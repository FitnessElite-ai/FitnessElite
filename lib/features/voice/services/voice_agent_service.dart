import 'package:flutter/foundation.dart';
import '../../agent/models/agent_context.dart';
import '../../agent/models/agent_decision.dart';
import '../../agent/orchestration/agent_orchestrator.dart';
import '../../agent/policies/agent_permission_policy.dart';
import '../../agent/policies/fitness_safety_policy.dart';
import '../../ai_coach/services/conversational_ai_provider.dart';

/// Voice Agent Service executing the speech -> intent -> agent context -> orchestrator -> action -> voice response pipeline.
class VoiceAgentService {
  final AgentOrchestrator _orchestrator;
  final ConversationalAIProvider _aiProvider;

  VoiceAgentService({
    AgentOrchestrator? orchestrator,
    ConversationalAIProvider? aiProvider,
  })  : _orchestrator = orchestrator ?? AgentOrchestrator(),
        _aiProvider = aiProvider ?? DeterministicFallbackProvider();

  Future<String> processVoiceQuery({
    required String speechText,
    required AgentContext context,
  }) async {
    debugPrint('[VoiceAgentService] Processing voice input: "$speechText"');

    // 1. Extract Structured Intent
    final intent = StructuredUserIntent.parse(speechText);

    // 2. Check Permission Policy
    final perm = AgentPermissionPolicy.evaluateActionPermission(intent.intentType, 'VoiceAgentTool');
    if (perm == ActionPermissionLevel.neverAllowed) {
      return "FitnessElite.ai cannot perform medical diagnoses or unsafe commands.";
    }

    // 3. Evaluate via Orchestrator or Conversational Provider
    if (intent.intentType == 'time_constraint' || intent.intentType == 'fatigue') {
      final AgentDecision decision = _orchestrator.runDailyCycle(context);
      final safeResponse = FitnessSafetyPolicy.sanitizeText(decision.decision);
      return safeResponse;
    }

    // 4. Fallback to Conversational AI Provider
    final response = await _aiProvider.generateResponse(
      userMessage: speechText,
      conversation: const [],
    );

    return FitnessSafetyPolicy.sanitizeText(response);
  }
}
