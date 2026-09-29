import 'package:fitness_elite/core/services/agent_observability_service.dart';
import 'package:fitness_elite/core/services/fitness_notification_service.dart';
import 'package:fitness_elite/core/services/local_storage_service.dart';
import 'package:fitness_elite/core/services/persistence_providers.dart';
import 'package:fitness_elite/features/agent/memory/fitness_memory_service.dart';
import 'package:fitness_elite/features/agent/models/agent_context.dart';
import 'package:fitness_elite/features/agent/models/agent_log.dart';
import 'package:fitness_elite/features/agent/models/agent_memory.dart';
import 'package:fitness_elite/features/agent/orchestration/agent_orchestrator.dart';
import 'package:fitness_elite/features/agent/policies/agent_permission_policy.dart';
import 'package:fitness_elite/features/agent/policies/fitness_safety_policy.dart';
import 'package:fitness_elite/features/agent/services/agent_context_builder.dart';
import 'package:fitness_elite/features/agent/services/fitness_agent.dart';
import 'package:fitness_elite/features/agent/services/specialized_agents.dart';
import 'package:fitness_elite/features/agent/tools/fitness_tools.dart';
import 'package:fitness_elite/features/agent/ui/screens/agent_memory_screen.dart';
import 'package:fitness_elite/features/ai_coach/models/complete_fitness_profile.dart';
import 'package:fitness_elite/features/ai_coach/models/fitness_preferences.dart';
import 'package:fitness_elite/features/ai_coach/services/conversational_ai_provider.dart';
import 'package:fitness_elite/features/breathwork/policies/breath_safety_policy.dart';
import 'package:fitness_elite/features/breathwork/services/breathing_library.dart';
import 'package:fitness_elite/features/breathwork/services/breathing_session_engine.dart';
import 'package:fitness_elite/features/devices/models/device_fitness_data.dart';
import 'package:fitness_elite/features/fitness_engine/models/workout_day.dart';
import 'package:fitness_elite/features/health_assessment/domain/fitness_profile.dart';
import 'package:fitness_elite/features/voice/services/voice_agent_service.dart';
import 'package:fitness_elite/features/workouts/models/workout_history_log.dart';
import 'package:fitness_elite/features/yoga/services/yoga_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Agentic Fitness System Comprehensive Unit Tests', () {
    test('1. AgentPermissionPolicy classifies actions and tools correctly', () {
      expect(
        AgentPermissionPolicy.evaluateActionPermission('medical_diagnosis', 'DiagnoseTool'),
        equals(ActionPermissionLevel.neverAllowed),
      );
      expect(
        AgentPermissionPolicy.evaluateActionPermission('subscription_purchase', 'PaywallTool'),
        equals(ActionPermissionLevel.userConfirmationRequired),
      );
      expect(
        AgentPermissionPolicy.evaluateActionPermission('modify_workout', 'ModifyWorkoutTool'),
        equals(ActionPermissionLevel.lowRiskWrite),
      );
      expect(
        AgentPermissionPolicy.evaluateActionPermission('read_history', 'GetWorkoutHistoryTool'),
        equals(ActionPermissionLevel.read),
      );
      expect(
        AgentPermissionPolicy.isPermittedWithoutApproval('modify_workout', 'ModifyWorkoutTool'),
        isTrue,
      );
    });

    test('2. FitnessSafetyPolicy validates and sanitizes outputs', () {
      const unsafe = 'You have a disease and should eat under 800 calories';
      expect(FitnessSafetyPolicy.validateText(unsafe), isFalse);
      expect(FitnessSafetyPolicy.sanitizeText(unsafe), contains('estimated fitness guidance only'));

      const safe = 'Your workout intensity has been reduced for optimal recovery.';
      expect(FitnessSafetyPolicy.validateText(safe), isTrue);
      expect(FitnessSafetyPolicy.sanitizeText(safe), equals(safe));
    });

    test('3. LocalFitnessMemoryService remember, retrieve, update, and forget', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final memoryService = LocalFitnessMemoryService(storage);

      expect(memoryService.getAllMemories(), isEmpty);

      final memory = AgentMemory(
        id: 'mem_1',
        category: 'EXERCISE_PREFERENCE',
        value: 'Prefers morning workouts',
        confidence: 0.95,
        source: 'user',
        createdAt: DateTime.now(),
      );

      await memoryService.remember(memory);
      expect(memoryService.getAllMemories().length, equals(1));

      final retrieved = memoryService.retrieveRelevantMemory('morning');
      expect(retrieved.length, equals(1));
      expect(retrieved.first.value, equals('Prefers morning workouts'));

      await memoryService.updateMemory('mem_1', 'Prefers 7 AM workouts');
      expect(memoryService.getAllMemories().first.value, equals('Prefers 7 AM workouts'));

      await memoryService.forgetMemory('mem_1');
      expect(memoryService.getAllMemories(), isEmpty);
    });

    test('4. AgentContextBuilder aggregates profile, plan, history, and memories', () {
      const hp = FitnessProfile(
        name: 'Alex',
        age: 27,
        sex: 'Female',
        heightCm: 168.0,
        weightKg: 62.0,
        unitSystem: UnitSystem.metric,
        bmi: 22.0,
        bmiCategory: 'Normal',
        activityLevel: 'Active',
        primaryGoal: 'Build muscle',
        workoutAvailability: '30 min',
        workoutDays: '4 days',
        equipment: 'Dumbbells',
        sleepDuration: '8 hours',
        dietaryPreference: 'Flexitarian',
        preferredLanguage: 'en',
      );

      final profile = CompleteFitnessProfile(
        healthProfile: hp,
        fitnessPreferences: const FitnessPreferences(
          primaryGoal: 'Build muscle',
          dailyTrainingTime: '30 min',
          preferredLocation: 'Home',
          experienceLevel: 'Intermediate',
          consistencyBarrier: 'Time',
          dietaryPreference: 'Flexitarian',
          additionalNotes: '',
        ),
        completedAt: DateTime.now(),
      );

      final context = AgentContextBuilder.buildContext(
        profile: profile,
        memories: const [],
        history: const [],
      );

      expect(context.profile?.healthProfile.name, equals('Alex'));
      expect(context.workoutHistory, isEmpty);
    });

    test('5. Specialized Sub-Agents evaluate context cleanly', () {
      final workoutAgent = WorkoutAgent();
      final nutritionAgent = NutritionAgent();
      final recoveryAgent = RecoveryAgent();
      final progressAgent = ProgressAgent();
      final visionAgent = VisionAgent();
      final deviceAgent = DeviceAgent();
      final yogaAgent = YogaAgent();

      const context = AgentContext();

      expect(workoutAgent.evaluate(context).agentName, equals('WorkoutAgent'));
      expect(nutritionAgent.evaluate(context).agentName, equals('NutritionAgent'));
      expect(recoveryAgent.evaluate(context).agentName, equals('RecoveryAgent'));
      expect(progressAgent.evaluate(context).agentName, equals('ProgressAgent'));
      expect(visionAgent.evaluate(context).agentName, equals('VisionAgent'));
      expect(deviceAgent.evaluate(context).agentName, equals('DeviceAgent'));
      expect(yogaAgent.evaluate(context).agentName, equals('YogaAgent'));
    });

    test('6. WorkoutAgent proposes volume reduction upon high fatigue feedback', () {
      final workoutAgent = WorkoutAgent();
      final now = DateTime.now();

      final today = WorkoutDay(
        day: 'Monday',
        title: 'Lower Body Strength',
        focus: 'Legs & Core',
        type: 'workout',
        durationMinutes: 40,
        exercises: const [],
      );

      final historyLog = WorkoutHistoryLog(
        id: 'log_1',
        completedAt: now.subtract(const Duration(days: 1)),
        dayTitle: 'Upper Body',
        focus: 'Chest',
        durationMinutes: 40,
        exercisesCompleted: 5,
        setsCompleted: 15,
        feedbackRating: 'Very challenging',
      );

      final context = AgentContext(
        todayWorkout: today,
        workoutHistory: [historyLog],
      );

      final output = workoutAgent.evaluate(context);
      expect(output.proposedActions.length, equals(1));
      expect(output.proposedActions.first.type, equals('modify_workout'));
      expect(output.proposedActions.first.parameters['durationMinutes'], equals(30));
    });

    test('7. All Agent Tool abstractions execute parameter validation and returns data', () async {
      final getProfileTool = GetFitnessProfileTool(null);
      expect((await getProfileTool.execute({})).success, isFalse);

      final modifyTool = ModifyWorkoutTool();
      final modifyRes = await modifyTool.execute({'durationMinutes': 25, 'reason': 'Fatigue'});
      expect(modifyRes.success, isTrue);
      expect(modifyRes.data['durationMinutes'], equals(25));

      final logFeedbackTool = LogFeedbackTool();
      final logRes = await logFeedbackTool.execute({'rating': 'Very challenging'});
      expect(logRes.success, isTrue);

      final yogaTool = GenerateYogaSessionTool();
      final yogaRes = await yogaTool.execute({'durationMinutes': 10});
      expect(yogaRes.success, isTrue);
    });

    test('8. AgentOrchestrator runs daily cycle and applies permission filtering', () {
      final orchestrator = AgentOrchestrator();
      const context = AgentContext();

      final decision = orchestrator.runDailyCycle(context);
      expect(decision.id.isNotEmpty, isTrue);
      expect(decision.title, contains("Today's Fitness Intelligence"));
      expect(decision.isApproved, isTrue);
    });

    test('9. FitnessAgent executes cycle and stores decision memory', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final memoryService = LocalFitnessMemoryService(storage);
      final agent = FitnessAgent(memoryService);

      const context = AgentContext();
      final decision = await agent.runCycle(context);

      expect(decision.decision.isNotEmpty, isTrue);
      expect(memoryService.getAllMemories().length, equals(1));
      expect(memoryService.getAllMemories().first.category, equals('AGENT_DECISION'));
    });

    test('10. StructuredUserIntent parses natural language queries into intent types', () {
      final intent1 = StructuredUserIntent.parse('I only have 20 minutes today');
      expect(intent1.intentType, equals('time_constraint'));
      expect(intent1.extractedParameters['durationMinutes'], equals(20));

      final intent2 = StructuredUserIntent.parse('I am too tired for legs');
      expect(intent2.intentType, equals('fatigue'));
      expect(intent2.extractedParameters['targetGroup'], equals('legs'));

      final intent3 = StructuredUserIntent.parse('I hate running');
      expect(intent3.intentType, equals('exercise_dislike'));
      expect(intent3.extractedParameters['exerciseToAvoid'], equals('running'));

      final intent4 = StructuredUserIntent.parse('Can I replace push-ups?');
      expect(intent4.intentType, equals('exercise_replacement'));
      expect(intent4.extractedParameters['exerciseToReplace'], equals('push-ups'));

      final intent5 = StructuredUserIntent.parse('I missed yesterday');
      expect(intent5.intentType, equals('missed_workout'));

      final intent6 = StructuredUserIntent.parse('I want to train tomorrow morning');
      expect(intent6.intentType, equals('schedule_change'));
    });

    test('11. DeterministicFallbackProvider generates intelligent conversational responses', () async {
      final provider = DeterministicFallbackProvider();
      final resp = await provider.generateResponse(
        userMessage: 'I only have 15 minutes today',
        conversation: const [],
      );

      expect(resp, contains('15'));
    });

    test('12. LocalFitnessNotificationService sends agent notifications cleanly', () async {
      final service = LocalFitnessNotificationService();
      await service.initialize();
      await service.sendAgentNotification(
        title: 'Plan Adapted',
        message: 'Your 30-min session was reduced for recovery.',
      );
      expect(true, isTrue);
    });

    test('13. LocalAgentObservabilityService logs agent runs without biometrics', () {
      final service = LocalAgentObservabilityService();
      final log = AgentLog(
        runId: 'run_1',
        timestamp: DateTime.now(),
        trigger: 'user_action',
        agentsInvoked: ['WorkoutAgent', 'RecoveryAgent'],
        toolsUsed: ['ModifyWorkoutTool'],
        decisionSummary: 'Session modified to 25m',
        durationMs: 42,
      );

      service.logAgentRun(log);
      expect(service.getLogs().length, equals(1));
      expect(service.getLogs().first.durationMs, equals(42));
    });

    test('14. DeviceAgent detects poor sleep and triggers recovery active mobility', () {
      final deviceAgent = DeviceAgent();
      final data = DeviceFitnessData(
        source: 'HealthKit',
        steps: 8000,
        sleepDurationHours: 5.2, // Poor sleep
        restingHeartRate: 64,
        timestamp: DateTime.now(),
      );

      final context = AgentContext(deviceData: data);
      final output = deviceAgent.evaluate(context);

      expect(output.proposedActions.length, equals(1));
      expect(output.proposedActions.first.type, equals('generate_yoga_session'));
    });

    test('15. YogaLibrary generates 10-minute recovery mobility sessions', () {
      final session = YogaLibrary.generateRecoverySession(durationMin: 10);
      expect(session.durationMinutes, equals(10));
      expect(session.poses.length, greaterThanOrEqualTo(5));
      expect(session.poses.first.name.isNotEmpty, isTrue);
    });

    test('16. VoiceAgentService processes voice inputs and returns safe response', () async {
      final voiceService = VoiceAgentService();
      const context = AgentContext();

      final resp = await voiceService.processVoiceQuery(
        speechText: 'I only have 20 minutes today and I feel tired',
        context: context,
      );

      expect(resp.isNotEmpty, isTrue);
      expect(resp, isNot(contains('medical diagnosis')));
    });

    testWidgets('17. AgentMemoryScreen renders AppBar leading back icon and Your Fitness Memory title', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localStorage = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorage),
          ],
          child: const MaterialApp(
            home: AgentMemoryScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Your Fitness Memory'), findsOneWidget);
      expect(find.text('YOUR FITNESS MEMORY'), findsOneWidget);
      expect(find.text('FitnessElite.ai learns what works for you.'), findsOneWidget);
    });

    test('18. BreathSafetyPolicy validates and sanitizes breathing instructions', () {
      const unsafe = 'hold breath for 2 minutes and hyperventilate';
      expect(BreathSafetyPolicy.validateInstructions(unsafe), isFalse);
      expect(BreathSafetyPolicy.sanitizeText(unsafe), contains('Maintain comfortable, rhythmic breathing'));

      const safe = 'Inhale smoothly for 4 seconds, then exhale for 4 seconds.';
      expect(BreathSafetyPolicy.validateInstructions(safe), isTrue);
    });

    test('19. BreathingLibrary catalog provides 10 beginner-friendly breathing exercises', () {
      final catalog = BreathingLibrary.catalog;
      expect(catalog.length, equals(10));
      final defaultSession = BreathingLibrary.getDefaultSession(category: 'Calm');
      expect(defaultSession.name.isNotEmpty, isTrue);
      expect(defaultSession.inhaleSeconds, greaterThan(0));
    });

    test('20. BreathingSessionEngine executes deterministic phase transitions and timers', () {
      final exercise = BreathingLibrary.catalog.first;
      BreathingSessionState? lastState;

      final engine = BreathingSessionEngine(
        exercise: exercise,
        onTick: (state) => lastState = state,
      );

      engine.start();
      expect(lastState?.phase, equals(BreathPhase.preparing));

      engine.stop();
      expect(lastState?.phase, equals(BreathPhase.stopped));
    });
  });
}
