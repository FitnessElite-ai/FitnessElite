import '../models/complete_fitness_profile.dart';
import '../../fitness_engine/models/fitness_plan.dart';
import '../../workouts/models/workout_history_log.dart';

/// Context-building abstraction supplying sanitized, relevant context to AICoachService
/// without passing raw sensitive personal data or full biometrics.
class AICoachContextBuilder {
  static String buildContextSummary({
    CompleteFitnessProfile? profile,
    FitnessPlan? currentPlan,
    List<WorkoutHistoryLog>? history,
  }) {
    final goal = profile?.fitnessPreferences.primaryGoal ??
        profile?.healthProfile.primaryGoal ??
        'General Fitness';
    final level = profile?.fitnessPreferences.experienceLevel ?? 'Beginner';
    final location = profile?.fitnessPreferences.preferredLocation ?? 'Home';
    final sessionMin = profile?.fitnessPreferences.dailyTrainingTime ?? '30 min';

    final calories = currentPlan?.nutritionPlan.dailyCalories ?? 2000;
    final protein = currentPlan?.nutritionPlan.proteinGrams ?? 120;
    final diet = currentPlan?.nutritionPlan.dietaryPreference ?? 'Flexible';

    final completedSessions = history?.length ?? 0;
    final lastFeedback = history?.isNotEmpty == true ? history!.last.feedbackRating : 'None';

    return 'Goal: $goal | Level: $level | Location: $location | Session: $sessionMin | Calories: ${calories}kcal | Protein: ${protein}g ($diet) | Completed: $completedSessions sessions | Last Feedback: $lastFeedback';
  }
}
