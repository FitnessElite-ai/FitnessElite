import 'dart:convert';
import 'local_storage_service.dart';

abstract class UserDataRepository {
  Future<String> exportUserData();
  Future<bool> deleteUserData();
}

class LocalUserDataRepository implements UserDataRepository {
  final LocalStorageService _storage;

  LocalUserDataRepository(this._storage);

  @override
  Future<String> exportUserData() async {
    final Map<String, dynamic> exportData = {
      'languageCode': _storage.getLanguageCode(),
      'onboardingCompleted': _storage.isOnboardingCompleted(),
      'authUserData': _storage.getAuthUserData(),
      'exportedAt': DateTime.now().toIso8601String(),
      'note': 'Biometric data and progress logs exported from FitnessElite local storage.'
    };
    return json.encode(exportData);
  }

  @override
  Future<bool> deleteUserData() async {
    // Clear all local user session and profile keys
    await _storage.clearAuthUserData();
    return true;
  }
}
