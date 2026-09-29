import '../domain/user_model.dart';

/// Clean repository interface for authentication.
/// Abstracted so Firebase, Supabase, or Custom Backend can replace implementation without UI changes.
abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;

  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthUser> signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  });

  Future<AuthUser> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
