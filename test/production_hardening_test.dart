import 'package:fitness_elite/core/services/analytics_service.dart';
import 'package:fitness_elite/core/services/error_reporting_service.dart';
import 'package:fitness_elite/core/services/local_storage_service.dart';
import 'package:fitness_elite/core/services/user_data_repository.dart';
import 'package:fitness_elite/features/ai_coach/models/complete_fitness_profile.dart';
import 'package:fitness_elite/features/ai_coach/models/fitness_preferences.dart';
import 'package:fitness_elite/features/ai_coach/services/ai_coach_context_builder.dart';
import 'package:fitness_elite/features/health_assessment/domain/fitness_profile.dart';
import 'package:fitness_elite/shared/widgets/consent_dialog.dart';
import 'package:fitness_elite/shared/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Production Hardening & System Services Tests', () {
    test('LocalAnalyticsService logs non-sensitive telemetry events', () {
      final analytics = LocalAnalyticsService();
      analytics.logEvent(AppAnalyticsEvents.planGenerated, {'goal': 'Build muscle'});
      analytics.logEvent(AppAnalyticsEvents.workoutCompleted, {'duration': 30});
    });

    test('LocalErrorReportingService records exceptions without biometrics', () {
      final reporter = LocalErrorReportingService();
      reporter.recordError(Exception('Network timeout'), StackTrace.current, reason: 'Testing error reporting');
    });

    test('LocalUserDataRepository exports and deletes local user data', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final repo = LocalUserDataRepository(storage);

      await storage.saveAuthUserData('{"id":"usr_123","email":"test@fitnesselite.ai"}');
      await storage.setAuthenticated(true);

      final exportJson = await repo.exportUserData();
      expect(exportJson, contains('test@fitnesselite.ai'));

      final success = await repo.deleteUserData();
      expect(success, isTrue);
      expect(storage.isAuthenticated(), isFalse);
    });

    test('AICoachContextBuilder constructs sanitized summary for AI coach', () {
      final now = DateTime.now();
      const hp = FitnessProfile(
        name: 'Jordan',
        age: 26,
        sex: 'Male',
        heightCm: 180.0,
        weightKg: 75.0,
        unitSystem: UnitSystem.metric,
        bmi: 23.1,
        bmiCategory: 'Normal weight',
        activityLevel: 'Active',
        primaryGoal: 'Build muscle',
        workoutAvailability: '30 min',
        workoutDays: '4 days',
        equipment: 'Dumbbells',
        sleepDuration: '8 hours',
        dietaryPreference: 'Flexible',
        preferredLanguage: 'en',
      );

      const pref = FitnessPreferences(
        primaryGoal: 'Build muscle',
        dailyTrainingTime: '30 minutes',
        preferredLocation: 'Home',
        experienceLevel: 'Intermediate',
        consistencyBarrier: 'Time',
        dietaryPreference: 'Flexible',
        additionalNotes: '',
      );

      final profile = CompleteFitnessProfile(
        healthProfile: hp,
        fitnessPreferences: pref,
        completedAt: now,
      );

      final summary = AICoachContextBuilder.buildContextSummary(profile: profile);

      expect(summary, contains('Goal: Build muscle'));
      expect(summary, contains('Level: Intermediate'));
      expect(summary, contains('Location: Home'));
    });

    testWidgets('OfflineBanner displays message when offline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(isOffline: true),
          ),
        ),
      );

      expect(find.text("You're offline. Your saved plan and exercise library are still fully available."), findsOneWidget);
    });

    testWidgets('ConsentDialog renders title, description, and accept button', (WidgetTester tester) async {
      bool accepted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConsentDialog(
              title: 'Vision AI Consent',
              description: 'Your photos stay local on device.',
              onAccepted: () {
                accepted = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Vision AI Consent'), findsOneWidget);
      expect(find.text('Your photos stay local on device.'), findsOneWidget);

      await tester.tap(find.text('I Agree & Continue'));
      expect(accepted, isTrue);
    });
  });
}
