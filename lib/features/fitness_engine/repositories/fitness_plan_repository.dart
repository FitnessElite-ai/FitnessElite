import '../../../core/services/local_storage_service.dart';
import '../models/fitness_plan.dart';

abstract class FitnessPlanRepository {
  FitnessPlan? getCurrentPlan();
  Future<bool> savePlan(FitnessPlan plan);
  Future<bool> clearPlan();
  bool hasActivePlan();
}

class LocalFitnessPlanRepository implements FitnessPlanRepository {
  static const String _keyFitnessPlanData = 'fe_fitness_plan_data';
  static const String _keyPlanActive = 'fe_fitness_plan_active';

  final LocalStorageService _storage;

  LocalFitnessPlanRepository(this._storage);

  @override
  FitnessPlan? getCurrentPlan() {
    final data = _storage.getString(_keyFitnessPlanData);
    if (data != null && data.isNotEmpty) {
      try {
        return FitnessPlan.fromJson(data);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<bool> savePlan(FitnessPlan plan) async {
    await _storage.setString(_keyFitnessPlanData, plan.toJson());
    return await _storage.setString(_keyPlanActive, 'true');
  }

  @override
  Future<bool> clearPlan() async {
    await _storage.remove(_keyFitnessPlanData);
    return await _storage.remove(_keyPlanActive);
  }

  @override
  bool hasActivePlan() {
    return _storage.getString(_keyPlanActive) == 'true';
  }
}
