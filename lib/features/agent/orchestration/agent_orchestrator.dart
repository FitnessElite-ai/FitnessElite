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

  AgentDecision runDailyCycle(AgentContext context) {
    final workoutOut = _workoutAgent.evaluate(context);
    final nutritionOut = _nutritionAgent.evaluate(context);
    final recoveryOut = _recoveryAgent.evaluate(context);
    final progressOut = _progressAgent.evaluate(context);
    final visionOut = _visionAgent.evaluate(context);

    // Filter proposed actions through permission policy
    final List<AgentAction> validActions = [];
    bool needsApproval = false;

    for (final action in [
      ...workoutOut.proposedActions,
      ...nutritionOut.proposedActions,
      ...recoveryOut.proposedActions,
      ...visionOut.proposedActions,
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
    String reasonText = "${progressOut.summary} ${recoveryOut.summary} ${nutritionOut.summary}";
    String evidenceText = "Based on recent workout feedback, metabolic targets, and ${visionOut.summary}";

    if (workoutOut.proposedActions.isNotEmpty) {
      decisionText = workoutOut.summary;
      reasonText = "Adapted based on recent exertion signals, recovery baseline, and nutrition focus (${nutritionOut.summary}).";
      evidenceText = "User feedback indicated high fatigue in the previous session.";
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
