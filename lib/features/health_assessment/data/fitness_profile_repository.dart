import '../../../core/services/local_storage_service.dart';
import '../domain/fitness_profile.dart';

abstract class FitnessProfileRepository {
  FitnessProfile? getFitnessProfile();
  Future<bool> saveFitnessProfile(FitnessProfile profile);
  Future<bool> clearFitnessProfile();
}

class LocalFitnessProfileRepository implements FitnessProfileRepository {
  static const String _keyFitnessProfileData = 'fe_fitness_profile_data';
  final LocalStorageService _storage;

  LocalFitnessProfileRepository(this._storage);

  @override
  FitnessProfile? getFitnessProfile() {
    final data = _storage.getString(_keyFitnessProfileData);
    if (data != null && data.isNotEmpty) {
      try {
        return FitnessProfile.fromJson(data);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<bool> saveFitnessProfile(FitnessProfile profile) async {
    return await _storage.setString(_keyFitnessProfileData, profile.toJson());
  }

  @override
  Future<bool> clearFitnessProfile() async {
    return await _storage.remove(_keyFitnessProfileData);
  }
}
