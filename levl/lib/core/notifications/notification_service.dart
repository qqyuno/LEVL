import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'notification_messages.dart';

/// Handles all local push notifications for LEVL.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification channel / IDs
  static const _channelId = 'levl_reminders';
  static const _channelName = 'LEVL Напоминания';
  static const _morningId = 1001;
  static const _streakId = 1002;
  static const _returnId = 1003;

  // Prefs keys
  static const _keyEnabled = 'notif_enabled';
  static const _keyMorningHour = 'notif_morning_hour';
  static const _keyMorningMinute = 'notif_morning_minute';
  static const _keyStreakAlert = 'notif_streak_alert';
  static const _keyReturnAlert = 'notif_return_alert';

  // ── Init ──────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    // Timezone setup
    tz_data.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Moscow'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    _initialized = true;
  }

  // ── Permission ────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    // Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    // iOS
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  // ── Schedule all notifications ────────────────────────────────────
  /// Call this on every app launch and when settings change.
  Future<void> scheduleAll({
    required int dailyMinutes,
    required int currentStreak,
  }) async {
    if (!_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_keyEnabled) ?? false;

    // Cancel everything first
    await _plugin.cancelAll();

    if (!enabled) return;

    final hour = prefs.getInt(_keyMorningHour) ?? 9;
    final minute = prefs.getInt(_keyMorningMinute) ?? 0;
    final streakAlert = prefs.getBool(_keyStreakAlert) ?? true;
    final returnAlert = prefs.getBool(_keyReturnAlert) ?? true;

    // 1. Morning reminder — daily at chosen time
    await _scheduleMorning(hour, minute, dailyMinutes);

    // 2. Streak at risk — daily at 21:00 (cancelled in-app if quests done)
    if (streakAlert && currentStreak > 0) {
      await _scheduleStreakAlert(dailyMinutes, currentStreak);
    }

    // 3. Return after absence — 2 days from now
    if (returnAlert) {
      await _scheduleReturn();
    }
  }

  // ── Morning ───────────────────────────────────────────────────────
  Future<void> _scheduleMorning(int hour, int minute, int dailyMinutes) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final message = NotificationMessages.morning(dailyMinutes, date: scheduled);

    await _plugin.zonedSchedule(
      _morningId,
      'LEVL',
      message,
      scheduled,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
  }

  // ── Streak alert ──────────────────────────────────────────────────
  Future<void> _scheduleStreakAlert(int dailyMinutes, int currentStreak) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 21, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final message = NotificationMessages.streak(currentStreak, dailyMinutes,
        date: scheduled);

    await _plugin.zonedSchedule(
      _streakId,
      'LEVL',
      message,
      scheduled,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Return after absence ──────────────────────────────────────────
  Future<void> _scheduleReturn() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(const Duration(days: 2));

    final message = NotificationMessages.returnAfterAbsence(date: scheduled);

    await _plugin.zonedSchedule(
      _returnId,
      'LEVL',
      message,
      scheduled,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Cancel streak alert (called when quests completed today) ──────
  Future<void> cancelStreakAlert() async {
    if (!_initialized) return;
    await _plugin.cancel(_streakId);
  }

  // ── Cancel return (called on every app open) ──────────────────────
  Future<void> cancelReturn() async {
    if (!_initialized) return;
    await _plugin.cancel(_returnId);
  }

  // ── Notification details ──────────────────────────────────────────
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Ежедневные напоминания от Системы',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // ── Settings helpers ──────────────────────────────────────────────
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value);
  }

  Future<TimeOfDay> getMorningTime() async {
    final prefs = await SharedPreferences.getInstance();
    return TimeOfDay(
      hour: prefs.getInt(_keyMorningHour) ?? 9,
      minute: prefs.getInt(_keyMorningMinute) ?? 0,
    );
  }

  Future<void> setMorningTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMorningHour, time.hour);
    await prefs.setInt(_keyMorningMinute, time.minute);
  }

  Future<bool> isStreakAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStreakAlert) ?? true;
  }

  Future<void> setStreakAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStreakAlert, value);
  }

  Future<bool> isReturnAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyReturnAlert) ?? true;
  }

  Future<void> setReturnAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReturnAlert, value);
  }
}
