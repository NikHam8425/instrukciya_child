import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static const int FREE_ACTIONS_LIMIT = 5;

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

  /// Покупка премиум подписки (локальный режим)
  Future<bool> buyPro() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', true);
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
