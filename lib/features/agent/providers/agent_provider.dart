import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/persistence_providers.dart';
import '../../ai_coach/providers/ai_coach_provider.dart';
import '../../fitness_engine/providers/fitness_engine_provider.dart';
import '../../workouts/providers/workout_session_provider.dart';
import '../memory/fitness_memory_service.dart';
import '../models/agent_decision.dart';
import '../models/agent_state.dart';
import '../orchestration/agent_orchestrator.dart';
import '../services/agent_context_builder.dart';
import '../services/fitness_agent.dart';

final fitnessMemoryServiceProvider = Provider<FitnessMemoryService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalFitnessMemoryService(storage);
});

final agentOrchestratorProvider = Provider<AgentOrchestrator>((ref) {
  return AgentOrchestrator();
});

final fitnessAgentServiceProvider = Provider<FitnessAgentService>((ref) {
  final memoryService = ref.watch(fitnessMemoryServiceProvider);
  return FitnessAgent(memoryService);
});

class AgentNotifier extends Notifier<AgentState> {
  late final FitnessAgentService _agentService;
  late final FitnessMemoryService _memoryService;

  @override
  AgentState build() {
    _agentService = ref.watch(fitnessAgentServiceProvider);
    _memoryService = ref.watch(fitnessMemoryServiceProvider);

    final memories = _memoryService.getAllMemories();

    return AgentState(
      memories: memories,
      statusMessage: 'Fitness Agent Active',
    );
  }

  Future<AgentDecision> triggerAgentCycle() async {
    state = state.copyWith(
      isRunning: true,
      activeStage: AgentCycleStage.observe,
      statusMessage: 'Observing workout signals...',
    );

    await Future.delayed(const Duration(milliseconds: 100));
    state = state.copyWith(
      activeStage: AgentCycleStage.understand,
      statusMessage: 'Evaluating recovery & history...',
    );

    final aiState = ref.read(conversationNotifierProvider);
    final engineState = ref.read(fitnessEngineNotifierProvider);
    final historyRepo = ref.read(workoutHistoryRepositoryProvider);

    final history = historyRepo.getWorkoutHistory();
    final memories = _memoryService.getAllMemories();

    final context = AgentContextBuilder.buildContext(
      profile: aiState.completeProfile,
      currentPlan: engineState.currentPlan,
      history: history,
      memories: memories,
    );

    state = state.copyWith(
      activeStage: AgentCycleStage.plan,
      statusMessage: 'Planning adaptation...',
    );

    await Future.delayed(const Duration(milliseconds: 100));
    state = state.copyWith(
      activeStage: AgentCycleStage.decide,
      statusMessage: 'Finalizing agent decision...',
    );

    final decision = await _agentService.runCycle(context);

    final updatedHistory = List<AgentDecision>.from(state.decisionHistory)..add(decision);
    final updatedMemories = _memoryService.getAllMemories();

    state = state.copyWith(
      isRunning: false,
      activeStage: AgentCycleStage.idle,
      lastDecision: decision,
      decisionHistory: updatedHistory,
      memories: updatedMemories,
      statusMessage: 'Fitness Agent Active',
    );

    return decision;
  }

  void approveDecision(String decisionId) {
    if (state.lastDecision != null && state.lastDecision!.id == decisionId) {
      state = state.copyWith(
        lastDecision: state.lastDecision!.copyWith(isApproved: true),
      );
    }
  }

  Future<void> forgetMemory(String id) async {
    await _memoryService.forgetMemory(id);
    final memories = _memoryService.getAllMemories();
    state = state.copyWith(memories: memories);
  }
}

final agentNotifierProvider = NotifierProvider<
    AgentNotifier, AgentState>(
  AgentNotifier.new,
);
