# Интеграция ЮKassa - Инструкция

## Что сделано:

1. ✅ Создан сервис `YooKassaService` для работы с API ЮKassa
2. ✅ Обновлен экран оплаты `PaywallScreen`:
   - Убрано слово "Премиум"
   - Добавлена кнопка "Продолжить пользоваться ассистентом"
   - Красивый UI с описанием преимуществ
   - Цена 500₽
3. ✅ Интеграция с ЮKassa через API

## Что нужно сделать:

### 1. Получить данные от ЮKassa

Зайдите в личный кабинет ЮKassa и получите:
- **Shop ID** (идентификатор магазина)
- **Secret Key** (секретный ключ для API)

### 2. Добавить ключи в код

Откройте файл `/Users/niklay/instrukciya_child/lib/services/yookassa_service.dart`

Замените строки 5-6:
```dart
static const String _shopId = 'YOUR_SHOP_ID'; // Замените на ваш Shop ID
static const String _secretKey = 'YOUR_SECRET_KEY'; // Замените на ваш Secret Key
```

### 3. Настроить URL Scheme для возврата из оплаты

#### Для iOS:
1. Откройте `ios/Runner/Info.plist`
2. Добавьте перед `</dict>`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.example.instrukciyaChild</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>instrukciya</string>
        </array>
    </dict>
</array>
```

#### Для Android:
1. Откройте `android/app/src/main/AndroidManifest.xml`
2. Добавьте внутри `<activity>` с `android.intent.action.MAIN`:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="instrukciya" />
</intent-filter>
```

### 4. Настроить Webhook (рекомендуется для production)

Для автоматической активации после оплаты нужно:
1. Создать backend endpoint для получения уведомлений от ЮKassa
2. В личном кабинете ЮKassa указать URL вебхука
3. При получении уведомления о успешной оплате - активировать доступ в Firebase

**Временное решение:** Сейчас используется кнопка "Я оплатил" - пользователь сам подтверждает оплату.

### 5. Тестирование

ЮKassa предоставляет тестовый режим:
- Тестовые карты: https://yookassa.ru/developers/payment-acceptance/testing-and-going-live/testing
- Для тестирования используйте тестовые ключи из личного кабинета

### 6. Запуск

```bash
flutter pub get
flutter run
```

## Как это работает:

1. Пользователь использует 5 бесплатных запросов
2. При 6-м запросе открывается экран оплаты
3. Нажимает "Продолжить пользоваться ассистентом"
4. Открывается страница оплаты ЮKassa в браузере
5. После оплаты возвращается в приложение
6. Нажимает "Я оплатил"
7. Получает безлимитный доступ к ассистенту

## Безопасность:

⚠️ **ВАЖНО:** Не коммитьте Secret Key в Git!
Используйте переменные окружения или Firebase Remote Config для хранения ключей.

## Следующие шаги (опционально):

1. Добавить Firebase Functions для обработки webhook от ЮKassa
2. Хранить статус оплаты в Firestore
3. Добавить проверку статуса платежа по ID
4. Реализовать возврат средств через API
