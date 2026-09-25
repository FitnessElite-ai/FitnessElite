import '../../ai_coach/models/complete_fitness_profile.dart';
import '../models/fitness_plan.dart';

/// Abstract service interface for the Fitness Intelligence Engine.
/// Decoupled so a future AI / LLM model can replace the deterministic engine
/// without changing UI or data models.
abstract class FitnessEngineService {
  Future<FitnessPlan> generatePlan({
    required CompleteFitnessProfile profile,
  });
}
