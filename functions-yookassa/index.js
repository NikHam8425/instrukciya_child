const { onRequest, onCall } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const { v4: uuidv4 } = require("uuid");

admin.initializeApp();

// Секреты из Secret Manager
const YOOKASSA_SHOP_ID = defineSecret("YOOKASSA_SHOP_ID");
const YOOKASSA_SECRET_KEY = defineSecret("YOOKASSA_SECRET_KEY");
const YOOKASSA_WEBHOOK_SECRET = defineSecret("YOOKASSA_WEBHOOK_SECRET");

// ============================================================================
// 1. createPayment - Создание платежа через ЮKassa
// ============================================================================
// ============================================================================
// 1. createPayment - Создание платежа через ЮKassa
// ============================================================================
const { HttpsError } = require("firebase-functions/v2/https");

exports.createPayment = onCall(
  {
    secrets: [YOOKASSA_SHOP_ID, YOOKASSA_SECRET_KEY],
    region: "europe-west1",
  },
  async (request) => {
    try {
      const { amount, currency = "RUB", planId, returnUrl } = request.data;
      const uid = request.auth?.uid;

      if (!uid) {
        throw new HttpsError("unauthenticated", "Пользователь не авторизован");
      }

      if (!amount || amount <= 0) {
        throw new HttpsError("invalid-argument", "Неверная сумма платежа");
      }

      // Проверка наличия секретов
      if (!YOOKASSA_SHOP_ID.value() || !YOOKASSA_SECRET_KEY.value()) {
        console.error("Missing YooKassa secrets");
        throw new HttpsError("failed-precondition", "Ошибка конфигурации сервера (Secrets)");
      }

      // Генерируем уникальный ключ идемпотентности
      const idempotenceKey = uuidv4();

      // Формируем Basic Auth
      const shopId = YOOKASSA_SHOP_ID.value();
      const secretKey = YOOKASSA_SECRET_KEY.value();
      const auth = Buffer.from(`${shopId}:${secretKey}`).toString("base64");

      // Тело запроса к ЮKassa
      const paymentData = {
        amount: {
          value: amount.toFixed(2),
          currency: currency,
        },
        confirmation: {
          type: "redirect",
          return_url: returnUrl || "instrukciya://payment/success",
        },
        capture: true,
        description: `Подписка на ассистента "Мамин путь" (30 дней)`,
        metadata: {
          uid: uid,
          planId: planId || "assistant_access",
        },
        save_payment_method: true,
      };

      console.log(`Creating payment for ${uid}, amount: ${amount}`);

      // Запрос к API ЮKassa
      const response = await fetch("https://api.yookassa.ru/v3/payments", {
        method: "POST",
        headers: {
          "Authorization": `Basic ${auth}`,
          "Content-Type": "application/json",
          "Idempotence-Key": idempotenceKey,
        },
        body: JSON.stringify(paymentData),
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error("YooKassa API error:", errorText);
        throw new HttpsError("internal", `Ошибка ЮKassa: ${response.status}`, { details: errorText });
      }

      const payment = await response.json();

      // Сохраняем информацию о платеже в Firestore
      await admin.firestore().collection("payments").doc(payment.id).set({
        uid: uid,
        paymentId: payment.id,
        planId: planId || "assistant_access",
        amount: amount,
        currency: currency,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        metadata: payment.metadata,
      });

      // Возвращаем клиенту URL для оплаты
      return {
        paymentId: payment.id,
        confirmationUrl: payment.confirmation.confirmation_url,
        status: payment.status,
      };
    } catch (error) {
      console.error("Error creating payment:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Не удалось создать платеж", { message: error.message });
    }
  }
);

// ============================================================================
// 2. yookassaWebhook - Обработка webhook от ЮKassa
// ============================================================================
exports.yookassaWebhook = onRequest(
  {
    secrets: [YOOKASSA_SHOP_ID, YOOKASSA_SECRET_KEY],
    region: "europe-west1",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const event = req.body;
      console.log("Received webhook:", JSON.stringify(event, null, 2));

      // Проверяем тип события
      if (event.event === "payment.succeeded") {
        const payment = event.object;
        const { uid, planId } = payment.metadata;
        const paymentMethodId = payment.payment_method?.id;

        if (!uid) {
          console.error("No UID in payment metadata");
          res.status(400).send("Missing UID");
          return;
        }

        // Обновляем статус платежа в Firestore
        await admin.firestore()
          .collection("payments")
          .doc(payment.id)
          .update({
            status: "succeeded",
            paymentMethodId: paymentMethodId,
            succeededAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        // Активируем подписку пользователя
        const nextChargeAt = new Date();
        nextChargeAt.setMonth(nextChargeAt.getMonth() + 1);

        await admin.firestore()
          .collection("users")
          .doc(uid)
          .set({
            subscription: {
              active: true,
              planId: planId || "assistant_access",
              paymentMethodId: paymentMethodId,
              nextChargeAt: admin.firestore.Timestamp.fromDate(nextChargeAt),
              activatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
          }, { merge: true });

        console.log(`Subscription activated for user ${uid}`);
      } else if (event.event === "payment.canceled") {
        const payment = event.object;

        // Обновляем статус платежа
        await admin.firestore()
          .collection("payments")
          .doc(payment.id)
          .update({
            status: "canceled",
            canceledAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        console.log(`Payment ${payment.id} canceled`);
      }

      res.status(200).send("OK");
    } catch (error) {
      console.error("Webhook error:", error);
      res.status(500).send("Internal Server Error");
    }
  }
);

// ============================================================================
// 3. chargeRecurring - Автоматическое продление подписок
// ============================================================================
exports.chargeRecurring = onSchedule(
  {
    schedule: "0 2 * * *", // Каждый день в 2:00 UTC
    secrets: [YOOKASSA_SHOP_ID, YOOKASSA_SECRET_KEY],
    region: "europe-west1",
    timeZone: "UTC",
  },
  async (event) => {
    console.log("Starting recurring charges...");

    const now = admin.firestore.Timestamp.now();

    // Находим пользователей с активной подпиской, которую нужно продлить
    const usersSnapshot = await admin.firestore()
      .collection("users")
      .where("subscription.active", "==", true)
      .where("subscription.nextChargeAt", "<=", now)
      .get();

    console.log(`Found ${usersSnapshot.size} subscriptions to renew`);

    const shopId = YOOKASSA_SHOP_ID.value();
    const secretKey = YOOKASSA_SECRET_KEY.value();
    const auth = Buffer.from(`${shopId}:${secretKey}`).toString("base64");

    for (const userDoc of usersSnapshot.docs) {
      const uid = userDoc.id;
      const subscription = userDoc.data().subscription;

      if (!subscription.paymentMethodId) {
        console.error(`No payment method for user ${uid}`);
        continue;
      }

      try {
        // Создаем платеж с сохраненным методом оплаты
        const paymentData = {
          amount: {
            value: "500.00", // Цена подписки
            currency: "RUB",
          },
          payment_method_id: subscription.paymentMethodId,
          capture: true,
          description: `Продление подписки ${subscription.planId}`,
          metadata: {
            uid: uid,
            planId: subscription.planId,
            recurring: true,
          },
        };

        const response = await fetch("https://api.yookassa.ru/v3/payments", {
          method: "POST",
          headers: {
            "Authorization": `Basic ${auth}`,
            "Content-Type": "application/json",
            "Idempotence-Key": uuidv4(),
          },
          body: JSON.stringify(paymentData),
        });

        if (!response.ok) {
          const errorText = await response.text();
          console.error(`Failed to charge user ${uid}:`, errorText);

          // Деактивируем подписку при ошибке оплаты
          await admin.firestore().collection("users").doc(uid).update({
            "subscription.active": false,
            "subscription.failedAt": admin.firestore.FieldValue.serverTimestamp(),
          });

          continue;
        }

        const payment = await response.json();

        // Сохраняем информацию о платеже
        await admin.firestore().collection("payments").doc(payment.id).set({
          uid: uid,
          paymentId: payment.id,
          planId: subscription.planId,
          amount: 500,
          currency: "RUB",
          status: payment.status,
          recurring: true,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Обновляем дату следующего списания
        if (payment.status === "succeeded") {
          const nextCharge = new Date();
          nextCharge.setMonth(nextCharge.getMonth() + 1);

          await admin.firestore().collection("users").doc(uid).update({
            "subscription.nextChargeAt": admin.firestore.Timestamp.fromDate(nextCharge),
            "subscription.lastChargedAt": admin.firestore.FieldValue.serverTimestamp(),
          });

          console.log(`Successfully charged user ${uid}`);
        }
      } catch (error) {
        console.error(`Error charging user ${uid}:`, error);
      }
    }

    console.log("Recurring charges completed");
  }
);

// ============================================================================
// 4. checkSubscriptionStatus - Проверка статуса подписки (вспомогательная)
// ============================================================================
exports.checkSubscriptionStatus = onCall(
  { region: "europe-west1" },
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new Error("Пользователь не авторизован");
    }

    const userDoc = await admin.firestore().collection("users").doc(uid).get();

    if (!userDoc.exists) {
      return { active: false };
    }

    const subscription = userDoc.data()?.subscription;

    return {
      active: subscription?.active || false,
      planId: subscription?.planId,
      nextChargeAt: subscription?.nextChargeAt?.toDate(),
    };
  }
);
