import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/persistence_providers.dart';
import '../models/nutrition_log.dart';
import '../repositories/nutrition_repository.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalNutritionRepository(storage);
});

class NutritionNotifier extends Notifier<DailyNutritionLog> {
  late final NutritionRepository _repo;

  @override
  DailyNutritionLog build() {
    _repo = ref.watch(nutritionRepositoryProvider);
    return _repo.getTodayLog();
  }

  void toggleMealEaten(String mealId) {
    final newEaten = Set<String>.from(state.eatenMealIds);
    if (newEaten.contains(mealId)) {
      newEaten.remove(mealId);
    } else {
      newEaten.add(mealId);
    }

    state = state.copyWith(eatenMealIds: newEaten);
    _repo.saveLog(state);
  }

  void addHydration(double liters) {
    final updated = state.hydrationLitersConsumed + liters;
    state = state.copyWith(hydrationLitersConsumed: double.parse(updated.toStringAsFixed(1)));
    _repo.saveLog(state);
  }
}

final nutritionNotifierProvider = NotifierProvider<
    NutritionNotifier, DailyNutritionLog>(
  NutritionNotifier.new,
);
