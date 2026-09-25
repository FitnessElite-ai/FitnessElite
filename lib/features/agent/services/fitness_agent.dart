import '../memory/fitness_memory_service.dart';
import '../models/agent_context.dart';
import '../models/agent_decision.dart';
import '../models/agent_memory.dart';
import '../orchestration/agent_orchestrator.dart';

abstract class FitnessAgentService {
  Future<AgentDecision> runCycle(AgentContext context);
}

/// Primary FitnessAgent executing the autonomous observe-understand-plan-decide-act-reflect cycle.
class FitnessAgent implements FitnessAgentService {
  final AgentOrchestrator _orchestrator = AgentOrchestrator();
  final FitnessMemoryService _memoryService;

  FitnessAgent(this._memoryService);

  @override
  Future<AgentDecision> runCycle(AgentContext context) async {
    // 1. Run orchestrator to evaluate context
    final decision = _orchestrator.runDailyCycle(context);

    // 2. Store decision in memory
    final memory = AgentMemory(
      id: 'mem_dec_${DateTime.now().millisecondsSinceEpoch}',
      category: 'AGENT_DECISION',
      value: decision.decision,
      confidence: 0.95,
      source: 'reflection',
      createdAt: DateTime.now(),
    );
    await _memoryService.remember(memory);

    return decision;
  }
}
