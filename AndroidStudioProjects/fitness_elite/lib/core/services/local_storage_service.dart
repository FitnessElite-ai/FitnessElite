import 'package:shared_preferences/shared_preferences.dart';

/// Clean local persistence service for FitnessElite.ai using SharedPreferences.
class LocalStorageService {
  static const String _keyLanguageCode = 'fe_language_code';
  static const String _keyOnboardingCompleted = 'fe_onboarding_completed';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  /// Get persisted language code (defaults to 'en')
  String getLanguageCode() {
    return _prefs.getString(_keyLanguageCode) ?? 'en';
  }

  /// Save selected language code
  Future<bool> saveLanguageCode(String code) async {
    return await _prefs.setString(_keyLanguageCode, code);
  }

  /// Check if onboarding has been completed
  bool isOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// Save onboarding completed status
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await _prefs.setBool(_keyOnboardingCompleted, completed);
  }

  static const String _keyIsAuthenticated = 'fe_is_authenticated';
  static const String _keyAuthUserData = 'fe_auth_user_data';

  /// Check if user is currently authenticated
  bool isAuthenticated() {
    return _prefs.getBool(_keyIsAuthenticated) ?? false;
  }

  /// Save authentication status
  Future<bool> setAuthenticated(bool authenticated) async {
    return await _prefs.setBool(_keyIsAuthenticated, authenticated);
  }

  /// Get persisted user JSON data
  String? getAuthUserData() {
    return _prefs.getString(_keyAuthUserData);
  }

  /// Save user JSON data
  Future<bool> saveAuthUserData(String jsonStr) async {
    return await _prefs.setString(_keyAuthUserData, jsonStr);
  }

  /// Clear user session data
  Future<bool> clearAuthUserData() async {
    await _prefs.remove(_keyAuthUserData);
    return await _prefs.setBool(_keyIsAuthenticated, false);
  }

  /// Generic string getter
  String? getString(String key) => _prefs.getString(key);

  /// Generic string setter
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  /// Generic key remover
  Future<bool> remove(String key) => _prefs.remove(key);
}
