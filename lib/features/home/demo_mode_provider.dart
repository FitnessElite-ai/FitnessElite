import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../agent/models/agent_memory.dart';
import '../agent/providers/agent_provider.dart';
import '../ai_coach/models/complete_fitness_profile.dart';
import '../ai_coach/models/fitness_preferences.dart';
import '../ai_coach/providers/ai_coach_provider.dart';
import '../health_assessment/domain/fitness_profile.dart';
import '../vision_assessment/models/vision_assessment.dart';
import '../vision_assessment/models/vision_insight.dart';
import '../workouts/models/workout_history_log.dart';
import '../workouts/providers/workout_session_provider.dart';

class DemoModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Default off
  }

  void toggleDemoMode(WidgetRef ref) {
    final nextState = !state;
    state = nextState;

    if (nextState) {
      // 1. Seed synthetic demo profile for Alex
      const demoHp = FitnessProfile(
        name: 'Alex Morgan (Demo)',
        age: 27,
        sex: 'Female',
        heightCm: 168.0,
        weightKg: 62.0,
        unitSystem: UnitSystem.metric,
        bmi: 22.0,
        bmiCategory: 'Normal weight',
        activityLevel: 'Active',
        primaryGoal: 'Build muscle & Tone',
        workoutAvailability: '30 min',
        workoutDays: '4 days',
        equipment: 'Dumbbells',
        sleepDuration: '8 hours',
        dietaryPreference: 'Flexitarian',
        preferredLanguage: 'en',
      );

      const demoPref = FitnessPreferences(
        primaryGoal: 'Build muscle & Tone',
        dailyTrainingTime: '30 minutes',
        preferredLocation: 'Home',
        experienceLevel: 'Intermediate',
        consistencyBarrier: 'Time',
        dietaryPreference: 'Flexitarian',
        additionalNotes: 'Synthetic Competition Profile',
      );

      final demoVision = VisionAssessment(
        id: 'vis_demo',
        isCompleted: true,
        insights: const [
          VisionInsight(
            category: 'POSTURE',
            title: 'Neutral Standing Alignment',
            description: 'Demo optical postural baseline',
            confidence: ConfidenceLevel.high,
            recommendation: 'Incorporate posture and core stability exercises',
          ),
        ],
        timestamp: DateTime.now(),
      );

      final demoComplete = CompleteFitnessProfile(
        healthProfile: demoHp,
        fitnessPreferences: demoPref,
        visionAssessment: demoVision,
        completedAt: DateTime.now(),
      );

      ref.read(conversationNotifierProvider.notifier).state =
          ref.read(conversationNotifierProvider).copyWith(
                completeProfile: demoComplete,
                isCompleted: true,
              );

      // 2. Seed synthetic 3-day history scenario (Day 1: 45 min workout, Day 2: Missed, Day 3: High fatigue)
      final historyRepo = ref.read(workoutHistoryRepositoryProvider);
      final demoLog = WorkoutHistoryLog(
        id: 'log_demo_1',
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        dayTitle: 'Upper Body Strength',
        focus: 'Chest, Back & Shoulders',
        durationMinutes: 45,
        exercisesCompleted: 5,
        setsCompleted: 15,
        feedbackRating: 'Very challenging',
      );
      historyRepo.saveWorkoutLog(demoLog);

      // 3. Seed synthetic agent memories
      final memoryService = ref.read(fitnessMemoryServiceProvider);
      memoryService.remember(AgentMemory(
        id: 'mem_demo_1',
        category: 'EXERCISE_PREFERENCE',
        value: 'Prefers 30-minute dumbbell home sessions',
        confidence: 0.95,
        source: 'user',
        createdAt: DateTime.now(),
      ));
      memoryService.remember(AgentMemory(
        id: 'mem_demo_2',
        category: 'ADHERENCE_PATTERN',
        value: 'Tends to skip sessions exceeding 40 minutes',
        confidence: 0.90,
        source: 'observation',
        createdAt: DateTime.now(),
      ));

      // 4. Trigger autonomous agent cycle
      ref.read(agentNotifierProvider.notifier).triggerAgentCycle();
    }
  }
}

final demoModeNotifierProvider = NotifierProvider<
    DemoModeNotifier, bool>(
  DemoModeNotifier.new,
);
