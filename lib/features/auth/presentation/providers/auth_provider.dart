import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/persistence_providers.dart';
import '../../data/auth_repository.dart';
import '../../data/dev_auth_repository.dart';
import '../../domain/auth_state.dart';

/// Provider for AuthRepository (defaults to DevAuthRepository)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return DevAuthRepository(storage);
});

/// Riverpod Notifier managing Authentication state
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    final user = _repository.currentUser;
    if (user != null) {
      return AuthState.authenticated(user);
    }
    return AuthState.unauthenticated();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    try {
      final user = await _repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } on DevAuthException catch (e) {
      if (e.code == 'network') {
        state = AuthState.error(
          'network_error',
          AuthErrorType.networkError,
        );
      } else {
        state = AuthState.error(
          'invalid_credentials',
          AuthErrorType.invalidCredentials,
        );
      }
    } catch (e) {
      state = AuthState.error(
        e.toString(),
        AuthErrorType.unknown,
      );
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    try {
      final user = await _repository.signUpWithEmailAndPassword(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } on DevAuthException catch (e) {
      if (e.code == 'network') {
        state = AuthState.error(
          'network_error',
          AuthErrorType.networkError,
        );
      } else if (e.code == 'accountExists') {
        state = AuthState.error(
          'account_exists',
          AuthErrorType.accountCreationFailure,
        );
      } else {
        state = AuthState.error(
          'account_creation_failed',
          AuthErrorType.accountCreationFailure,
        );
      }
    } catch (e) {
      state = AuthState.error(
        e.toString(),
        AuthErrorType.unknown,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = AuthState.loading();
    try {
      final user = await _repository.signInWithGoogle();
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(
        e.toString(),
        AuthErrorType.unknown,
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = AuthState.loading();
    try {
      await _repository.sendPasswordResetEmail(email);
      state = AuthState.passwordResetSent();
    } on DevAuthException catch (e) {
      if (e.code == 'network') {
        state = AuthState.error(
          'network_error',
          AuthErrorType.networkError,
        );
      } else {
        state = AuthState.error(
          'reset_failed',
          AuthErrorType.passwordResetRequest,
        );
      }
    } catch (e) {
      state = AuthState.error(
        e.toString(),
        AuthErrorType.unknown,
      );
    }
  }

  Future<void> signOut() async {
    state = AuthState.loading();
    await _repository.signOut();
    state = AuthState.unauthenticated();
  }

  void clearError() {
    if (state.user != null) {
      state = AuthState.authenticated(state.user!);
    } else {
      state = AuthState.unauthenticated();
    }
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Clean Validation Helpers
class AuthValidators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.\_%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validateName(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validationNameRequired;
    }
    return null;
  }

  static String? validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validationEmailInvalid;
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return l10n.validationEmailInvalid;
    }
    return null;
  }

  static String? validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.length < 8) {
      return l10n.validationPasswordMin;
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password,
    AppLocalizations l10n,
  ) {
    if (value == null || value != password) {
      return l10n.validationPasswordMatch;
    }
    return null;
  }
}
