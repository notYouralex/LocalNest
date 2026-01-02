import 'package:firebase_auth/firebase_auth.dart';

/// Service for handling password reset operations
class FirebasePasswordResetService {
  final FirebaseAuth _firebaseAuth;

  FirebasePasswordResetService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Sends a password reset email to the specified email address
  /// Throws an exception with a user-friendly message if the operation fails
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Failed to send password reset email. Please try again.');
    }
  }

  /// Converts Firebase error codes to user-friendly messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Failed to send password reset email. Please try again.';
    }
  }
}
