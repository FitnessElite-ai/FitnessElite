import '../models/agent_action.dart';
import '../models/agent_context.dart';
import '../models/agent_decision.dart';
import '../policies/agent_permission_policy.dart';
import '../policies/fitness_safety_policy.dart';
import '../services/specialized_agents.dart';

/// Orchestrates specialized sub-agents, validates actions via AgentPermissionPolicy,
/// and produces user-explainable AgentDecision objects.
class AgentOrchestrator {
  final WorkoutAgent _workoutAgent = WorkoutAgent();
  final NutritionAgent _nutritionAgent = NutritionAgent();
  final RecoveryAgent _recoveryAgent = RecoveryAgent();
  final ProgressAgent _progressAgent = ProgressAgent();
  final VisionAgent _visionAgent = VisionAgent();
  final DeviceAgent _deviceAgent = DeviceAgent();
  final WeatherAgent _weatherAgent = WeatherAgent();
  final BreathAgent _breathAgent = BreathAgent();
  final YogaAgent _yogaAgent = YogaAgent();

  AgentDecision runDailyCycle(AgentContext context) {
    final workoutOut = _workoutAgent.evaluate(context);
    final nutritionOut = _nutritionAgent.evaluate(context);
    final recoveryOut = _recoveryAgent.evaluate(context);
    final progressOut = _progressAgent.evaluate(context);
    final visionOut = _visionAgent.evaluate(context);
    final deviceOut = _deviceAgent.evaluate(context);
    final weatherOut = _weatherAgent.evaluate(context);
    final breathOut = _breathAgent.evaluate(context);
    final yogaOut = _yogaAgent.evaluate(context);

    // Filter proposed actions through permission policy
    final List<AgentAction> validActions = [];
    bool needsApproval = false;

    for (final action in [
      ...workoutOut.proposedActions,
      ...nutritionOut.proposedActions,
      ...recoveryOut.proposedActions,
      ...visionOut.proposedActions,
      ...deviceOut.proposedActions,
      ...weatherOut.proposedActions,
      ...breathOut.proposedActions,
      ...yogaOut.proposedActions,
    ]) {
      final perm = AgentPermissionPolicy.evaluateActionPermission(action.type, action.targetTool);
      if (perm == ActionPermissionLevel.neverAllowed) continue;

      if (perm == ActionPermissionLevel.userConfirmationRequired) {
        needsApproval = true;
      }
      validActions.add(action);
    }

    String title = "Today's Fitness Intelligence";
    String decisionText = "Your training split is on track. ${workoutOut.summary}";
    String reasonText = "${progressOut.summary} ${recoveryOut.summary} ${nutritionOut.summary} ${weatherOut.summary}";
    String evidenceText = "Based on recent workout feedback, metabolic targets, location weather signals (${weatherOut.summary}), and ${visionOut.summary}";

    if (workoutOut.proposedActions.isNotEmpty || deviceOut.proposedActions.isNotEmpty || weatherOut.proposedActions.isNotEmpty) {
      decisionText = workoutOut.proposedActions.isNotEmpty
          ? workoutOut.summary
          : weatherOut.proposedActions.isNotEmpty
              ? weatherOut.summary
              : deviceOut.summary;
      reasonText = "Adapted based on recent exertion signals, recovery baseline, location weather alerts (${weatherOut.summary}), wearable device feedback (${deviceOut.summary}), and nutrition focus.";
      evidenceText = "User feedback, environmental weather alerts, and wearable signals indicated fatigue or schedule constraints.";
    }

    title = FitnessSafetyPolicy.sanitizeText(title);
    decisionText = FitnessSafetyPolicy.sanitizeText(decisionText);

    return AgentDecision(
      id: 'dec_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      decision: decisionText,
      reason: reasonText,
      evidence: evidenceText,
      actions: validActions,
      requiresApproval: needsApproval,
      isApproved: !needsApproval,
      createdAt: DateTime.now(),
    );
  }
}
