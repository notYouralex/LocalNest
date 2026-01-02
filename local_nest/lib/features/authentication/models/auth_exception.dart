/// Custom exception for authentication errors
class AuthException implements Exception {
  final String code;
  final String message;
  final String? details;

  AuthException({
    required this.code,
    required this.message,
    this.details,
  });

  factory AuthException.fromFirebaseAuthException(dynamic e) {
    String message = 'Authentication failed';
    String details = '';

    if (e != null && e.code != null) {
      switch (e.code) {
        case 'user-not-found':
          message = 'Account not found';
          details = 'No account exists with this email address. Please sign up first.';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          details = 'The password you entered is incorrect';
          break;
        case 'invalid-credential':
          // Firebase SDK v5.x uses this code for wrong email/password
          message = 'Invalid email or password';
          details = 'Please check your email and password and try again';
          break;
        case 'invalid-email':
          message = 'Invalid email';
          details = 'Please enter a valid email address';
          break;
        case 'email-already-in-use':
          message = 'Email already registered';
          details = 'An account with this email already exists. Please sign in instead.';
          break;
        case 'weak-password':
          message = 'Weak password';
          details = 'Password should be at least 6 characters';
          break;
        case 'network-request-failed':
          message = 'Network error';
          details = 'Please check your internet connection';
          break;
        case 'too-many-requests':
          message = 'Too many attempts';
          details = 'Account temporarily locked. Please try again later.';
          break;
        case 'user-disabled':
          message = 'Account disabled';
          details = 'This account has been disabled. Please contact support.';
          break;
        case 'operation-not-allowed':
          message = 'Sign in method not allowed';
          details = 'This sign in method is not enabled';
          break;
        case 'account-exists-with-different-credential':
          message = 'Account exists with different method';
          details = 'An account already exists with the same email but different sign-in credentials';
          break;
        default:
          message = 'Authentication error';
          details = e.message ?? 'An unknown error occurred';
      }
    }

    return AuthException(
      code: e?.code ?? 'unknown',
      message: message,
      details: details.isEmpty ? null : details,
    );
  }

  @override
  String toString() => 'AuthException: $message${details != null ? ' - $details' : ''}';
}