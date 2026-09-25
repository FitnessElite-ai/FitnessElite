import '../../../core/services/local_storage_service.dart';
import '../models/nutrition_log.dart';

abstract class NutritionRepository {
  DailyNutritionLog getTodayLog();
  Future<bool> saveLog(DailyNutritionLog log);
}

class LocalNutritionRepository implements NutritionRepository {
  static const String _keyNutritionPrefix = 'fe_nutrition_log_';

  final LocalStorageService _storage;

  LocalNutritionRepository(this._storage);

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  DailyNutritionLog getTodayLog() {
    final key = _getTodayKey();
    final data = _storage.getString('$_keyNutritionPrefix$key');
    if (data != null && data.isNotEmpty) {
      try {
        return DailyNutritionLog.fromJson(data);
      } catch (_) {}
    }
    return DailyNutritionLog(dateKey: key);
  }

  @override
  Future<bool> saveLog(DailyNutritionLog log) async {
    final key = log.dateKey.isNotEmpty ? log.dateKey : _getTodayKey();
    return await _storage.setString('$_keyNutritionPrefix$key', log.toJson());
  }
}
