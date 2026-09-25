import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_storage_service.dart';

/// Provider for LocalStorageService instance (overridden in ProviderScope in main.dart)
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be initialized with SharedPreferences');
});

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
