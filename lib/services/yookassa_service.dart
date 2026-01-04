import 'package:cloud_functions/cloud_functions.dart';

class YooKassaService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  /// Создает платеж в ЮKassa через Firebase Cloud Functions
  /// Возвращает Map с result (URL для оплаты) и paymentId или null в случае ошибки
  Future<Map<String, String>?> createPayment({
    required double amount,
    required String description,
    String? returnUrl,
    String? planId,
  }) async {
    try {
      final callable = _functions.httpsCallable('createPayment');
      
      final result = await callable.call({
        'amount': amount,
        'description': description,
        'returnUrl': returnUrl ?? 'instrukciya://payment/success',
        'planId': planId,
      });

      final data = result.data as Map<dynamic, dynamic>;
      
      return {
        'confirmationUrl': data['confirmationUrl'] as String,
        'paymentId': data['paymentId'] as String,
      };
    } catch (e) {
      print('YooKassa Cloud Function exception: $e');
      return null;
    }
  }

  /// Проверяет статус подписки через Firebase (вспомогательная функция клиента)
  /// В продакшене лучше слушать изменения в Firestore через Stream
  Future<bool> checkSubscriptionStatus() async {
    try {
      final callable = _functions.httpsCallable('checkSubscriptionStatus');
      final result = await callable.call();
      final data = result.data as Map<dynamic, dynamic>;
      return data['active'] as bool == true;
    } catch (e) {
      print('Check Subscription Status exception: $e');
      return false;
    }
  }
}
