import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AssistantNotifier {
  static final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const init = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(init);
  }

  Future<void> showLimitReached() async {
    const android = AndroidNotificationDetails(
      'assistant_channel', 'Assistant',
      importance: Importance.high, priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);
    await _plugin.show(
      1001, 'Лимит израсходован', 'Оформите PRO, чтобы продолжить общение',
      details,
    );
  }
}
