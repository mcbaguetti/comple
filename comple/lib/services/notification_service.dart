import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../models/birthday.dart';
import 'error_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      final InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
      await _plugin.initialize(initSettings);
    } catch (e, st) {
      logError(e, st);
    }
  }

  int _idFromString(String id) => id.hashCode & 0x7fffffff;

  Future<void> scheduleBirthdayNotification(Birthday birthday) async {
    try {
      final now = DateTime.now();
      int year = now.year;

      DateTime nextBirthday = DateTime(year, birthday.date.month, birthday.date.day, 9, 0);
      DateTime notificationDate = nextBirthday.subtract(const Duration(days: 14));
      if (!notificationDate.isAfter(now)) {
        nextBirthday = DateTime(year + 1, birthday.date.month, birthday.date.day, 9, 0);
        notificationDate = nextBirthday.subtract(const Duration(days: 14));
      }

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(notificationDate, tz.local);

      final int notifId = _idFromString(birthday.id);

      final androidDetails = AndroidNotificationDetails(
        'birthday_channel',
        'Birthday reminders',
        channelDescription: 'Reminders for upcoming birthdays',
        importance: Importance.max,
        priority: Priority.high,
      );

      final iosDetails = DarwinNotificationDetails();

      await _plugin.zonedSchedule(
        notifId,
        'Upcoming birthday — ${birthday.name}',
        'In 14 days: ${birthday.name}\'s birthday is on ${birthday.date.month}/${birthday.date.day}',
        scheduledDate,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e, st) {
      logError(e, st);
    }
  }

  Future<void> cancelBirthdayNotification(String id) async {
    try {
      await _plugin.cancel(_idFromString(id));
    } catch (e, st) {
      logError(e, st);
    }
  }
}
