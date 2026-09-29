import '../../../core/services/local_storage_service.dart';
import '../models/complete_fitness_profile.dart';
import '../models/fitness_preferences.dart';

abstract class AICoachRepository {
  FitnessPreferences? getFitnessPreferences();
  CompleteFitnessProfile? getCompleteFitnessProfile();
  Future<bool> saveFitnessPreferences(FitnessPreferences preferences);
  Future<bool> saveCompleteFitnessProfile(CompleteFitnessProfile profile);
  Future<bool> clearCompleteFitnessProfile();
  bool isAiAssessmentCompleted();
}

class LocalAICoachRepository implements AICoachRepository {
  static const String _keyFitnessPreferences = 'fe_fitness_preferences';
  static const String _keyCompleteFitnessProfile =
      'fe_complete_fitness_profile';
  static const String _keyAiCompleted = 'fe_ai_assessment_completed';

  final LocalStorageService _storage;

  LocalAICoachRepository(this._storage);

  @override
  FitnessPreferences? getFitnessPreferences() {
    final data = _storage.getString(_keyFitnessPreferences);
    if (data != null && data.isNotEmpty) {
      try {
        return FitnessPreferences.fromJson(data);
      } catch (_) {}
    }
    return null;
  }

  @override
  CompleteFitnessProfile? getCompleteFitnessProfile() {
    final data = _storage.getString(_keyCompleteFitnessProfile);
    if (data != null && data.isNotEmpty) {
      try {
        return CompleteFitnessProfile.fromJson(data);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<bool> saveFitnessPreferences(FitnessPreferences preferences) async {
    return await _storage.setString(
        _keyFitnessPreferences, preferences.toJson());
  }

  @override
  Future<bool> saveCompleteFitnessProfile(
      CompleteFitnessProfile profile) async {
    await _storage.setString(
        _keyFitnessPreferences, profile.fitnessPreferences.toJson());
    await _storage.setString(
        _keyCompleteFitnessProfile, profile.toJson());
    return await _storage.setString(_keyAiCompleted, 'true');
  }

  @override
  Future<bool> clearCompleteFitnessProfile() async {
    await _storage.remove(_keyFitnessPreferences);
    await _storage.remove(_keyCompleteFitnessProfile);
    return await _storage.remove(_keyAiCompleted);
  }

  @override
  bool isAiAssessmentCompleted() {
    return _storage.getString(_keyAiCompleted) == 'true';
  }
}
