import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/persistence_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

/// Root Application Widget for FitnessElite.ai.
/// Configures Material 3, dynamic ThemeMode, Locale, GoRouter, and Localization.
class FitnessEliteApp extends ConsumerWidget {
  const FitnessEliteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: FitnessEliteTheme.lightTheme,
      darkTheme: FitnessEliteTheme.darkTheme,
      locale: locale,
      routerConfig: appRouter,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
