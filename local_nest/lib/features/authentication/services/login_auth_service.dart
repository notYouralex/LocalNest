import '../models/models.dart';

/// Abstract interface for login authentication service
abstract class LoginAuthService {
  /// Sign in with email and password
  Future<UserModel> signInWithEmail(String email, String password);

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Stream of authentication state changes
  Stream<UserModel?> authStateChanges();
}