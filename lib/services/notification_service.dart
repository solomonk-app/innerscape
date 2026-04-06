import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _enabledKey = 'reminder_enabled';
  static const String _hourKey = 'reminder_hour';
  static const String _minuteKey = 'reminder_minute';

  // Notification IDs
  static const int _dailyReminderId = 0;
  static const int _weeklyDigestId = 1;
  // Capsule IDs start at 100
  static int _capsuleNotificationId(String capsuleId) =>
      100 + capsuleId.hashCode.abs() % 9900;

  static const List<String> _reminderTitles = [
    'Time to check in \u{1F319}',
    'How are you feeling? \u{2728}',
    'A moment for yourself \u{1F9D8}',
    'Your journal awaits \u{1F4DD}',
    'Pause. Breathe. Reflect. \u{1F33F}',
  ];

  static const List<String> _reminderBodies = [
    'Take a moment to reflect on your day and log your mood.',
    'A quick check-in can make all the difference. How\'s your day going?',
    'Your future self will thank you for journaling today.',
    'Even a one-word entry counts. What\'s on your mind?',
    'Tracking your mood helps you understand yourself better.',
    'Don\'t break your streak! Take 30 seconds to check in.',
    'Your mood matters. Let\'s capture how you\'re feeling.',
    'A little self-reflection goes a long way. Ready to check in?',
    'Today\'s challenge is ready! Check in to see what awaits you.',
    'A new wellness challenge is waiting. Ready to give it a try?',
  ];

  /// Initialize the notification plugin and timezone data
  Future<void> init() async {
    tzdata.initializeTimeZones();
    final String tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));
    debugPrint('Timezone set to: $tzName');

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final result = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidPlugin?.requestNotificationsPermission();
      return result ?? true;
    }
    return false;
  }

  /// Schedule a daily reminder at the specified time
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    // Cancel existing daily reminder
    await _notifications.cancel(_dailyReminderId);

    final random = Random();
    final title = _reminderTitles[random.nextInt(_reminderTitles.length)];
    final body = _reminderBodies[random.nextInt(_reminderBodies.length)];

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'mood_reminder',
      'Mood Reminders',
      channelDescription: 'Daily reminders to log your mood',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE8945A),
      styleInformation: BigTextStyleInformation(''),
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
      _dailyReminderId,
      title,
      body,
      scheduledDate,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'mood_checkin',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minuteKey, minute);
  }

  /// Cancel all scheduled reminders
  Future<void> cancelReminder() async {
    await _notifications.cancel(_dailyReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
  }

  /// Check if reminders are currently enabled
  Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Get the currently saved reminder time
  Future<TimeOfDay> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_hourKey) ?? 20;
    final minute = prefs.getInt(_minuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Reschedule with the saved time (call on app startup if enabled)
  Future<void> rescheduleIfEnabled() async {
    final enabled = await isReminderEnabled();
    if (enabled) {
      final time = await getReminderTime();
      await scheduleDailyReminder(hour: time.hour, minute: time.minute);
    }
  }

  /// Schedule a one-time notification for a time capsule
  Future<void> scheduleCapsuleNotification({
    required String capsuleId,
    required DateTime unlocksAt,
  }) async {
    final notifId = _capsuleNotificationId(capsuleId);
    final scheduledDate = tz.TZDateTime.from(unlocksAt, tz.local);

    // Don't schedule if already past
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      'time_capsule',
      'Time Capsules',
      channelDescription: 'Notifications when your time capsules are ready',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFD4A574),
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
      notifId,
      'Your time capsule is ready! \u{1F48C}',
      'A letter from your past self is waiting to be opened.',
      scheduledDate,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'time_capsule_$capsuleId',
    );
  }

  /// Schedule weekly digest reminder (Sunday 10am)
  Future<void> scheduleWeeklyDigestReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    // Find next Sunday
    var nextSunday = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, 10, 0,
    );
    while (nextSunday.weekday != DateTime.sunday || nextSunday.isBefore(now)) {
      nextSunday = nextSunday.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'weekly_digest',
      'Weekly Digest',
      channelDescription: 'Weekly mood digest reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE8945A),
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
      _weeklyDigestId,
      'Your weekly mood digest is ready \u{1F4CA}',
      'See how your week went and get insights for the week ahead.',
      nextSunday,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_digest',
    );
  }
}
