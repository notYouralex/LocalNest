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
          message = 'User not found';
          details = 'No user exists with this email address';
          break;
        case 'wrong-password':
          message = 'Wrong password';
          details = 'The password is incorrect';
          break;
        case 'email-already-in-use':
          message = 'Email already registered';
          details = 'An account with this email already exists';
          break;
        case 'invalid-email':
          message = 'Invalid email';
          details = 'Please enter a valid email address';
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
          details = 'Please try again later';
          break;
        case 'user-disabled':
          message = 'Account disabled';
          details = 'This account has been disabled';
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