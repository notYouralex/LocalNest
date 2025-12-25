/// Abstract interface for login authentication service
abstract class LoginAuthService {
  Future<void> signInWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signInWithFacebook();
}
