import 'agent_tool.dart';
import '../../ai_coach/models/complete_fitness_profile.dart';
import '../../devices/models/device_fitness_data.dart';
import '../../fitness_engine/models/fitness_plan.dart';
import '../../fitness_engine/models/workout_day.dart';
import '../../weather/models/weather_fitness_data.dart';
import '../../workouts/models/workout_history_log.dart';

/// 1. GetFitnessProfileTool
class GetFitnessProfileTool extends AgentTool {
  final CompleteFitnessProfile? profile;
  GetFitnessProfileTool(this.profile);

  @override
  String get name => 'GetFitnessProfileTool';
  @override
  String get description => 'Retrieves user biometric profile and baseline targets.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    if (profile == null) {
      return const AgentToolResult(success: false, output: 'No profile found.');
    }
    return AgentToolResult(
      success: true,
      output: 'Profile for ${profile!.healthProfile.name}, goal: ${profile!.fitnessPreferences.primaryGoal}',
      data: profile!.toMap(),
    );
  }
}

/// 2. GetCurrentPlanTool
class GetCurrentPlanTool extends AgentTool {
  final FitnessPlan? plan;
  GetCurrentPlanTool(this.plan);

  @override
  String get name => 'GetCurrentPlanTool';
  @override
  String get description => 'Retrieves active personalized fitness plan and schedule.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    if (plan == null) {
      return const AgentToolResult(success: false, output: 'No active plan.');
    }
    return AgentToolResult(
      success: true,
      output: 'Active plan: ${plan!.summary}',
      data: plan!.toMap(),
    );
  }
}

/// 3. GetTodayWorkoutTool
class GetTodayWorkoutTool extends AgentTool {
  final WorkoutDay? todayWorkout;
  GetTodayWorkoutTool(this.todayWorkout);

  @override
  String get name => 'GetTodayWorkoutTool';
  @override
  String get description => "Retrieves today's scheduled workout session details.";
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    if (todayWorkout == null) {
      return const AgentToolResult(success: false, output: "No workout scheduled for today.");
    }
    return AgentToolResult(
      success: true,
      output: "Today's workout: ${todayWorkout!.title} (${todayWorkout!.durationMinutes} min)",
      data: todayWorkout!.toMap(),
    );
  }
}

/// 4. GetRecentProgressTool
class GetRecentProgressTool extends AgentTool {
  final List<WorkoutHistoryLog> history;
  GetRecentProgressTool(this.history);

  @override
  String get name => 'GetRecentProgressTool';
  @override
  String get description => 'Calculates streak, completion rates, and progress metrics.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final completedCount = history.length;
    final totalDuration = history.fold<int>(0, (sum, h) => sum + h.durationMinutes);

    return AgentToolResult(
      success: true,
      output: 'Completed $completedCount total sessions ($totalDuration total minutes).',
      data: {
        'completedCount': completedCount,
        'totalMinutes': totalDuration,
      },
    );
  }
}

/// 5. GetWorkoutHistoryTool
class GetWorkoutHistoryTool extends AgentTool {
  final List<WorkoutHistoryLog> history;
  GetWorkoutHistoryTool(this.history);

  @override
  String get name => 'GetWorkoutHistoryTool';
  @override
  String get description => 'Retrieves recent completed workout logs and feedback ratings.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    return AgentToolResult(
      success: true,
      output: '${history.length} completed sessions logged.',
      data: {'logs': history.map((e) => e.toMap()).toList()},
    );
  }
}

/// 6. GetNutritionContextTool
class GetNutritionContextTool extends AgentTool {
  final FitnessPlan? plan;
  GetNutritionContextTool(this.plan);

  @override
  String get name => 'GetNutritionContextTool';
  @override
  String get description => 'Retrieves macro targets, dietary preferences, and meal guidance.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final nutrition = plan?.nutritionPlan;
    if (nutrition == null) {
      return const AgentToolResult(success: false, output: 'No nutrition targets active.');
    }
    return AgentToolResult(
      success: true,
      output: 'Target: ${nutrition.dailyCalories} kcal, ${nutrition.proteinGrams}g Protein (${nutrition.dietaryPreference}).',
      data: nutrition.toMap(),
    );
  }
}

/// 7. GetRecoveryContextTool
class GetRecoveryContextTool extends AgentTool {
  final FitnessPlan? plan;
  GetRecoveryContextTool(this.plan);

  @override
  String get name => 'GetRecoveryContextTool';
  @override
  String get description => 'Retrieves recovery status, sleep target, and mobility guidance.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final rec = plan?.recoveryPlan;
    if (rec == null) {
      return const AgentToolResult(success: false, output: 'No recovery targets active.');
    }
    return AgentToolResult(
      success: true,
      output: 'Sleep target: ${rec.sleepTargetHours}, Hydration: ${rec.hydrationGuidance}',
      data: rec.toMap(),
    );
  }
}

/// 8. GetUserPreferencesTool
class GetUserPreferencesTool extends AgentTool {
  final CompleteFitnessProfile? profile;
  GetUserPreferencesTool(this.profile);

  @override
  String get name => 'GetUserPreferencesTool';
  @override
  String get description => 'Retrieves user location, time availability, equipment, and dietary preferences.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    if (profile == null) {
      return const AgentToolResult(success: false, output: 'No user preferences found.');
    }
    final prefs = profile!.fitnessPreferences;
    return AgentToolResult(
      success: true,
      output: 'Training time: ${prefs.dailyTrainingTime}, Location: ${prefs.preferredLocation}, Diet: ${prefs.dietaryPreference}',
      data: prefs.toMap(),
    );
  }
}

/// 9. GetVisionInsightsTool
class GetVisionInsightsTool extends AgentTool {
  final CompleteFitnessProfile? profile;
  GetVisionInsightsTool(this.profile);

  @override
  String get name => 'GetVisionInsightsTool';
  @override
  String get description => 'Retrieves optical posture and form assessment insights.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final vision = profile?.visionAssessment;
    if (vision == null || !vision.completed) {
      return const AgentToolResult(success: false, output: 'No vision assessment available.');
    }
    return AgentToolResult(
      success: true,
      output: '${vision.insights.length} optical vision assessment insights retrieved.',
      data: vision.toMap(),
    );
  }
}

/// 10. GenerateWorkoutTool
class GenerateWorkoutTool extends AgentTool {
  GenerateWorkoutTool();

  @override
  String get name => 'GenerateWorkoutTool';
  @override
  String get description => 'Generates a custom workout session matching time and equipment parameters.';
  @override
  bool get isReadOnly => false;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final title = parameters['title'] as String? ?? 'Custom Adaptive Workout';
    final duration = (parameters['durationMinutes'] as num?)?.toInt() ?? 30;

    return AgentToolResult(
      success: true,
      output: 'Generated $duration-min workout: $title.',
      data: {
        'title': title,
        'durationMinutes': duration,
        'generatedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}

/// 11. ModifyWorkoutTool
class ModifyWorkoutTool extends AgentTool {
  ModifyWorkoutTool();

  @override
  String get name => 'ModifyWorkoutTool';
  @override
  String get description => 'Modifies duration or exercise list of a workout day based on fatigue/time constraints.';
  @override
  bool get isReadOnly => false;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final sessionMin = (parameters['durationMinutes'] as num?)?.toInt() ?? 25;
    final reason = parameters['reason'] as String? ?? 'Adapted for recovery';

    return AgentToolResult(
      success: true,
      output: 'Workout session modified to $sessionMin minutes ($reason).',
      data: {'durationMinutes': sessionMin, 'reason': reason},
    );
  }
}

/// 12. GenerateNutritionGuidanceTool
class GenerateNutritionGuidanceTool extends AgentTool {
  GenerateNutritionGuidanceTool();

  @override
  String get name => 'GenerateNutritionGuidanceTool';
  @override
  String get description => 'Generates targeted nutrition focus and meal adjustments based on workout intensity.';
  @override
  bool get isReadOnly => false;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final focus = parameters['focus'] as String? ?? 'Protein & Hydration Focus';
    return AgentToolResult(
      success: true,
      output: 'Nutrition guidance generated: $focus.',
      data: {'focus': focus},
    );
  }
}

/// 13. UpdateGoalTool
class UpdateGoalTool extends AgentTool {
  UpdateGoalTool();

  @override
  String get name => 'UpdateGoalTool';
  @override
  String get description => 'Updates active non-medical fitness goals and target milestones.';
  @override
  bool get isReadOnly => false;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final newGoal = parameters['primaryGoal'] as String?;
    if (newGoal == null || newGoal.isEmpty) {
      return const AgentToolResult(success: false, output: 'Invalid primary goal provided.');
    }
    return AgentToolResult(
      success: true,
      output: 'Fitness goal updated to: $newGoal.',
      data: {'primaryGoal': newGoal},
    );
  }
}

/// 14. LogWorkoutTool
class LogWorkoutTool extends AgentTool {
  LogWorkoutTool();

  @override
  String get name => 'LogWorkoutTool';
  @override
  String get description => 'Logs completed workout session performance details.';
  @override
  bool get isReadOnly => false;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final title = parameters['workoutTitle'] as String? ?? 'Session';
    final duration = (parameters['durationMinutes'] as num?)?.toInt() ?? 30;

    return AgentToolResult(
      success: true,
      output: 'Logged workout session: $title ($duration min).',
      data: {'workoutTitle': title, 'durationMinutes': duration},
    );
  }
}

/// 15. LogFeedbackTool
class LogFeedbackTool extends AgentTool {
  LogFeedbackTool();

  @override
  String get name => 'LogFeedbackTool';
  @override
  String get description => 'Logs subjective fatigue and exertion feedback from completed workout.';
  @override
  bool get isReadOnly => false;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final rating = parameters['rating'] as String? ?? 'Optimal';
    return AgentToolResult(
      success: true,
      output: 'Logged session feedback: $rating.',
      data: {'rating': rating},
    );
  }
}

/// 16. CreateRecoveryPlanTool
class CreateRecoveryPlanTool extends AgentTool {
  CreateRecoveryPlanTool();

  @override
  String get name => 'CreateRecoveryPlanTool';
  @override
  String get description => 'Generates active recovery and mobility protocol for fatigue management.';
  @override
  bool get isReadOnly => false;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final protocol = parameters['protocol'] as String? ?? '15-min Postural Mobility & Breathing Protocol';
    return AgentToolResult(
      success: true,
      output: 'Created recovery plan: $protocol.',
      data: {'protocol': protocol},
    );
  }
}

/// 17. GetDeviceDataTool
class GetDeviceDataTool extends AgentTool {
  final DeviceFitnessData? data;
  GetDeviceDataTool(this.data);

  @override
  String get name => 'GetDeviceDataTool';
  @override
  String get description => 'Retrieves wearable signals including steps, sleep hours, and resting heart rate.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    if (data == null) {
      return const AgentToolResult(success: false, output: 'No wearable device connected.');
    }
    return AgentToolResult(
      success: true,
      output: 'Device (${data!.source}): ${data!.steps} steps, ${data!.sleepDurationHours} hrs sleep, ${data!.restingHeartRate} bpm resting HR.',
      data: data!.toMap(),
    );
  }
}

/// 18. GetWearableSignalsTool
class GetWearableSignalsTool extends AgentTool {
  final DeviceFitnessData? data;
  GetWearableSignalsTool(this.data);

  @override
  String get name => 'GetWearableSignalsTool';
  @override
  String get description => 'Evaluates recovery signals (sleep deficit, elevated resting HR) from wearable devices.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    if (data == null) {
      return const AgentToolResult(success: false, output: 'No wearable signals active.');
    }
    final poorSleep = data!.hasPoorSleepSignal;
    return AgentToolResult(
      success: true,
      output: poorSleep ? 'Wearable signal: Short sleep detected.' : 'Wearable signals optimal.',
      data: {'poorSleep': poorSleep, 'sleepHours': data!.sleepDurationHours},
    );
  }
}

/// 19. GenerateYogaSessionTool
class GenerateYogaSessionTool extends AgentTool {
  GenerateYogaSessionTool();

  @override
  String get name => 'GenerateYogaSessionTool';
  @override
  String get description => 'Generates a restorative Yoga & Mobility session for active recovery.';
  @override
  bool get isReadOnly => false;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    final duration = (parameters['durationMinutes'] as num?)?.toInt() ?? 10;
    return AgentToolResult(
      success: true,
      output: 'Generated $duration-min Recovery Yoga & Mobility Flow.',
      data: {'durationMinutes': duration, 'category': 'Recovery Yoga'},
    );
  }
}

/// 20. GetYogaPreferencesTool
class GetYogaPreferencesTool extends AgentTool {
  GetYogaPreferencesTool();

  @override
  String get name => 'GetYogaPreferencesTool';
  @override
  String get description => 'Retrieves user mobility preferences and restorative focus.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    return const AgentToolResult(
      success: true,
      output: 'Yoga Preference: Recovery & Post-workout mobility focus.',
      data: {'preference': 'Recovery & Post-workout mobility'},
    );
  }
}

/// 21. GetWeatherContextTool
class GetWeatherContextTool extends AgentTool {
  final WeatherFitnessData? weather;
  GetWeatherContextTool(this.weather);

  @override
  String get name => 'GetWeatherContextTool';
  @override
  String get description => 'Retrieves location-based temperature, weather conditions, and environmental alerts.';
  @override
  bool get isReadOnly => true;

  @override
  Future<AgentToolResult> execute(Map<String, dynamic> parameters) async {
    if (weather == null) {
      return const AgentToolResult(success: false, output: 'No location weather signals active.');
    }
    return AgentToolResult(
      success: true,
      output: 'Location Weather (${weather!.cityName}): ${weather!.condition}, ${weather!.temperatureCelsius.toInt()}°C.',
      data: weather!.toMap(),
    );
  }
}
