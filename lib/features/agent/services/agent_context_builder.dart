import '../../ai_coach/models/complete_fitness_profile.dart';
import '../../fitness_engine/models/fitness_plan.dart';
import '../../fitness_engine/models/workout_day.dart';
import '../../workouts/models/workout_history_log.dart';
import '../models/agent_context.dart';
import '../models/agent_memory.dart';
import '../models/agent_observation.dart';

class AgentContextBuilder {
  static AgentContext buildContext({
    CompleteFitnessProfile? profile,
    FitnessPlan? currentPlan,
    List<WorkoutHistoryLog> history = const [],
    List<AgentMemory> memories = const [],
    List<AgentObservation> observations = const [],
  }) {
    WorkoutDay? todayWorkout;
    if (currentPlan != null && currentPlan.weeklySchedule.isNotEmpty) {
      final todayIndex = (DateTime.now().weekday - 1) % currentPlan.weeklySchedule.length;
      todayWorkout = currentPlan.weeklySchedule[todayIndex];
    }

    return AgentContext(
      profile: profile,
      currentPlan: currentPlan,
      todayWorkout: todayWorkout,
      workoutHistory: history,
      memories: memories,
      observations: observations,
    );
  }
}
