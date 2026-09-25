import 'user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  passwordResetSent,
}

enum AuthErrorType {
  invalidCredentials,
  networkError,
  accountCreationFailure,
  passwordResetRequest,
  unknown,
}

/// Represents the UI & session state of authentication.
class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final AuthErrorType? errorType;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.errorType,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  factory AuthState.authenticated(AuthUser user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

  factory AuthState.unauthenticated() => const AuthState(
        status: AuthStatus.unauthenticated,
      );

  factory AuthState.error(String message, AuthErrorType type) => AuthState(
        status: AuthStatus.error,
        errorMessage: message,
        errorType: type,
      );

  factory AuthState.passwordResetSent() => const AuthState(
        status: AuthStatus.passwordResetSent,
      );

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  bool get isLoading => status == AuthStatus.loading;
}
