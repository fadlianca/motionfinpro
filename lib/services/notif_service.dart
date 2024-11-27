import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  late FlutterLocalNotificationsPlugin _plugin;

  NotificationService() {
    _plugin = FlutterLocalNotificationsPlugin();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    _plugin.initialize(settings);
  }

  Future<void> scheduleNotification(String title, DateTime date) async {
    await _plugin.zonedSchedule(
      0,
      'Pengingat Jadwal',
      title,
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'jadwal_channel',
          'Jadwal Notifications',
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
