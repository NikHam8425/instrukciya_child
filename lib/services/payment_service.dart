import 'package:shared_preferences/shared_preferences.dart';
import 'yookassa_service.dart';

class PaymentService {
  static const int FREE_ACTIONS_LIMIT = 5;
  final _yooKassa = YooKassaService();

  /// Проверяет, есть ли у пользователя премиум подписка
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremium') ?? false;
  }

  /// Получает количество использованных бесплатных действий
  Future<int> getFreeActionsCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('freeActionsCount') ?? 0;
  }

  /// Увеличивает счетчик бесплатных действий
  Future<void> incrementFreeActions() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('freeActionsCount') ?? 0;
    await prefs.setInt('freeActionsCount', count + 1);
  }

  /// Проверяет, может ли пользователь выполнить действие
  Future<bool> canPerformAction() async {
    if (await isPremium()) return true;
    
    // Синхронизируем статус с сервером на случай, если подписка была куплена
    if (await syncSubscriptionStatus()) return true;
    
    final count = await getFreeActionsCount();
    return count < FREE_ACTIONS_LIMIT;
  }

  /// Выполняет действие с проверкой лимита
  Future<bool> performAction() async {
    if (await isPremium()) return true;

    final count = await getFreeActionsCount();
    if (count >= FREE_ACTIONS_LIMIT) {
      // Последний шанс - проверить на сервере (вдруг оплатил, но кеш старый)
      if (await syncSubscriptionStatus()) return true;
      return false; // Нужна подписка
    }

    await incrementFreeActions();
    return true;
  }

  /// Обновляет локальный статус премиума (вызывается после успешной оплаты)
  Future<bool> setPremiumStatus(bool isActive) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', isActive);
      return true;
    } catch (e) {
      print('Error setting premium status: $e');
      return false;
    }
  }

  /// Проверяет статус на сервере и обновляет локальный кеш
  Future<bool> syncSubscriptionStatus() async {
    try {
      final isActive = await _yooKassa.checkSubscriptionStatus();
      await setPremiumStatus(isActive);
      return isActive;
    } catch (e) {
      print('Sync subscription error: $e');
      return false;
    }
  }

  /// Восстанавливает покупки (проверяет статус в Firestore)
  Future<bool> restorePurchases() async {
    return await syncSubscriptionStatus();
  }

  /// Получает оставшиеся бесплатные действия
  Future<int> getRemainingFreeActions() async {
    final count = await getFreeActionsCount();
    return FREE_ACTIONS_LIMIT - count;
  }

  /// Сбрасывает счетчик бесплатных действий (для сброса данных)
  Future<void> resetFreeActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('freeActionsCount');
    await prefs.remove('isPremium');
  }
}

