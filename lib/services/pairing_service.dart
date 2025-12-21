import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Упрощённый локальный сервис "связки" без Firebase.
///
/// Весь функционал семейной ленты и приглашений теперь работает **только локально**,
/// через `SharedPreferences` и шаринг ссылок. Это гарантирует, что приложение
/// запускается и в web, и без настроенного Firebase.
class PairingService {
  static const String _pairCodeKey = 'pairCode';
  static const String _partnerIdKey = 'partnerId';
  static const String _familyFeedKey = 'familyFeed';

  /// Генерация кода приглашения (локально, без сервера).
  static Future<String> generatePairCode() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_pairCodeKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final code = _generateInviteCode();
    await prefs.setString(_pairCodeKey, code);
    return code;
  }

  /// Текущий код (создаст новый, если ещё не было).
  static Future<String?> getCurrentPairCode() async {
    return generatePairCode();
  }

  /// "Присоединение" по коду — просто сохраняем его локально.
  static Future<bool> enterPairCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_partnerIdKey, code.trim());
    return true;
  }

  /// Считаем, что связка есть, если сохранён partnerId.
  static Future<bool> isPaired() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_partnerIdKey) != null;
  }

  /// ID семьи в локальном варианте не используется.
  static Future<String?> getFamilyId() async => null;

  /// Список членов семьи — пустой локальный заглушечный список.
  static Future<List<Map<String, dynamic>>> getFamilyMembers() async => [];

  // --- Локальная "семейная лента" (остаётся как была) ---

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

  static Future<List<Map<String, dynamic>>> getFamilyFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final feedJson = prefs.getString(_familyFeedKey) ?? '[]';
    final List<dynamic> feed = jsonDecode(feedJson);

    return feed.cast<Map<String, dynamic>>();
  }

  static Future<void> clearPairing() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pairCodeKey);
    await prefs.remove(_partnerIdKey);
    await prefs.remove(_familyFeedKey);
  }

  /// Отправка приглашения через WhatsApp (локальный код).
  static Future<void> sendWhatsAppInvite() async {
    final inviteCode = await getCurrentPairCode();
    if (inviteCode == null || inviteCode.isEmpty) return;

    final message = 'Присоединяйся к нашей семье в приложении "Мамин путь"!\n'
        'Код приглашения: $inviteCode\n\n'
        'Скачай приложение и введи этот код, чтобы получить доступ к общим событиям и чек-листам.';

    final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse(whatsappUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Шаринг кода через системное меню.
  static Future<void> shareInviteCode() async {
    final inviteCode = await getCurrentPairCode();
    if (inviteCode == null || inviteCode.isEmpty) return;

    final message = 'Присоединяйся к нашей семье в приложении "Мамин путь"!\n'
        'Код приглашения: $inviteCode';

    await Share.share(message);
  }

  // --- Вспомогательное ---

  static String _generateInviteCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
