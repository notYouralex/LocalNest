import 'package:firebase_auth/firebase_auth.dart';
import 'login_auth_service.dart';
import 'sign_up_auth.dart';
import 'firebase_auth_service.dart';
import 'firebase_signup_auth_service.dart';

/// Service provider for authentication services
class AuthServiceProvider {
  static late LoginAuthService _loginAuthService;
  static late SignUpAuthService _signUpAuthService;

  /// Initialize Firebase authentication services
  static void initializeFirebaseServices() {
    _loginAuthService = FirebaseLoginAuthService();
    _signUpAuthService = FirebaseSignUpAuthService();
  }

  /// Get login auth service
  static LoginAuthService getLoginAuthService() {
    return _loginAuthService;
  }

  /// Get sign up auth service
  static SignUpAuthService getSignUpAuthService() {
    return _signUpAuthService;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Get current user
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}