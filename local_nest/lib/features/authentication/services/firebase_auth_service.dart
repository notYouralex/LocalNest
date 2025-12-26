import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/models.dart';
import 'login_auth_service.dart';

/// Firebase implementation of LoginAuthService
class FirebaseLoginAuthService implements LoginAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  FirebaseLoginAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Sign in failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException(
          code: 'google-sign-in-cancelled',
          message: 'Google sign-in was cancelled',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'google-sign-in-error',
        message: 'Google sign-in failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      final result = await _facebookAuth.login();

      if (result.status == LoginStatus.cancelled) {
        throw AuthException(
          code: 'facebook-login-cancelled',
          message: 'Facebook login was cancelled',
        );
      }

      if (result.status == LoginStatus.failed) {
        throw AuthException(
          code: 'facebook-login-error',
          message: 'Facebook login failed',
          details: result.message,
        );
      }

      final credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final authResult = await _firebaseAuth.signInWithCredential(credential);
      return UserModel.fromFirebaseUser(authResult.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'facebook-login-error',
        message: 'Facebook login failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
    } catch (e) {
      throw AuthException(
        code: 'sign-out-error',
        message: 'Sign out failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }
}