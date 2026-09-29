import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_storage_service.dart';
import 'workout_alarm_service.dart';

/// Provider for LocalStorageService instance (overridden in ProviderScope in main.dart)
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be initialized with SharedPreferences');
});

final workoutAlarmServiceProvider = Provider<WorkoutAlarmService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return WorkoutAlarmService(storage);
});

class WorkoutAlarmNotifier extends Notifier<WorkoutAlarmConfig> {
  late final WorkoutAlarmService _service;

  @override
  WorkoutAlarmConfig build() {
    _service = ref.watch(workoutAlarmServiceProvider);
    return _service.getAlarmConfig();
  }

  Future<void> updateTime(TimeOfDay time) async {
    final newConfig = state.copyWith(alarmTime: time, isEnabled: true);
    state = newConfig;
    await _service.saveAlarmConfig(newConfig);
  }

  Future<void> toggleEnabled(bool enabled) async {
    final newConfig = state.copyWith(isEnabled: enabled);
    state = newConfig;
    await _service.saveAlarmConfig(newConfig);
  }
}

final workoutAlarmNotifierProvider = NotifierProvider<WorkoutAlarmNotifier, WorkoutAlarmConfig>(
  WorkoutAlarmNotifier.new,
);

/// Riverpod Notifier for managing app Locale state & persistence
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final storage = ref.watch(localStorageServiceProvider);
    final code = storage.getLanguageCode();
    return Locale(code);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveLanguageCode(languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

/// Riverpod Notifier for managing onboarding completion state
class OnboardingStateNotifier extends Notifier<bool> {
  @override
  bool build() {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.isOnboardingCompleted();
  }

  Future<void> completeOnboarding() async {
    state = true;
    final storage = ref.read(localStorageServiceProvider);
    await storage.setOnboardingCompleted(true);
  }

  Future<void> resetOnboarding() async {
    state = false;
    final storage = ref.read(localStorageServiceProvider);
    await storage.setOnboardingCompleted(false);
  }
}

final onboardingStateProvider =
    NotifierProvider<OnboardingStateNotifier, bool>(
  OnboardingStateNotifier.new,
);
