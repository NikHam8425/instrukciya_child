import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
// Firebase temporarily disabled
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class PairingService {
  static const String _pairCodeKey = 'pairCode';
  static const String _partnerIdKey = 'partnerId';
  static const String _familyFeedKey = 'familyFeed';
  
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Создание новой семьи
  static Future<String?> createFamily(String familyName) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final inviteCode = _generateInviteCode();
      final familyRef = await _firestore.collection('families').add({
        'name': familyName,
        'memberIds': [user.uid],
        'creatorId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'inviteCode': inviteCode,
      });

      // Обновляем профиль пользователя
      await _firestore.collection('users').doc(user.uid).set({
        'familyId': familyRef.id,
        'role': 'creator',
        'email': user.email,
        'displayName': user.displayName ?? 'Пользователь',
        'isPremium': false,
        'freeActionsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return familyRef.id;
    } catch (e) {
      print('Error creating family: $e');
      return null;
    }
  }

  // Генерация кода приглашения
  static String _generateInviteCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Генерация кода для связки (старый метод, оставлен для совместимости)
  static Future<String> generatePairCode() async {
    final user = _auth.currentUser;
    if (user == null) return '';

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final familyId = userDoc.data()?['familyId'] as String?;
      
      if (familyId == null) return '';

      final familyDoc = await _firestore.collection('families').doc(familyId).get();
      return familyDoc.data()?['inviteCode'] ?? '';
    } catch (e) {
      return '';
    }
  }

  // Присоединение к семье по коду
  static Future<bool> enterPairCode(String code) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Ищем семью с таким кодом приглашения
      final querySnapshot = await _firestore
          .collection('families')
          .where('inviteCode', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      final familyDoc = querySnapshot.docs.first;
      final familyId = familyDoc.id;
      final memberIds = List<String>.from(familyDoc.data()['memberIds'] ?? []);

      // Проверяем, не состоит ли уже пользователь в этой семье
      if (memberIds.contains(user.uid)) return true;

      // Добавляем пользователя в семью
      memberIds.add(user.uid);
      await _firestore.collection('families').doc(familyId).update({
        'memberIds': memberIds,
      });

      // Обновляем профиль пользователя
      await _firestore.collection('users').doc(user.uid).set({
        'familyId': familyId,
        'role': 'member',
        'email': user.email,
        'displayName': user.displayName ?? 'Пользователь',
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error joining family: $e');
      return false;
    }
  }

  // Получение текущего кода приглашения
  static Future<String?> getCurrentPairCode() async {
    return await generatePairCode();
  }

  // Проверка, состоит ли пользователь в семье
  static Future<bool> isPaired() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final familyId = userDoc.data()?['familyId'];
      return familyId != null;
    } catch (e) {
      return false;
    }
  }

  // Получение ID семьи
  static Future<String?> getFamilyId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data()?['familyId'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Получение списка членов семьи
  static Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    final familyId = await getFamilyId();
    if (familyId == null) return [];

    try {
      final familyDoc = await _firestore.collection('families').doc(familyId).get();
      final memberIds = List<String>.from(familyDoc.data()?['memberIds'] ?? []);

      final members = <Map<String, dynamic>>[];
      for (final memberId in memberIds) {
        final userDoc = await _firestore.collection('users').doc(memberId).get();
        if (userDoc.exists) {
          members.add({
            'id': memberId,
            'displayName': userDoc.data()?['displayName'] ?? 'Пользователь',
            'email': userDoc.data()?['email'] ?? '',
            'role': userDoc.data()?['role'] ?? 'member',
          });
        }
      }

      return members;
    } catch (e) {
      print('Error getting family members: $e');
      return [];
    }
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

  // Отправка приглашения через WhatsApp
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

  // Поделиться кодом приглашения
  static Future<void> shareInviteCode() async {
    final inviteCode = await getCurrentPairCode();
    if (inviteCode == null || inviteCode.isEmpty) return;

    final message = 'Присоединяйся к нашей семье в приложении "Мамин путь"!\n'
        'Код приглашения: $inviteCode';

    await Share.share(message);
  }

  // Синхронизация с Firestore (автоматическая через стримы)
  static Stream<QuerySnapshot> getFamilyEventsStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .asyncExpand((userDoc) {
      final familyId = userDoc.data()?['familyId'] as String?;
      if (familyId == null) return const Stream.empty();

      return _firestore
          .collection('families')
          .doc(familyId)
          .collection('events')
          .orderBy('createdAt', descending: true)
          .snapshots();
    });
  }
}
