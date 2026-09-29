import '../../ai_coach/models/complete_fitness_profile.dart';
import '../../devices/models/device_fitness_data.dart';
import '../../fitness_engine/models/fitness_plan.dart';
import '../../fitness_engine/models/workout_day.dart';
import '../../workouts/models/workout_history_log.dart';
import 'agent_memory.dart';
import 'agent_observation.dart';

/// Aggregated, sanitized context provided to specialized agents.
class AgentContext {
  final CompleteFitnessProfile? profile;
  final FitnessPlan? currentPlan;
  final WorkoutDay? todayWorkout;
  final List<WorkoutHistoryLog> workoutHistory;
  final List<AgentMemory> memories;
  final List<AgentObservation> observations;
  final DeviceFitnessData? deviceData;

  const AgentContext({
    this.profile,
    this.currentPlan,
    this.todayWorkout,
    this.workoutHistory = const [],
    this.memories = const [],
    this.observations = const [],
    this.deviceData,
  });
}
