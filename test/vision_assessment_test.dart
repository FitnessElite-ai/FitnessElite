import 'package:fitness_elite/core/services/local_storage_service.dart';
import 'package:fitness_elite/core/services/persistence_providers.dart';
import 'package:fitness_elite/features/ai_coach/models/complete_fitness_profile.dart';
import 'package:fitness_elite/features/ai_coach/models/fitness_preferences.dart';
import 'package:fitness_elite/features/ai_coach/presentation/screens/plan_preview_screen.dart';
import 'package:fitness_elite/features/health_assessment/domain/fitness_profile.dart';
import 'package:fitness_elite/features/vision_assessment/models/vision_assessment.dart';
import 'package:fitness_elite/features/vision_assessment/models/vision_insight.dart';
import 'package:fitness_elite/features/vision_assessment/models/vision_photo.dart';
import 'package:fitness_elite/features/vision_assessment/presentation/screens/vision_intro_screen.dart';
import 'package:fitness_elite/features/vision_assessment/presentation/screens/vision_results_screen.dart';
import 'package:fitness_elite/features/vision_assessment/presentation/widgets/photo_capture_card.dart';
import 'package:fitness_elite/features/vision_assessment/providers/vision_assessment_provider.dart';
import 'package:fitness_elite/features/vision_assessment/repositories/vision_assessment_repository.dart';
import 'package:fitness_elite/features/vision_assessment/services/mock_vision_assessment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Vision Assessment Architecture & Unit Tests', () {
    test('VisionPhoto model supports getters and JSON serialization', () {
      final now = DateTime.now();
      final photo = VisionPhoto(
        id: 'photo_01',
        filePath: '/tmp/front.jpg',
        type: PhotoType.front,
        timestamp: now,
      );

      expect(photo.localPath, equals('/tmp/front.jpg'));
      expect(photo.createdAt, equals(now));
      expect(photo.type, equals(PhotoType.front));

      final jsonStr = photo.toJson();
      final restored = VisionPhoto.fromJson(jsonStr);

      expect(restored.id, equals('photo_01'));
      expect(restored.localPath, equals('/tmp/front.jpg'));
      expect(restored.type, equals(PhotoType.front));
    });

    test('VisionInsight confidence labels and serialization', () {
      const insight = VisionInsight(
        category: 'POSTURE',
        title: 'Neutral Standing Alignment',
        description: 'Visual posture baseline.',
        confidence: ConfidenceLevel.moderate,
        recommendation: 'Keep neutral spine posture.',
      );

      expect(insight.confidenceLabel, equals('Moderate confidence'));

      final jsonStr = insight.toJson();
      final restored = VisionInsight.fromJson(jsonStr);

      expect(restored.category, equals('POSTURE'));
      expect(restored.confidence, equals(ConfidenceLevel.moderate));
    });

    test('VisionAssessment supports optional photos and getters', () {
      final now = DateTime.now();
      final front = VisionPhoto(
        id: 'front',
        filePath: '/tmp/front.jpg',
        type: PhotoType.front,
        timestamp: now,
      );

      final assessment = VisionAssessment(
        id: 'vis_123',
        frontPhoto: front,
        sidePhoto: null,
        backPhoto: null,
        isCompleted: true,
        insights: const [
          VisionInsight(
            category: 'POSTURE',
            title: 'Title',
            description: 'Desc',
            confidence: ConfidenceLevel.high,
            recommendation: 'Rec',
          ),
        ],
        timestamp: now,
      );

      expect(assessment.completed, isTrue);
      expect(assessment.createdAt, equals(now));
      expect(assessment.photos.length, equals(1));
      expect(assessment.sidePhoto, isNull);
      expect(assessment.backPhoto, isNull);

      final restored = VisionAssessment.fromJson(assessment.toJson());
      expect(restored.completed, isTrue);
      expect(restored.frontPhoto?.localPath, equals('/tmp/front.jpg'));
      expect(restored.sidePhoto, isNull);
    });

    test('MockVisionAssessmentService returns DEMO structured insights without fake precise body measurements', () async {
      final service = MockVisionAssessmentService();
      final now = DateTime.now();

      final front = VisionPhoto(
        id: 'f1',
        filePath: '/tmp/front.jpg',
        type: PhotoType.front,
        timestamp: now,
      );

      const healthProfile = FitnessProfile(
        name: 'Jordan',
        age: 26,
        sex: 'Male',
        heightCm: 180.0,
        weightKg: 75.0,
        unitSystem: UnitSystem.metric,
        bmi: 23.1,
        bmiCategory: 'Normal weight',
        activityLevel: 'Moderately Active',
        primaryGoal: 'Build muscle',
        workoutAvailability: '30 min',
        workoutDays: '3 days',
        equipment: 'Dumbbells',
        sleepDuration: '8 hours',
        dietaryPreference: 'Flexitarian',
        preferredLanguage: 'en',
      );

      const preferences = FitnessPreferences(
        primaryGoal: 'Build muscle',
        dailyTrainingTime: '30 min',
        preferredLocation: 'Home',
        experienceLevel: 'Beginner',
        consistencyBarrier: 'Time',
        dietaryPreference: 'Flexitarian',
        additionalNotes: '',
      );

      final completeProfile = CompleteFitnessProfile(
        healthProfile: healthProfile,
        fitnessPreferences: preferences,
        completedAt: now,
      );

      final result = await service.analyze(
        photos: [front],
        profile: completeProfile,
      );

      expect(result.completed, isTrue);
      expect(result.insights.isNotEmpty, isTrue);

      // Verify no fake precise measurements
      for (final insight in result.insights) {
        final text = '${insight.title} ${insight.description} ${insight.recommendation}'.toLowerCase();
        expect(text, isNot(contains('body fat %')));
        expect(text, isNot(contains('exact body fat')));
        expect(text, isNot(contains('disease')));
        expect(text, isNot(contains('diagnosis')));
      }
    });

    test('CompleteFitnessProfile integrates VisionAssessment optionally', () {
      final now = DateTime.now();
      const healthProfile = FitnessProfile(
        name: 'Sam',
        age: 25,
        sex: 'Female',
        heightCm: 165.0,
        weightKg: 58.0,
        unitSystem: UnitSystem.metric,
        bmi: 21.3,
        bmiCategory: 'Normal weight',
        activityLevel: 'Lightly Active',
        primaryGoal: 'Improve fitness',
        workoutAvailability: '30 min',
        workoutDays: '3 days',
        equipment: 'Bodyweight',
        sleepDuration: '7-8 hours',
        dietaryPreference: 'Anything',
        preferredLanguage: 'en',
      );

      const preferences = FitnessPreferences(
        primaryGoal: 'Improve fitness',
        dailyTrainingTime: '30 min',
        preferredLocation: 'Home',
        experienceLevel: 'Beginner',
        consistencyBarrier: 'Motivation',
        dietaryPreference: 'Anything',
        additionalNotes: '',
      );

      // 1. Skipped Vision Assessment
      final profileSkipped = CompleteFitnessProfile(
        healthProfile: healthProfile,
        fitnessPreferences: preferences,
        visionAssessment: null,
        completedAt: now,
      );

      expect(profileSkipped.visionAssessment, isNull);

      // 2. Completed Vision Assessment
      final assessment = VisionAssessment(
        id: 'vis_1',
        isCompleted: true,
        timestamp: now,
      );

      final profileWithVision = CompleteFitnessProfile(
        healthProfile: healthProfile,
        fitnessPreferences: preferences,
        visionAssessment: assessment,
        completedAt: now,
      );

      expect(profileWithVision.visionAssessment, isNotNull);
      expect(profileWithVision.visionAssessment?.completed, isTrue);
    });

    test('LocalVisionAssessmentRepository gets, saves, and clears assessment', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final repo = LocalVisionAssessmentRepository(storage);

      expect(repo.getVisionAssessment(), isNull);
      expect(repo.isVisionAssessmentCompleted(), isFalse);

      final assessment = VisionAssessment(
        id: 'v123',
        isCompleted: true,
        timestamp: DateTime.now(),
      );

      await repo.saveVisionAssessment(assessment);
      expect(repo.isVisionAssessmentCompleted(), isTrue);

      final restored = repo.getVisionAssessment();
      expect(restored?.id, equals('v123'));

      await repo.clearVisionAssessment();
      expect(repo.getVisionAssessment(), isNull);
      expect(repo.isVisionAssessmentCompleted(), isFalse);
    });

    testWidgets('VisionIntroScreen renders title, benefit cards, disclaimer and buttons', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
          ],
          child: const MaterialApp(
            home: VisionIntroScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('See your fitness from a new perspective.'), findsOneWidget);
      expect(find.text('VISUAL BASELINE'), findsOneWidget);
      expect(find.text('BODY BALANCE'), findsOneWidget);
      expect(find.text('PERSONALIZATION'), findsOneWidget);
      expect(find.text('Start Assessment'), findsOneWidget);
      expect(find.text('Skip for now'), findsWidgets);
    });

    testWidgets('PhotoCaptureCard renders options and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoCaptureCard(
              title: 'Front Photo (Recommended)',
              subtitle: 'Full body pose',
              type: PhotoType.front,
              photo: null,
              onPhotoCaptured: (_) {},
              onPhotoRemoved: () {},
            ),
          ),
        ),
      );

      expect(find.text('Front Photo (Recommended)'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
    });

    testWidgets('VisionResultsScreen displays insights and preview badge', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs);

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(localStorageService),
        ],
      );

      final notifier = container.read(visionAssessmentNotifierProvider.notifier);
      notifier.setFrontPhoto('/tmp/front.jpg');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: VisionResultsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your Visual Fitness Insights'), findsOneWidget);
      expect(find.text('AI Vision Preview'), findsOneWidget);
      expect(find.text('Continue to Plan Preview'), findsOneWidget);
    });

    testWidgets('PlanPreviewScreen displays profile description reflecting Vision Assessment status', (WidgetTester tester) async {
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

      expect(find.text('Your profile includes your health data, goals, and lifestyle preferences.'), findsOneWidget);
      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.text('NUTRITION'), findsOneWidget);
      expect(find.text('RECOVERY'), findsOneWidget);
      expect(find.text('PROGRESS'), findsOneWidget);
    });
  });
}
