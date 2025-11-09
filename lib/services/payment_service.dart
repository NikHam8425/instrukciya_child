// Firebase temporarily disabled
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  // Firebase temporarily disabled - using local mode only
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static const int FREE_ACTIONS_LIMIT = 5;

  /// Проверяет, есть ли у пользователя премиум подписка
  Future<bool> isPremium() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Локальный режим
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool('isPremium') ?? false;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['isPremium'] ?? false;
    } catch (e) {
      // Fallback на локальное хранилище
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isPremium') ?? false;
    }
  }

  /// Получает количество использованных бесплатных действий
  Future<int> getFreeActionsCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Локальный режим
        final prefs = await SharedPreferences.getInstance();
        return prefs.getInt('freeActionsCount') ?? 0;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['freeActionsCount'] ?? 0;
    } catch (e) {
      // Fallback на локальное хранилище
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('freeActionsCount') ?? 0;
    }
  }

  /// Увеличивает счетчик бесплатных действий
  Future<void> incrementFreeActions() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Локальный режим
        final prefs = await SharedPreferences.getInstance();
        final count = prefs.getInt('freeActionsCount') ?? 0;
        await prefs.setInt('freeActionsCount', count + 1);
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'freeActionsCount': FieldValue.increment(1),
      });
    } catch (e) {
      // Fallback на локальное хранилище
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt('freeActionsCount') ?? 0;
      await prefs.setInt('freeActionsCount', count + 1);
    }
  }

  /// Проверяет, может ли пользователь выполнить действие
  Future<bool> canPerformAction() async {
    if (await isPremium()) return true;
    
    final count = await getFreeActionsCount();
    return count < FREE_ACTIONS_LIMIT;
  }

  /// Выполняет действие с проверкой лимита
  Future<bool> performAction() async {
    if (await isPremium()) return true;

    final count = await getFreeActionsCount();
    if (count >= FREE_ACTIONS_LIMIT) {
      return false; // Нужна подписка
    }

    await incrementFreeActions();
    return true;
  }

  /// Покупка премиум подписки через Stripe
  Future<bool> buyPro() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Вызываем Firebase Function для создания Stripe checkout session
      final callable = _functions.httpsCallable('createCheckoutSession');
      final result = await callable.call({
        'priceId': 'price_1234567890', // Замените на реальный Price ID из Stripe
        'userId': user.uid,
      });

      final sessionUrl = result.data['url'] as String?;
      if (sessionUrl == null) return false;

      // Здесь нужно открыть браузер с sessionUrl
      // После успешной оплаты Stripe webhook обновит isPremium в Firestore
      
      return true;
    } catch (e) {
      print('Error buying premium: $e');
      return false;
    }
  }

  /// Восстанавливает покупки (проверяет статус в Firestore)
  Future<bool> restorePurchases() async {
    return await isPremium();
  }

  /// Получает оставшиеся бесплатные действия
  Future<int> getRemainingFreeActions() async {
    final count = await getFreeActionsCount();
    return FREE_ACTIONS_LIMIT - count;
  }
}
