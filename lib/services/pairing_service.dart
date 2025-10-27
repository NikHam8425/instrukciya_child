import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class PairingService {
  static const String _pairCodeKey = 'pairCode';
  static const String _partnerIdKey = 'partnerId';
  static const String _familyFeedKey = 'familyFeed';

  // Генерация кода для связки
  static Future<String> generatePairCode() async {
    final random = Random();
    final code = (100000 + random.nextInt(900000)).toString(); // 6-значный код
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pairCodeKey, code);
    
    return code;
  }

  // Ввод кода для связки
  static Future<bool> enterPairCode(String code) async {
    // Заглушка для проверки кода (в реальном приложении здесь будет запрос к бэкенду)
    if (code.length == 6 && code.contains(RegExp(r'^\d+$'))) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_partnerIdKey, 'partner_${DateTime.now().millisecondsSinceEpoch}');
      return true;
    }
    return false;
  }

  // Получение текущего кода
  static Future<String?> getCurrentPairCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pairCodeKey);
  }

  // Проверка, есть ли связка
  static Future<bool> isPaired() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_partnerIdKey) != null;
  }

  // Получение ID партнёра
  static Future<String?> getPartnerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_partnerIdKey);
  }

  // Сохранение записи в семейную ленту
  static Future<void> addFamilyFeedEntry({
    required String author,
    required String content,
    required DateTime timestamp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingFeed = prefs.getString(_familyFeedKey) ?? '[]';
    final List<dynamic> feed = jsonDecode(existingFeed);
    
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'author': author,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
    
    feed.insert(0, entry); // Добавляем в начало списка
    
    await prefs.setString(_familyFeedKey, jsonEncode(feed));
  }

  // Получение семейной ленты
  static Future<List<Map<String, dynamic>>> getFamilyFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final feedJson = prefs.getString(_familyFeedKey) ?? '[]';
    final List<dynamic> feed = jsonDecode(feedJson);
    
    return feed.cast<Map<String, dynamic>>();
  }

  // Очистка связки
  static Future<void> clearPairing() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pairCodeKey);
    await prefs.remove(_partnerIdKey);
    await prefs.remove(_familyFeedKey);
  }

  // Заглушки для бэкенда
  static Future<bool> syncWithBackend() async {
    // Заглушка - в реальном приложении здесь будет синхронизация с сервером
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  static Future<bool> sendToPartner(Map<String, dynamic> entry) async {
    // Заглушка - в реальном приложении здесь будет отправка партнёру
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
