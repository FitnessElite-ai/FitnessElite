import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../agent/providers/agent_provider.dart';
import '../../agent/services/agent_context_builder.dart';
import '../../ai_coach/providers/ai_coach_provider.dart';
import '../../fitness_engine/providers/fitness_engine_provider.dart';
import '../../workouts/providers/workout_session_provider.dart';
import '../models/voice_state.dart';
import '../services/voice_agent_service.dart';

final voiceAgentServiceProvider = Provider<VoiceAgentService>((ref) {
  final orchestrator = ref.watch(agentOrchestratorProvider);
  return VoiceAgentService(orchestrator: orchestrator);
});

class VoiceNotifier extends Notifier<VoiceState> {
  late final VoiceAgentService _voiceService;

  @override
  VoiceState build() {
    _voiceService = ref.watch(voiceAgentServiceProvider);
    return const VoiceState();
  }

  Future<void> handleVoiceInput(String text) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(
      status: VoiceStatus.understanding,
      transcript: text,
      responseText: '',
    );

    final aiState = ref.read(conversationNotifierProvider);
    final engineState = ref.read(fitnessEngineNotifierProvider);
    final historyRepo = ref.read(workoutHistoryRepositoryProvider);
    final memoryService = ref.read(fitnessMemoryServiceProvider);

    final history = historyRepo.getWorkoutHistory();
    final memories = memoryService.getAllMemories();

    final context = ref.read(agentNotifierProvider).lastDecision != null
        ? AgentContextBuilder.buildContext(
            profile: aiState.completeProfile,
            currentPlan: engineState.currentPlan,
            history: history,
            memories: memories,
          )
        : AgentContextBuilder.buildContext(
            profile: aiState.completeProfile,
            currentPlan: engineState.currentPlan,
            history: history,
            memories: memories,
          );

    state = state.copyWith(status: VoiceStatus.responding);

    final response = await _voiceService.processVoiceQuery(
      speechText: text,
      context: context,
    );

    // If query was a time constraint or fatigue signal, trigger autonomous agent cycle!
    if (text.toLowerCase().contains('min') || text.toLowerCase().contains('tired')) {
      await ref.read(agentNotifierProvider.notifier).triggerAgentCycle();
    }

    state = state.copyWith(
      status: VoiceStatus.idle,
      responseText: response,
    );
  }

  void reset() {
    state = const VoiceState();
  }
}

final voiceNotifierProvider = NotifierProvider<VoiceNotifier, VoiceState>(
  VoiceNotifier.new,
);
