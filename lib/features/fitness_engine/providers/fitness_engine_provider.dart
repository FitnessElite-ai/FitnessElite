import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/persistence_providers.dart';
import '../../ai_coach/models/complete_fitness_profile.dart';
import '../models/fitness_plan.dart';
import '../repositories/fitness_plan_repository.dart';
import '../services/fitness_engine_service.dart';
import '../services/rule_based_fitness_engine.dart';

enum FitnessEngineStatus { idle, generating, success, error }

final fitnessEngineServiceProvider = Provider<FitnessEngineService>((ref) {
  return RuleBasedFitnessEngine();
});

final fitnessPlanRepositoryProvider = Provider<FitnessPlanRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalFitnessPlanRepository(storage);
});

class FitnessEngineState {
  final FitnessEngineStatus status;
  final String generationStage;
  final FitnessPlan? currentPlan;
  final String? errorMessage;

  const FitnessEngineState({
    this.status = FitnessEngineStatus.idle,
    this.generationStage = '',
    this.currentPlan,
    this.errorMessage,
  });

  FitnessEngineState copyWith({
    FitnessEngineStatus? status,
    String? generationStage,
    FitnessPlan? currentPlan,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FitnessEngineState(
      status: status ?? this.status,
      generationStage: generationStage ?? this.generationStage,
      currentPlan: currentPlan ?? this.currentPlan,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isGenerating => status == FitnessEngineStatus.generating;
  bool get isSuccess => status == FitnessEngineStatus.success;
  bool get isError => status == FitnessEngineStatus.error;
}

class FitnessEngineNotifier extends Notifier<FitnessEngineState> {
  late final FitnessEngineService _service;
  late final FitnessPlanRepository _repository;

  @override
  FitnessEngineState build() {
    _service = ref.watch(fitnessEngineServiceProvider);
    _repository = ref.watch(fitnessPlanRepositoryProvider);

    final existingPlan = _repository.getCurrentPlan();
    if (existingPlan != null) {
      return FitnessEngineState(
        status: FitnessEngineStatus.success,
        currentPlan: existingPlan,
      );
    }

    return const FitnessEngineState();
  }

  Future<FitnessPlan?> generatePlanForProfile(CompleteFitnessProfile profile) async {
    state = state.copyWith(
      status: FitnessEngineStatus.generating,
      generationStage: 'Understanding your profile',
      clearError: true,
    );

    try {
      final plan = await _service.generatePlan(profile: profile);

      await _repository.savePlan(plan);

      state = state.copyWith(
        status: FitnessEngineStatus.success,
        currentPlan: plan,
        generationStage: '',
      );

      return plan;
    } catch (e) {
      state = state.copyWith(
        status: FitnessEngineStatus.error,
        errorMessage: "We couldn't build your plan right now.",
      );
      return null;
    }
  }

  void resetPlan() {
    _repository.clearPlan();
    state = const FitnessEngineState();
  }
}

final fitnessEngineNotifierProvider = NotifierProvider<
    FitnessEngineNotifier, FitnessEngineState>(
  FitnessEngineNotifier.new,
);
