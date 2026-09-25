import 'package:fitness_elite/app/app.dart';
import 'package:fitness_elite/app/theme/theme_provider.dart';
import 'package:fitness_elite/core/localization/app_localizations.dart';
import 'package:fitness_elite/core/services/ai_service.dart';
import 'package:fitness_elite/core/services/local_storage_service.dart';
import 'package:fitness_elite/core/services/persistence_providers.dart';
import 'package:fitness_elite/features/ai_coach/models/complete_fitness_profile.dart';
import 'package:fitness_elite/features/ai_coach/models/fitness_preferences.dart';
import 'package:fitness_elite/features/ai_coach/presentation/screens/ai_coach_screen.dart';
import 'package:fitness_elite/features/ai_coach/presentation/screens/plan_preview_screen.dart';
import 'package:fitness_elite/features/ai_coach/repositories/ai_coach_repository.dart';
import 'package:fitness_elite/features/ai_coach/services/mock_ai_coach_service.dart';
import 'package:fitness_elite/features/auth/auth_screen.dart';
import 'package:fitness_elite/features/auth/data/dev_auth_repository.dart';
import 'package:fitness_elite/features/auth/presentation/providers/auth_provider.dart';
import 'package:fitness_elite/features/health_assessment/data/fitness_profile_repository.dart';
import 'package:fitness_elite/features/health_assessment/domain/bmi_calculator.dart';
import 'package:fitness_elite/features/health_assessment/domain/fitness_profile.dart';
import 'package:fitness_elite/features/health_assessment/presentation/health_assessment_screen.dart';
import 'package:fitness_elite/features/language_selection/language_selection_screen.dart';
import 'package:fitness_elite/features/onboarding/onboarding_screen.dart';
import 'package:fitness_elite/shared/widgets/fitness_elite_logo.dart';
import 'package:fitness_elite/shared/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FitnessElite App Architecture Tests', () {
    testWidgets('App renders Splash screen on launch with FitnessEliteLogo', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
          ],
          child: const FitnessEliteApp(),
        ),
      );

      // Advance time for non-blocking splash transition
      await tester.pump(const Duration(milliseconds: 1200));

      // Verify app title logo branding and status are present
      expect(find.byType(FitnessEliteLogo), findsWidgets);
      expect(find.text('Your journey starts here.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('LanguageSelectionScreen displays languages and filters via search', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
          ],
          child: const MaterialApp(
            home: LanguageSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Fitness, in your language.'), findsOneWidget);
      expect(find.text('English'), findsWidgets);
      expect(find.text('Español'), findsOneWidget);

      // Scroll ListView to find Arabic
      await tester.scrollUntilVisible(
        find.text('العربية'),
        100,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('العربية'), findsOneWidget);

      // Search for Spanish
      await tester.enterText(find.byType(TextField), 'Spanish');
      await tester.pumpAndSettle();

      expect(find.text('Español'), findsOneWidget);
      expect(find.text('العربية'), findsNothing);
    });

    testWidgets('OnboardingScreen displays 3 pages with headlines and visuals', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
          ],
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Understand your body.'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('GlassCard renders correctly with child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: GlassCard(
              child: Text('Glass Content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Content'), findsOneWidget);
      expect(find.byType(GlassCard), findsOneWidget);
    });

    test('AppLocalizations supports 9 locales and Arabic RTL', () {
      final enLoc = AppLocalizations(const Locale('en'));
      expect(enLoc.appName, equals('FitnessElite.ai'));
      expect(enLoc.welcomeSubtitle, contains('Fitness Digital Twin'));
      expect(enLoc.journeyStartsHere, equals('Your journey starts here.'));
      expect(enLoc.isRtl, isFalse);

      final arLoc = AppLocalizations(const Locale('ar'));
      expect(arLoc.appName, equals('FitnessElite.ai'));
      expect(arLoc.isRtl, isTrue);

      final esLoc = AppLocalizations(const Locale('es'));
      expect(esLoc.getStarted, equals('Comenzar'));

      final hiLoc = AppLocalizations(const Locale('hi'));
      expect(hiLoc.getStarted, equals('शुरू करें'));
    });

    testWidgets('ThemeModeNotifier toggles theme state correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      expect(container.read(themeModeProvider), equals(ThemeMode.system));

      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));

      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      expect(container.read(themeModeProvider), equals(ThemeMode.light));
    });

    test('AiService initializes lazily and asynchronously', () async {
      final container = ProviderContainer();
      expect(container.read(aiServiceProvider).status, equals(AiServiceStatus.uninitialized));

      final future = container.read(aiServiceProvider.notifier).initializeLazily();
      expect(container.read(aiServiceProvider).status, equals(AiServiceStatus.initializing));

      await future;
      expect(container.read(aiServiceProvider).status, equals(AiServiceStatus.ready));
    });

    test('LocalStorageService persists language, onboarding and auth status', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      expect(storage.getLanguageCode(), equals('en'));
      expect(storage.isOnboardingCompleted(), isFalse);
      expect(storage.isAuthenticated(), isFalse);

      await storage.saveLanguageCode('es');
      await storage.setOnboardingCompleted(true);
      await storage.setAuthenticated(true);

      expect(storage.getLanguageCode(), equals('es'));
      expect(storage.isOnboardingCompleted(), isTrue);
      expect(storage.isAuthenticated(), isTrue);
    });

    testWidgets('OnboardingScreen navigates through pages correctly', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
          ],
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Page 1
      expect(find.text('Understand your body.'), findsOneWidget);

      // Tap Next to advance to Page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 2
      expect(find.text('Your plan. Powered by AI.'), findsOneWidget);

      // Tap Next to advance to Page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 3
      expect(find.text('Become your stronger self.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    test('AuthValidators validates name, email, password and confirm password', () {
      final l10n = AppLocalizations(const Locale('en'));

      expect(AuthValidators.validateName('', l10n), equals(l10n.validationNameRequired));
      expect(AuthValidators.validateName('Alex Morgan', l10n), isNull);

      expect(AuthValidators.validateEmail('invalid-email', l10n), equals(l10n.validationEmailInvalid));
      expect(AuthValidators.validateEmail('alex@example.com', l10n), isNull);

      expect(AuthValidators.validatePassword('short', l10n), equals(l10n.validationPasswordMin));
      expect(AuthValidators.validatePassword('password123', l10n), isNull);

      expect(AuthValidators.validateConfirmPassword('mismatch', 'password123', l10n), equals(l10n.validationPasswordMatch));
      expect(AuthValidators.validateConfirmPassword('password123', 'password123', l10n), isNull);
    });

    test('DevAuthRepository authenticates, persists session and signs out', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final repo = DevAuthRepository(storage);

      expect(repo.currentUser, isNull);

      final user = await repo.signInWithEmailAndPassword(
        email: 'test@fitnesselite.ai',
        password: 'password123',
      );

      expect(user.email, equals('test@fitnesselite.ai'));
      expect(storage.isAuthenticated(), isTrue);

      // Reloading from storage retains user
      final restoredRepo = DevAuthRepository(storage);
      expect(restoredRepo.currentUser?.email, equals('test@fitnesselite.ai'));

      await restoredRepo.signOut();
      expect(restoredRepo.currentUser, isNull);
      expect(storage.isAuthenticated(), isFalse);
    });

    testWidgets('AuthScreen renders Sign In form and switches to Create Account mode', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
          ],
          child: const MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome to FitnessElite.ai'), findsOneWidget);
      final toggleFinder = find.text("Don't have an account? Create Account");
      expect(toggleFinder, findsOneWidget);

      // Switch to Create Account mode
      await tester.ensureVisible(toggleFinder);
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });

    test('BmiCalculator calculates BMI and categories accurately', () {
      // 70 kg, 175 cm -> 22.9 (Normal weight)
      final bmi = BmiCalculator.calculateBmi(70.0, 175.0);
      expect(bmi, equals(22.9));
      expect(BmiCalculator.getCategoryName(bmi), equals('Normal weight'));

      // 95 kg, 175 cm -> 31.0 (Obesity)
      final obeseBmi = BmiCalculator.calculateBmi(95.0, 175.0);
      expect(obeseBmi, equals(31.0));
      expect(BmiCalculator.getCategoryName(obeseBmi), equals('Obesity'));

      // Unit Conversions
      final lbs = BmiCalculator.kgToLbs(70.0);
      expect(double.parse(lbs.toStringAsFixed(1)), equals(154.3));

      final kg = BmiCalculator.lbsToKg(154.3);
      expect(double.parse(kg.toStringAsFixed(1)), equals(70.0));

      final cm = BmiCalculator.ftInToCm(5, 9.0);
      expect(double.parse(cm.toStringAsFixed(1)), equals(175.3));

      final ftIn = BmiCalculator.cmToFtIn(175.26);
      expect(ftIn.feet, equals(5));
      expect(ftIn.inches, equals(9.0));
    });

    test('LocalFitnessProfileRepository persists FitnessProfile cleanly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final repo = LocalFitnessProfileRepository(storage);

      expect(repo.getFitnessProfile(), isNull);

      const profile = FitnessProfile(
        name: 'Alex Morgan',
        age: 28,
        sex: 'Female',
        heightCm: 168.0,
        weightKg: 62.0,
        unitSystem: UnitSystem.metric,
        bmi: 22.0,
        bmiCategory: 'Normal weight',
        activityLevel: 'Very Active',
        primaryGoal: 'Build muscle',
        workoutAvailability: '45-60 min',
        workoutDays: '4-5 days',
        equipment: 'Full Gym',
        sleepDuration: '7-8 hours',
        dietaryPreference: 'High Protein',
        preferredLanguage: 'en',
      );

      await repo.saveFitnessProfile(profile);

      final restored = repo.getFitnessProfile();
      expect(restored?.name, equals('Alex Morgan'));
      expect(restored?.bmi, equals(22.0));
      expect(restored?.primaryGoal, equals('Build muscle'));
    });

    testWidgets('HealthAssessmentScreen renders Step 1 Basic Information', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
          ],
          child: const MaterialApp(
            home: HealthAssessmentScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Step 1 of 5'), findsOneWidget);
      expect(find.text('Metric (cm / kg)'), findsOneWidget);
    });

    test('MockAICoachService generates contextual responses', () async {
      final service = MockAICoachService();

      final resTime = await service.generateResponse(
        userMessage: '30 minutes',
        conversation: [],
      );
      expect(resTime, contains('30 minutes'));

      final resTravel = await service.generateResponse(
        userMessage: 'I travel a lot',
        conversation: [],
      );
      expect(resTravel, contains('travel'));

      final resBeginner = await service.generateResponse(
        userMessage: 'Beginner',
        conversation: [],
      );
      expect(resBeginner, contains('building consistency'));
    });

    test('LocalAICoachRepository persists CompleteFitnessProfile', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final repo = LocalAICoachRepository(storage);

      expect(repo.getCompleteFitnessProfile(), isNull);
      expect(repo.isAiAssessmentCompleted(), isFalse);

      const healthProfile = FitnessProfile(
        name: 'Taylor Swift',
        age: 30,
        sex: 'Female',
        heightCm: 178.0,
        weightKg: 65.0,
        unitSystem: UnitSystem.metric,
        bmi: 20.5,
        bmiCategory: 'Normal weight',
        activityLevel: 'Active',
        primaryGoal: 'Build muscle',
        workoutAvailability: '30-45 min',
        workoutDays: '4-5 days',
        equipment: 'Dumbbells',
        sleepDuration: '7-8 hours',
        dietaryPreference: 'Vegetarian',
        preferredLanguage: 'en',
      );

      const preferences = FitnessPreferences(
        primaryGoal: 'Build muscle',
        dailyTrainingTime: '30 minutes',
        preferredLocation: 'Home',
        experienceLevel: 'Intermediate',
        consistencyBarrier: 'Work/studies',
        dietaryPreference: 'Vegetarian',
        additionalNotes: 'Low impact preferred',
      );

      final complete = CompleteFitnessProfile(
        healthProfile: healthProfile,
        fitnessPreferences: preferences,
        completedAt: DateTime.now(),
      );

      await repo.saveCompleteFitnessProfile(complete);

      expect(repo.isAiAssessmentCompleted(), isTrue);
      final restored = repo.getCompleteFitnessProfile();
      expect(restored?.healthProfile.name, equals('Taylor Swift'));
      expect(restored?.fitnessPreferences.dailyTrainingTime, equals('30 minutes'));
    });

    testWidgets('AICoachScreen renders AI welcome message and quick replies', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
          ],
          child: const MaterialApp(
            home: AICoachScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("What is your main goal right now?"), findsOneWidget);
      expect(find.text('Build muscle'), findsOneWidget);
      expect(find.text('Lose fat'), findsOneWidget);
    });

    testWidgets('PlanPreviewScreen renders preview sections and CTA', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
          ],
          child: const MaterialApp(
            home: PlanPreviewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your personalized plan is next.'), findsOneWidget);
      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.text('NUTRITION'), findsOneWidget);
      expect(find.text('RECOVERY'), findsOneWidget);
      expect(find.text('PROGRESS'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });
  });
}
