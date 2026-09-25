import 'package:fitness_elite/core/services/local_storage_service.dart';
import 'package:fitness_elite/core/services/persistence_providers.dart';
import 'package:fitness_elite/features/ai_coach/models/complete_fitness_profile.dart';
import 'package:fitness_elite/features/ai_coach/models/fitness_preferences.dart';
import 'package:fitness_elite/features/fitness_engine/models/fitness_goal.dart';
import 'package:fitness_elite/features/fitness_engine/models/fitness_plan.dart';
import 'package:fitness_elite/features/fitness_engine/models/nutrition_plan.dart';
import 'package:fitness_elite/features/fitness_engine/models/recovery_plan.dart';
import 'package:fitness_elite/features/fitness_engine/models/workout_plan.dart';
import 'package:fitness_elite/features/fitness_engine/presentation/screens/personalized_plan_screen.dart';
import 'package:fitness_elite/features/fitness_engine/presentation/screens/plan_generation_screen.dart';
import 'package:fitness_elite/features/fitness_engine/providers/fitness_engine_provider.dart';
import 'package:fitness_elite/features/fitness_engine/repositories/fitness_plan_repository.dart';
import 'package:fitness_elite/features/fitness_engine/services/exercise_library.dart';
import 'package:fitness_elite/features/fitness_engine/services/rule_based_fitness_engine.dart';
import 'package:fitness_elite/features/health_assessment/domain/fitness_profile.dart';
import 'package:fitness_elite/features/vision_assessment/models/vision_assessment.dart';
import 'package:fitness_elite/features/vision_assessment/models/vision_insight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Fitness Intelligence Engine Architecture & Unit Tests', () {
    test('ExerciseLibrary provides exercises across all major muscle groups & equipment', () {
      final catalog = ExerciseLibrary.catalog;
      expect(catalog.isNotEmpty, isTrue);

      final muscleGroups = catalog.map((e) => e.muscleGroup).toSet();
      expect(muscleGroups.contains('Chest'), isTrue);
      expect(muscleGroups.contains('Back'), isTrue);
      expect(muscleGroups.contains('Legs'), isTrue);
      expect(muscleGroups.contains('Core'), isTrue);
      expect(muscleGroups.contains('Mobility'), isTrue);

      final homeEx = ExerciseLibrary.filterExercises(
        equipmentPreference: 'Bodyweight',
        experienceLevel: 'Beginner',
      );
      expect(homeEx.every((e) => e.equipment == 'Bodyweight' || e.equipment == 'Dumbbells'), isTrue);
    });

    test('Scenario 1: Beginner + Home + 15 min + Lose Fat', () async {
      final engine = RuleBasedFitnessEngine();
      final now = DateTime.now();

      const hp = FitnessProfile(
        name: 'Alice',
        age: 28,
        sex: 'Female',
        heightCm: 165.0,
        weightKg: 68.0,
        unitSystem: UnitSystem.metric,
        bmi: 25.0,
        bmiCategory: 'Overweight',
        activityLevel: 'Lightly Active',
        primaryGoal: 'Lose fat',
        workoutAvailability: '15 min',
        workoutDays: '3 days',
        equipment: 'Bodyweight only',
        sleepDuration: '7 hours',
        dietaryPreference: 'Flexible',
        preferredLanguage: 'en',
      );

      const pref = FitnessPreferences(
        primaryGoal: 'Lose fat',
        dailyTrainingTime: '15 minutes',
        preferredLocation: 'Home',
        experienceLevel: 'Beginner',
        consistencyBarrier: 'Time',
        dietaryPreference: 'Flexible',
        additionalNotes: '',
      );

      final completeProfile = CompleteFitnessProfile(
        healthProfile: hp,
        fitnessPreferences: pref,
        completedAt: now,
      );

      final plan = await engine.generatePlan(profile: completeProfile);

      expect(plan.summary, contains('Alice'));
      expect(plan.summary, contains('Home'));
      expect(plan.summary, contains('15-minute'));
      expect(plan.primaryGoal, contains('Lose Fat'));
      expect(plan.nutritionPlan.dailyCalories, lessThan(2200));
      expect(plan.nutritionPlan.proteinGrams, greaterThan(80));

      final workoutDays = plan.weeklySchedule.where((d) => d.isWorkout);
      for (final day in workoutDays) {
        expect(day.durationMinutes, equals(15));
        expect(day.exercises.length, lessThanOrEqualTo(3));
      }
    });

    test('Scenario 2: Intermediate + Gym + 60 min + Build Muscle', () async {
      final engine = RuleBasedFitnessEngine();
      final now = DateTime.now();

      const hp = FitnessProfile(
        name: 'Bob',
        age: 24,
        sex: 'Male',
        heightCm: 182.0,
        weightKg: 78.0,
        unitSystem: UnitSystem.metric,
        bmi: 23.5,
        bmiCategory: 'Normal weight',
        activityLevel: 'Very Active',
        primaryGoal: 'Build muscle',
        workoutAvailability: '60 min',
        workoutDays: '5 days',
        equipment: 'Full Gym',
        sleepDuration: '8 hours',
        dietaryPreference: 'Non-vegetarian',
        preferredLanguage: 'en',
      );

      const pref = FitnessPreferences(
        primaryGoal: 'Build muscle',
        dailyTrainingTime: '60 minutes',
        preferredLocation: 'Gym',
        experienceLevel: 'Intermediate',
        consistencyBarrier: 'Work',
        dietaryPreference: 'Non-vegetarian',
        additionalNotes: '',
      );

      final completeProfile = CompleteFitnessProfile(
        healthProfile: hp,
        fitnessPreferences: pref,
        completedAt: now,
      );

      final plan = await engine.generatePlan(profile: completeProfile);

      expect(plan.primaryGoal, contains('Build Muscle'));
      expect(plan.summary, contains('Gym'));
      expect(plan.nutritionPlan.dailyCalories, greaterThan(2300));
      expect(plan.nutritionPlan.proteinGrams, greaterThanOrEqualTo(140));

      final workoutDays = plan.weeklySchedule.where((d) => d.isWorkout);
      for (final day in workoutDays) {
        expect(day.durationMinutes, equals(60));
        expect(day.exercises.length, greaterThanOrEqualTo(3));
      }
    });

    test('Scenario 3: Vegetarian user meal generation', () async {
      final engine = RuleBasedFitnessEngine();
      final now = DateTime.now();

      const hp = FitnessProfile(
        name: 'Priya',
        age: 29,
        sex: 'Female',
        heightCm: 160.0,
        weightKg: 55.0,
        unitSystem: UnitSystem.metric,
        bmi: 21.5,
        bmiCategory: 'Normal weight',
        activityLevel: 'Moderately Active',
        primaryGoal: 'Improve overall fitness',
        workoutAvailability: '30 min',
        workoutDays: '4 days',
        equipment: 'Dumbbells',
        sleepDuration: '7-8 hours',
        dietaryPreference: 'Vegetarian',
        preferredLanguage: 'en',
      );

      const pref = FitnessPreferences(
        primaryGoal: 'Improve overall fitness',
        dailyTrainingTime: '30 minutes',
        preferredLocation: 'Home',
        experienceLevel: 'Beginner',
        consistencyBarrier: 'Motivation',
        dietaryPreference: 'Vegetarian',
        additionalNotes: '',
      );

      final plan = await engine.generatePlan(
        profile: CompleteFitnessProfile(
          healthProfile: hp,
          fitnessPreferences: pref,
          completedAt: now,
        ),
      );

      expect(plan.nutritionPlan.dietaryPreference, equals('Vegetarian'));
      expect(plan.nutritionPlan.meals.isNotEmpty, isTrue);

      for (final meal in plan.nutritionPlan.meals) {
        final text = '${meal.name} ${meal.description} ${meal.dietaryTags.join(" ")}'.toLowerCase();
        expect(text, isNot(contains('chicken')));
        expect(text, isNot(contains('beef')));
        expect(text, isNot(contains('fish')));
      }
    });

    test('Scenario 4: Vegan user meal generation', () async {
      final engine = RuleBasedFitnessEngine();
      final now = DateTime.now();

      const hp = FitnessProfile(
        name: 'Liam',
        age: 32,
        sex: 'Male',
        heightCm: 175.0,
        weightKg: 70.0,
        unitSystem: UnitSystem.metric,
        bmi: 22.9,
        bmiCategory: 'Normal weight',
        activityLevel: 'Moderately Active',
        primaryGoal: 'Improve endurance',
        workoutAvailability: '45 min',
        workoutDays: '4 days',
        equipment: 'Bodyweight',
        sleepDuration: '8 hours',
        dietaryPreference: 'Vegan',
        preferredLanguage: 'en',
      );

      const pref = FitnessPreferences(
        primaryGoal: 'Improve endurance',
        dailyTrainingTime: '45 minutes',
        preferredLocation: 'Outdoors',
        experienceLevel: 'Intermediate',
        consistencyBarrier: 'Weather',
        dietaryPreference: 'Vegan',
        additionalNotes: '',
      );

      final plan = await engine.generatePlan(
        profile: CompleteFitnessProfile(
          healthProfile: hp,
          fitnessPreferences: pref,
          completedAt: now,
        ),
      );

      expect(plan.nutritionPlan.dietaryPreference, equals('Vegan'));
      for (final meal in plan.nutritionPlan.meals) {
        final text = '${meal.name} ${meal.description} ${meal.dietaryTags.join(" ")}'.toLowerCase();
        expect(text, isNot(contains('egg')));
        expect(text, isNot(contains('curd')));
        expect(text, isNot(contains('paneer')));
        expect(text, isNot(contains('meat')));
      }
    });

    test('Scenario 5 & 6: VisionAssessment integration adds mobility & posture emphasis', () async {
      final engine = RuleBasedFitnessEngine();
      final now = DateTime.now();

      const hp = FitnessProfile(
        name: 'Chris',
        age: 30,
        sex: 'Male',
        heightCm: 178.0,
        weightKg: 76.0,
        unitSystem: UnitSystem.metric,
        bmi: 24.0,
        bmiCategory: 'Normal weight',
        activityLevel: 'Moderately Active',
        primaryGoal: 'Improve overall fitness',
        workoutAvailability: '30 min',
        workoutDays: '3 days',
        equipment: 'Dumbbells',
        sleepDuration: '7 hours',
        dietaryPreference: 'Flexible',
        preferredLanguage: 'en',
      );

      const pref = FitnessPreferences(
        primaryGoal: 'Improve overall fitness',
        dailyTrainingTime: '30 minutes',
        preferredLocation: 'Home',
        experienceLevel: 'Beginner',
        consistencyBarrier: 'Work',
        dietaryPreference: 'Flexible',
        additionalNotes: '',
      );

      // Scenario 5: Without Vision
      final planWithout = await engine.generatePlan(
        profile: CompleteFitnessProfile(
          healthProfile: hp,
          fitnessPreferences: pref,
          completedAt: now,
        ),
      );

      // Scenario 6: With Vision
      final vision = VisionAssessment(
        id: 'vis_test',
        isCompleted: true,
        insights: const [
          VisionInsight(
            category: 'POSTURE',
            title: 'Spine Alignment',
            description: 'Postural baseline focus',
            confidence: ConfidenceLevel.moderate,
            recommendation: 'Incorporate posture & mobility exercises',
          ),
        ],
        timestamp: now,
      );

      final planWith = await engine.generatePlan(
        profile: CompleteFitnessProfile(
          healthProfile: hp,
          fitnessPreferences: pref,
          visionAssessment: vision,
          completedAt: now,
        ),
      );

      expect(planWith.summary, contains('visual baseline insights'));
      expect(planWith.recoveryPlan.mobilityRecommendation, contains('posture'));
      expect(planWithout.summary, isNot(contains('visual baseline insights')));
    });

    test('Scenario 7 & 8: Missing or incomplete optional fields handling fallback', () async {
      final engine = RuleBasedFitnessEngine();

      const incompleteHp = FitnessProfile(
        name: '',
        age: 0,
        sex: '',
        heightCm: 0,
        weightKg: 0,
        unitSystem: UnitSystem.metric,
        bmi: 0,
        bmiCategory: '',
        activityLevel: '',
        primaryGoal: '',
        workoutAvailability: '',
        workoutDays: '',
        equipment: '',
        sleepDuration: '',
        dietaryPreference: '',
        preferredLanguage: 'en',
      );

      const incompletePref = FitnessPreferences(
        primaryGoal: '',
        dailyTrainingTime: '',
        preferredLocation: '',
        experienceLevel: '',
        consistencyBarrier: '',
        dietaryPreference: '',
        additionalNotes: '',
      );

      final plan = await engine.generatePlan(
        profile: CompleteFitnessProfile(
          healthProfile: incompleteHp,
          fitnessPreferences: incompletePref,
          completedAt: DateTime.now(),
        ),
      );

      expect(plan.id.isNotEmpty, isTrue);
      expect(plan.nutritionPlan.dailyCalories, greaterThan(1200));
      expect(plan.workoutPlan.days.isNotEmpty, isTrue);
    });

    test('FitnessPlan serialization and LocalFitnessPlanRepository persistence', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final repo = LocalFitnessPlanRepository(storage);

      expect(repo.getCurrentPlan(), isNull);
      expect(repo.hasActivePlan(), isFalse);

      final plan = FitnessPlan(
        id: 'plan_unit_test',
        createdAt: DateTime.now(),
        durationWeeks: 4,
        summary: 'Unit test plan summary.',
        primaryGoal: 'Build Muscle',
        targetMetrics: const [
          FitnessGoal(
            metric: 'Consistency',
            baseline: '0',
            target: '4',
            unit: 'sessions',
            timeframe: '4 weeks',
          ),
        ],
        weeklySchedule: const [],
        workoutPlan: const WorkoutPlan(
          title: 'Title',
          description: 'Desc',
          weeklyFrequency: 3,
        ),
        nutritionPlan: const NutritionPlan(
          dailyCalories: 2200,
          proteinGrams: 140,
          carbsGrams: 240,
          fatGrams: 70,
          hydrationLiters: 3.0,
          dietaryPreference: 'Flexible',
          guidanceNotes: 'Notes',
        ),
        recoveryPlan: const RecoveryPlan(
          sleepTargetHours: '8 hours',
          restDaysPerWeek: 2,
          hydrationGuidance: '3.0 L',
          mobilityRecommendation: 'Stretching',
          recoveryNotes: '',
        ),
      );

      await repo.savePlan(plan);
      expect(repo.hasActivePlan(), isTrue);

      final restored = repo.getCurrentPlan();
      expect(restored?.id, equals('plan_unit_test'));
      expect(restored?.primaryGoal, equals('Build Muscle'));

      await repo.clearPlan();
      expect(repo.getCurrentPlan(), isNull);
      expect(repo.hasActivePlan(), isFalse);
    });

    testWidgets('PlanGenerationScreen renders processing layout', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
          ],
          child: const MaterialApp(
            home: PlanGenerationScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PlanGenerationScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('PersonalizedPlanScreen renders full plan sections', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(localStorageService),
        ],
      );

      final engineNotifier = container.read(fitnessEngineNotifierProvider.notifier);

      const hp = FitnessProfile(
        name: 'Sarah',
        age: 27,
        sex: 'Female',
        heightCm: 168.0,
        weightKg: 60.0,
        unitSystem: UnitSystem.metric,
        bmi: 21.3,
        bmiCategory: 'Normal weight',
        activityLevel: 'Active',
        primaryGoal: 'Build muscle',
        workoutAvailability: '30 min',
        workoutDays: '4 days',
        equipment: 'Dumbbells',
        sleepDuration: '8 hours',
        dietaryPreference: 'Vegetarian',
        preferredLanguage: 'en',
      );

      const pref = FitnessPreferences(
        primaryGoal: 'Build muscle',
        dailyTrainingTime: '30 minutes',
        preferredLocation: 'Home',
        experienceLevel: 'Intermediate',
        consistencyBarrier: 'Time',
        dietaryPreference: 'Vegetarian',
        additionalNotes: '',
      );

      final profile = CompleteFitnessProfile(
        healthProfile: hp,
        fitnessPreferences: pref,
        completedAt: DateTime.now(),
      );

      await engineNotifier.generatePlanForProfile(profile);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PersonalizedPlanScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Your Fitness Plan'), findsOneWidget);
      expect(find.text('PERSONALIZED FOR YOU'), findsOneWidget);
      expect(find.text('WORKOUT PROGRAM'), findsOneWidget);
      expect(find.text('NUTRITION GUIDANCE'), findsOneWidget);
      expect(find.text('RECOVERY & SLEEP'), findsOneWidget);
      expect(find.text('MEASURABLE TARGETS'), findsOneWidget);
      expect(find.text('Start My Plan'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
