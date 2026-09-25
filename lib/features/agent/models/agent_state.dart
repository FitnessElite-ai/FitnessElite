import 'agent_decision.dart';
import 'agent_memory.dart';
import 'agent_observation.dart';

enum AgentCycleStage { idle, observe, understand, plan, decide, act, reflect, adapt }

/// Reactive state of the FitnessAgent system.
class AgentState {
  final bool isRunning;
  final AgentCycleStage activeStage;
  final AgentDecision? lastDecision;
  final List<AgentDecision> decisionHistory;
  final List<AgentMemory> memories;
  final List<AgentObservation> observations;
  final String statusMessage;

  const AgentState({
    this.isRunning = false,
    this.activeStage = AgentCycleStage.idle,
    this.lastDecision,
    this.decisionHistory = const [],
    this.memories = const [],
    this.observations = const [],
    this.statusMessage = 'Fitness Agent Active',
  });

  AgentState copyWith({
    bool? isRunning,
    AgentCycleStage? activeStage,
    AgentDecision? lastDecision,
    List<AgentDecision>? decisionHistory,
    List<AgentMemory>? memories,
    List<AgentObservation>? observations,
    String? statusMessage,
  }) {
    return AgentState(
      isRunning: isRunning ?? this.isRunning,
      activeStage: activeStage ?? this.activeStage,
      lastDecision: lastDecision ?? this.lastDecision,
      decisionHistory: decisionHistory ?? this.decisionHistory,
      memories: memories ?? this.memories,
      observations: observations ?? this.observations,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
