import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      final InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          try {
            // handle notification tap if needed in future
          } catch (e, st) {
            logError(e, st);
          }
        },
      );

      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
        await androidPlugin?.requestExactAlarmsPermission();
      }

      // Platform-specific permission requests are handled by the
      // Darwin initialization settings passed to `_plugin.initialize`.
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
        id: notifId,
        title: 'Upcoming birthday — ${birthday.name}',
        body: 'In 14 days: ${birthday.name}\'s birthday is on ${birthday.date.month}/${birthday.date.day}',
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e, st) {
      logError(e, st);
    }
  }

  Future<void> cancelBirthdayNotification(String id) async {
    try {
      await _plugin.cancel(id: _idFromString(id));
    } catch (e, st) {
      logError(e, st);
    }
  }

  /// Schedules an immediate (debug) notification after [seconds] seconds.
  Future<void> scheduleTestNotification({int seconds = 5}) async {
    try {
      final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
      final androidDetails = AndroidNotificationDetails(
        'debug_channel',
        'Debug notifications',
        channelDescription: 'Debug channel for testing',
        importance: Importance.max,
        priority: Priority.high,
      );
      final iosDetails = DarwinNotificationDetails();
      await _plugin.zonedSchedule(
        id: 999999,
        title: 'Test notification',
        body: 'This is a debug notification scheduled $seconds seconds ago',
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e, st) {
      logError(e, st);
    }
  }
}
