import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../constants/affirmations.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _enabledKey = 'reminder_enabled';
  static const String _hourKey = 'reminder_hour';
  static const String _minuteKey = 'reminder_minute';

  // Weekly reflection prefs
  static const String _weeklyReflectionEnabledKey =
      'weekly_reflection_enabled';
  static const String _weeklyReflectionWeekdayKey =
      'weekly_reflection_weekday';
  static const String _weeklyReflectionHourKey = 'weekly_reflection_hour';
  static const String _weeklyReflectionMinuteKey = 'weekly_reflection_minute';

  // Monthly reflection prefs
  static const String _monthlyReflectionEnabledKey =
      'monthly_reflection_enabled';
  static const String _monthlyReflectionDayKey = 'monthly_reflection_day';
  static const String _monthlyReflectionHourKey = 'monthly_reflection_hour';
  static const String _monthlyReflectionMinuteKey =
      'monthly_reflection_minute';

  // Affirmation prefs
  static const String _affirmationEnabledKey = 'affirmation_enabled';
  static const String _affirmationIntervalKey = 'affirmation_interval_hours';
  static const String _affirmationStartHourKey = 'affirmation_start_hour';
  static const String _affirmationEndHourKey = 'affirmation_end_hour';

  // Notification IDs
  static const int _dailyReminderId = 0;
  static const int _weeklyDigestId = 1;
  static const int _weeklyReflectionId = 2;
  static const int _monthlyReflectionId = 3;
  // Affirmation slot IDs: 10..29 (max 20 slots/day)
  static const int _affirmationIdBase = 10;
  static const int _affirmationMaxSlots = 20;
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

  // ─── Weekly reflection ───

  /// [weekday] uses Dart's DateTime.weekday: 1 = Monday, 7 = Sunday.
  Future<void> scheduleWeeklyReflection({
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    await _notifications.cancel(_weeklyReflectionId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'weekly_reflection',
      'Weekly Reflection',
      channelDescription: 'A weekly prompt to reflect on your week',
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
      _weeklyReflectionId,
      'A moment for weekly reflection \u{1F33F}',
      'Look back at the week and notice what you\'re carrying.',
      scheduled,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_reflection',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weeklyReflectionEnabledKey, true);
    await prefs.setInt(_weeklyReflectionWeekdayKey, weekday);
    await prefs.setInt(_weeklyReflectionHourKey, hour);
    await prefs.setInt(_weeklyReflectionMinuteKey, minute);
  }

  Future<void> cancelWeeklyReflection() async {
    await _notifications.cancel(_weeklyReflectionId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weeklyReflectionEnabledKey, false);
  }

  Future<bool> isWeeklyReflectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_weeklyReflectionEnabledKey) ?? false;
  }

  Future<({int weekday, int hour, int minute})>
      getWeeklyReflectionSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      weekday: prefs.getInt(_weeklyReflectionWeekdayKey) ?? DateTime.sunday,
      hour: prefs.getInt(_weeklyReflectionHourKey) ?? 10,
      minute: prefs.getInt(_weeklyReflectionMinuteKey) ?? 0,
    );
  }

  // ─── Monthly reflection ───

  /// `flutter_local_notifications` has no native monthly repeat, so this
  /// schedules only the next occurrence. [rescheduleReflectionsIfEnabled] is
  /// called on app startup to bump it forward as months roll over.
  Future<void> scheduleMonthlyReflection({
    required int dayOfMonth,
    required int hour,
    required int minute,
  }) async {
    await _notifications.cancel(_monthlyReflectionId);

    final now = tz.TZDateTime.now(tz.local);
    final clampedDay = dayOfMonth.clamp(1, 28);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, clampedDay, hour, minute,
    );
    if (!scheduled.isAfter(now)) {
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      scheduled = tz.TZDateTime(
        tz.local, nextYear, nextMonth, clampedDay, hour, minute,
      );
    }

    const androidDetails = AndroidNotificationDetails(
      'monthly_reflection',
      'Monthly Reflection',
      channelDescription: 'A monthly prompt to reflect on the month',
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
      _monthlyReflectionId,
      'A moment for monthly reflection \u{1F319}',
      'Look back at the month — what shifted, what you\'re carrying forward.',
      scheduled,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'monthly_reflection',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_monthlyReflectionEnabledKey, true);
    await prefs.setInt(_monthlyReflectionDayKey, dayOfMonth);
    await prefs.setInt(_monthlyReflectionHourKey, hour);
    await prefs.setInt(_monthlyReflectionMinuteKey, minute);
  }

  Future<void> cancelMonthlyReflection() async {
    await _notifications.cancel(_monthlyReflectionId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_monthlyReflectionEnabledKey, false);
  }

  Future<bool> isMonthlyReflectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_monthlyReflectionEnabledKey) ?? false;
  }

  Future<({int day, int hour, int minute})>
      getMonthlyReflectionSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      day: prefs.getInt(_monthlyReflectionDayKey) ?? 1,
      hour: prefs.getInt(_monthlyReflectionHourKey) ?? 10,
      minute: prefs.getInt(_monthlyReflectionMinuteKey) ?? 0,
    );
  }

  /// Re-schedule reflection notifications using stored prefs. Call on app
  /// startup so the monthly notification (which doesn't natively repeat)
  /// rolls forward to the next month after firing.
  Future<void> rescheduleReflectionsIfEnabled() async {
    if (await isWeeklyReflectionEnabled()) {
      final s = await getWeeklyReflectionSettings();
      await scheduleWeeklyReflection(
        weekday: s.weekday,
        hour: s.hour,
        minute: s.minute,
      );
    }
    if (await isMonthlyReflectionEnabled()) {
      final s = await getMonthlyReflectionSettings();
      await scheduleMonthlyReflection(
        dayOfMonth: s.day,
        hour: s.hour,
        minute: s.minute,
      );
    }
  }

  // ─── Affirmation reminders ───

  /// Schedules recurring affirmation notifications. Slots are spaced by
  /// [intervalHours] between [startHour] and [endHour] (inclusive). Each slot
  /// repeats daily via [DateTimeComponents.time]. Body text is drawn from
  /// [affirmations] and rotates by slot index; re-call this method (e.g. on
  /// app startup) to refresh which affirmations appear.
  Future<void> scheduleAffirmationSlots({
    required int intervalHours,
    required int startHour,
    required int endHour,
  }) async {
    await cancelAffirmations();

    if (intervalHours < 1) intervalHours = 1;
    if (startHour < 0 || startHour > 23) startHour = 9;
    if (endHour < startHour) endHour = startHour;
    if (endHour > 23) endHour = 23;

    final slotHours = <int>[];
    for (int h = startHour; h <= endHour; h += intervalHours) {
      slotHours.add(h);
      if (slotHours.length >= _affirmationMaxSlots) break;
    }

    if (slotHours.isEmpty) {
      // Save prefs anyway so the toggle state stays consistent.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_affirmationEnabledKey, true);
      await prefs.setInt(_affirmationIntervalKey, intervalHours);
      await prefs.setInt(_affirmationStartHourKey, startHour);
      await prefs.setInt(_affirmationEndHourKey, endHour);
      return;
    }

    // Pick a fresh starting offset each schedule so re-toggling rotates
    // which affirmations appear.
    final random = Random();
    final startIndex = affirmations.isEmpty
        ? 0
        : random.nextInt(affirmations.length);

    const androidDetails = AndroidNotificationDetails(
      'affirmations',
      'Affirmations',
      channelDescription: 'Personal affirmation reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
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

    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < slotHours.length; i++) {
      final hour = slotHours[i];
      var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, 0,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final affirmationIndex = affirmations.isEmpty
          ? 0
          : (startIndex + i) % affirmations.length;
      final body = affirmations.isEmpty
          ? 'A small kindness for yourself today.'
          : affirmations[affirmationIndex].text;

      await _notifications.zonedSchedule(
        _affirmationIdBase + i,
        'A moment with yourself \u{2728}',
        body,
        scheduled,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'affirmation',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_affirmationEnabledKey, true);
    await prefs.setInt(_affirmationIntervalKey, intervalHours);
    await prefs.setInt(_affirmationStartHourKey, startHour);
    await prefs.setInt(_affirmationEndHourKey, endHour);
  }

  Future<void> cancelAffirmations() async {
    for (int i = 0; i < _affirmationMaxSlots; i++) {
      await _notifications.cancel(_affirmationIdBase + i);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_affirmationEnabledKey, false);
  }

  Future<bool> isAffirmationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_affirmationEnabledKey) ?? false;
  }

  Future<({int intervalHours, int startHour, int endHour})>
      getAffirmationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      intervalHours: prefs.getInt(_affirmationIntervalKey) ?? 3,
      startHour: prefs.getInt(_affirmationStartHourKey) ?? 9,
      endHour: prefs.getInt(_affirmationEndHourKey) ?? 21,
    );
  }

  /// Call on app startup so the body-text rotates to fresh affirmations and
  /// any past slots roll forward.
  Future<void> rescheduleAffirmationsIfEnabled() async {
    if (await isAffirmationEnabled()) {
      final s = await getAffirmationSettings();
      await scheduleAffirmationSlots(
        intervalHours: s.intervalHours,
        startHour: s.startHour,
        endHour: s.endHour,
      );
    }
  }
}
