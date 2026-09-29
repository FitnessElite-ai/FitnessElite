import 'package:flutter/material.dart';
import 'local_storage_service.dart';

class WorkoutAlarmConfig {
  final bool isEnabled;
  final TimeOfDay alarmTime;
  final String label;

  const WorkoutAlarmConfig({
    this.isEnabled = true,
    this.alarmTime = const TimeOfDay(hour: 7, minute: 0),
    this.label = 'Daily Workout Alarm',
  });

  String get formattedTime {
    final hour = alarmTime.hourOfPeriod == 0 ? 12 : alarmTime.hourOfPeriod;
    final minute = alarmTime.minute.toString().padLeft(2, '0');
    final period = alarmTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  WorkoutAlarmConfig copyWith({
    bool? isEnabled,
    TimeOfDay? alarmTime,
    String? label,
  }) {
    return WorkoutAlarmConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      alarmTime: alarmTime ?? this.alarmTime,
      label: label ?? this.label,
    );
  }
}

/// Service managing lightweight, seamless daily workout alarms and audio/chime reminders.
class WorkoutAlarmService {
  static const String _keyAlarmEnabled = 'fe_workout_alarm_enabled';
  static const String _keyAlarmHour = 'fe_workout_alarm_hour';
  static const String _keyAlarmMinute = 'fe_workout_alarm_minute';

  final LocalStorageService _storage;

  WorkoutAlarmService(this._storage);

  WorkoutAlarmConfig getAlarmConfig() {
    final enabled = _storage.getString(_keyAlarmEnabled) != 'false';
    final hour = int.tryParse(_storage.getString(_keyAlarmHour) ?? '7') ?? 7;
    final minute = int.tryParse(_storage.getString(_keyAlarmMinute) ?? '0') ?? 0;

    return WorkoutAlarmConfig(
      isEnabled: enabled,
      alarmTime: TimeOfDay(hour: hour, minute: minute),
    );
  }

  Future<void> saveAlarmConfig(WorkoutAlarmConfig config) async {
    await _storage.setString(_keyAlarmEnabled, config.isEnabled ? 'true' : 'false');
    await _storage.setString(_keyAlarmHour, config.alarmTime.hour.toString());
    await _storage.setString(_keyAlarmMinute, config.alarmTime.minute.toString());
    debugPrint('[WorkoutAlarmService] Workout alarm updated: ${config.formattedTime} (Enabled: ${config.isEnabled})');
  }

  void triggerAlarmChime() {
    debugPrint('[WorkoutAlarmService] 🔔 CHIME ALERT: Time for your FitnessElite.ai workout session!');
  }
}
