import '../models/agent_action.dart';
import '../models/agent_context.dart';

class AgentOutput {
  final String agentName;
  final String summary;
  final List<AgentAction> proposedActions;
  final Map<String, dynamic> metadata;

  const AgentOutput({
    required this.agentName,
    required this.summary,
    this.proposedActions = const [],
    this.metadata = const {},
  });
}

/// Workout Sub-Agent handling session adaptations, duration compression, and progression.
class WorkoutAgent {
  AgentOutput evaluate(AgentContext context) {
    final history = context.workoutHistory;
    final today = context.todayWorkout;

    if (today == null) {
      return const AgentOutput(
        agentName: 'WorkoutAgent',
        summary: 'No active session scheduled today.',
      );
    }

    // Check recent feedback signals
    bool recentFatigue = false;
    if (history.isNotEmpty) {
      final lastRating = history.last.feedbackRating.toLowerCase();
      if (lastRating.contains('very challenging') || lastRating.contains('difficult')) {
        recentFatigue = true;
      }
    }

    if (recentFatigue) {
      return AgentOutput(
        agentName: 'WorkoutAgent',
        summary: 'Recent session rated very challenging. Recommending a 25% volume reduction for today.',
        proposedActions: [
          AgentAction(
            id: 'act_reduce_vol_${DateTime.now().millisecondsSinceEpoch}',
            type: 'modify_workout',
            description: 'Reduce today session duration from ${today.durationMinutes}m to ${(today.durationMinutes * 0.75).round()}m',
            targetTool: 'ModifyWorkoutTool',
            parameters: {
              'durationMinutes': (today.durationMinutes * 0.75).round(),
              'reason': 'High exertion feedback in previous session',
            },
          ),
        ],
      );
    }

    return AgentOutput(
      agentName: 'WorkoutAgent',
      summary: 'Today session: ${today.title} (${today.durationMinutes} min). Session intensity optimal.',
    );
  }
}

/// Nutrition Sub-Agent handling macro targets and meal recommendations.
class NutritionAgent {
  AgentOutput evaluate(AgentContext context) {
    final nutrition = context.currentPlan?.nutritionPlan;
    if (nutrition == null) {
      return const AgentOutput(
        agentName: 'NutritionAgent',
        summary: 'No active nutrition plan.',
      );
    }

    return AgentOutput(
      agentName: 'NutritionAgent',
      summary: 'Target: ${nutrition.dailyCalories} kcal, ${nutrition.proteinGrams}g Protein (${nutrition.dietaryPreference}).',
    );
  }
}

/// Recovery Sub-Agent monitoring sleep, hydration, and mobility protocols.
class RecoveryAgent {
  AgentOutput evaluate(AgentContext context) {
    final rec = context.currentPlan?.recoveryPlan;
    return AgentOutput(
      agentName: 'RecoveryAgent',
      summary: 'Sleep Target: ${rec?.sleepTargetHours ?? "7-8 hours"}. Hydration: ${rec?.hydrationGuidance ?? "2.5 L"}.',
    );
  }
}

/// Progress Sub-Agent analyzing consistency streaks and milestones.
class ProgressAgent {
  AgentOutput evaluate(AgentContext context) {
    final completed = context.workoutHistory.length;
    return AgentOutput(
      agentName: 'ProgressAgent',
      summary: 'Completed $completed total training sessions.',
      metadata: {'completedWorkouts': completed},
    );
  }
}

/// Coach Sub-Agent providing user-facing explanations and conversational assistance.
class CoachAgent {
  AgentOutput evaluate(AgentContext context, String userQuery) {
    return AgentOutput(
      agentName: 'CoachAgent',
      summary: 'AI Coach context ready for query: "$userQuery"',
    );
  }
}

/// Vision Sub-Agent evaluating optical assessment signals and posture cues.
/// Complies with strict safety rules: never diagnoses disease or claims exact body fat/muscle mass.
class VisionAgent {
  AgentOutput evaluate(AgentContext context) {
    final vision = context.profile?.visionAssessment;
    if (vision == null || !vision.completed || vision.insights.isEmpty) {
      return const AgentOutput(
        agentName: 'VisionAgent',
        summary: 'No optical vision assessment recorded.',
      );
    }

    final postureInsights = vision.insights
        .where((i) => i.category.toUpperCase() == 'POSTURE' || i.category.toUpperCase() == 'ALIGNMENT')
        .toList();

    if (postureInsights.isNotEmpty) {
      final topInsight = postureInsights.first;
      return AgentOutput(
        agentName: 'VisionAgent',
        summary: 'Visual signal: ${topInsight.title} — ${topInsight.recommendation}',
        metadata: {'insightCount': vision.insights.length},
      );
    }

    return AgentOutput(
      agentName: 'VisionAgent',
      summary: '${vision.insights.length} visual fitness insights analyzed.',
      metadata: {'insightCount': vision.insights.length},
    );
  }
}
