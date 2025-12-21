import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  static Future<void> scheduleBabyNotifications(DateTime babyDob) async {
    // Уведомление через 1 месяц - "к врачу"
    final oneMonthLater = babyDob.add(const Duration(days: 30));
    await _scheduleNotification(
      id: 1,
      title: 'Напоминание',
      body: 'Время идти к врачу на осмотр',
      scheduledDate: oneMonthLater,
    );

    // Уведомление через 6 месяцев - "прикорм"
    final sixMonthsLater = babyDob.add(const Duration(days: 180));
    await _scheduleNotification(
      id: 2,
      title: 'Напоминание',
      body: 'Время вводить прикорм',
      scheduledDate: sixMonthsLater,
    );

    // Уведомление через 12 месяцев - "первые зубы"
    final twelveMonthsLater = babyDob.add(const Duration(days: 365));
    await _scheduleNotification(
      id: 3,
      title: 'Напоминание',
      body: 'Первые зубы должны появиться',
      scheduledDate: twelveMonthsLater,
    );
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Устанавливаем время на 09:00
    final scheduledTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9, // 09:00
    );

    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'baby_reminders',
      'Напоминания о ребёнке',
      channelDescription: 'Уведомления о важных этапах развития ребёнка',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}