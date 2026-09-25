import 'dart:async';
import '../../../core/services/local_storage_service.dart';
import '../domain/user_model.dart';
import 'auth_repository.dart';

/// Production-ready Development Authentication Repository.
/// Used during local development phase before backend integration.
/// Persists sessions locally via LocalStorageService across app restarts.
class DevAuthRepository implements AuthRepository {
  final LocalStorageService _storage;
  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  AuthUser? _currentUser;

  DevAuthRepository(this._storage) {
    _initSession();
  }

  void _initSession() {
    if (_storage.isAuthenticated()) {
      final jsonStr = _storage.getAuthUserData();
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          _currentUser = AuthUser.fromJson(jsonStr);
          _authStateController.add(_currentUser);
          return;
        } catch (_) {}
      }
    }
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail == 'network@fitnesselite.ai') {
      throw const DevAuthException('network');
    }

    if (cleanEmail == 'fail@fitnesselite.ai' || password == 'wrongpass') {
      throw const DevAuthException('invalidCredentials');
    }

    final user = AuthUser(
      id: 'usr_${cleanEmail.hashCode}',
      email: cleanEmail,
      fullName: cleanEmail.contains('@')
          ? cleanEmail.split('@').first.toUpperCase()
          : 'Fitness Elite User',
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    await _storage.setAuthenticated(true);
    await _storage.saveAuthUserData(user.toJson());
    _authStateController.add(user);

    return user;
  }

  @override
  Future<AuthUser> signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail == 'network@fitnesselite.ai') {
      throw const DevAuthException('network');
    }

    if (cleanEmail == 'exists@fitnesselite.ai') {
      throw const DevAuthException('accountExists');
    }

    final user = AuthUser(
      id: 'usr_${cleanEmail.hashCode}',
      email: cleanEmail,
      fullName: fullName.trim(),
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    await _storage.setAuthenticated(true);
    await _storage.saveAuthUserData(user.toJson());
    _authStateController.add(user);

    return user;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final googleUser = AuthUser(
      id: 'usr_google_dev_123',
      email: 'alex.fitness@gmail.com',
      fullName: 'Alex Morgan',
      createdAt: DateTime.now(),
    );

    _currentUser = googleUser;
    await _storage.setAuthenticated(true);
    await _storage.saveAuthUserData(googleUser.toJson());
    _authStateController.add(googleUser);

    return googleUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail == 'network@fitnesselite.ai') {
      throw const DevAuthException('network');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    await _storage.clearAuthUserData();
    _authStateController.add(null);
  }
}

class DevAuthException implements Exception {
  final String code;
  const DevAuthException(this.code);

  @override
  String toString() => 'DevAuthException: $code';
}
