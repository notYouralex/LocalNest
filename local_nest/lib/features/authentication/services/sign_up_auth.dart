import '../models/models.dart';

/// Abstract interface for sign up authentication service
abstract class SignUpAuthService {
  /// Sign up with email and password
  Future<UserModel> signUpWithEmail(String name, String email, String password);

  /// Sign up with Google
  Future<UserModel> signUpWithGoogle();

  /// Sign out
  Future<void> signOut();
}