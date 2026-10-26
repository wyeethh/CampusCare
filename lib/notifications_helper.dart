import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// ---------------------------------------------------------------------------
// Local notifications for the clinic reminders
// ---------------------------------------------------------------------------
class NotificationsHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'clinic_reminders',
      'Clinic reminders',
      channelDescription: 'Reminders for your school clinic appointments',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  // Set up once when the app starts
  static Future<void> init() async {
    try {
      const AndroidInitializationSettings android =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings ios = DarwinInitializationSettings();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: android,
          iOS: ios,
        ),
      );

      // Ask notification permission on Android 13+
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    } catch (e) {
      // Notifications are optional, never break the app
    }
  }

  // Show a notification right away
  static Future<void> showNow(String title, String body) async {
    try {
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: title,
        body: body,
        notificationDetails: _details,
      );
    } catch (e) {
      // Ignore if the phone does not allow notifications
    }
  }

  // Show a reminder at the given date and time
  static Future<void> schedule(String title, String body, DateTime when) async {
    // If the reminder is basically now, just show it right away (good for demo)
    if (when.isBefore(DateTime.now().add(const Duration(seconds: 30)))) {
      await showNow(title, body);
      return;
    }

    try {
      // Exact alarm if the phone allows it, otherwise the normal one
      AndroidScheduleMode mode = AndroidScheduleMode.inexactAllowWhileIdle;
      bool? canExact = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.canScheduleExactNotifications();
      if (canExact == true) {
        mode = AndroidScheduleMode.exactAllowWhileIdle;
      }

      await _plugin.zonedSchedule(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: _details,
        androidScheduleMode: mode,
      );
    } catch (e) {
      // Ignore if the phone does not allow scheduled notifications
    }
  }
}
