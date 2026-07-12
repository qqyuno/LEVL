import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'notification_service.dart';

part 'notification_provider.g.dart';

/// Settings state for notifications UI.
class NotificationSettings {
  final bool enabled;
  final TimeOfDay morningTime;
  final bool streakAlert;
  final bool returnAlert;

  const NotificationSettings({
    this.enabled = true,
    this.morningTime = const TimeOfDay(hour: 9, minute: 0),
    this.streakAlert = true,
    this.returnAlert = true,
  });

  NotificationSettings copyWith({
    bool? enabled,
    TimeOfDay? morningTime,
    bool? streakAlert,
    bool? returnAlert,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      morningTime: morningTime ?? this.morningTime,
      streakAlert: streakAlert ?? this.streakAlert,
      returnAlert: returnAlert ?? this.returnAlert,
    );
  }
}

@Riverpod(keepAlive: true)
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  final _service = NotificationService.instance;

  @override
  Future<NotificationSettings> build() async {
    final enabled = await _service.isEnabled();
    final morningTime = await _service.getMorningTime();
    final streakAlert = await _service.isStreakAlertEnabled();
    final returnAlert = await _service.isReturnAlertEnabled();

    return NotificationSettings(
      enabled: enabled,
      morningTime: morningTime,
      streakAlert: streakAlert,
      returnAlert: returnAlert,
    );
  }

  Future<void> setEnabled(bool value) async {
    var nextValue = value;

    if (value) {
      try {
        await _service.init();
        nextValue = await _service.requestPermission();
      } catch (_) {
        nextValue = false;
      }
    }

    await _service.setEnabled(nextValue);
    state = AsyncData(state.requireValue.copyWith(enabled: nextValue));
  }

  Future<void> setMorningTime(TimeOfDay time) async {
    await _service.setMorningTime(time);
    state = AsyncData(state.requireValue.copyWith(morningTime: time));
  }

  Future<void> setStreakAlert(bool value) async {
    await _service.setStreakAlert(value);
    state = AsyncData(state.requireValue.copyWith(streakAlert: value));
  }

  Future<void> setReturnAlert(bool value) async {
    await _service.setReturnAlert(value);
    state = AsyncData(state.requireValue.copyWith(returnAlert: value));
  }
}
