import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/models.dart';
import 'sign_up_auth.dart';

/// Firebase implementation of SignUpAuthService
class FirebaseSignUpAuthService implements SignUpAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;
  final FacebookAuth _facebookAuth;

  FirebaseSignUpAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = kIsWeb ? null : (googleSignIn ?? GoogleSignIn()),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  @override
  Future<UserModel> signUpWithEmail(String name, String email, String password) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update user profile with name
      await result.user?.updateDisplayName(name);
      await result.user?.reload();

      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Sign up failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserModel> signUpWithGoogle() async {
    try {
      if (_googleSignIn == null) {
        throw AuthException(
          code: 'google-sign-up-unavailable',
          message: 'Google sign-up is not available on this platform',
        );
      }
      
      // Sign out first to force account picker to show
      await _googleSignIn.signOut();
      
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException(
          code: 'google-sign-up-cancelled',
          message: 'Google sign-up was cancelled',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);

      // If new user, set additional data if needed
      if (result.additionalUserInfo?.isNewUser ?? false) {
        await result.user?.updateDisplayName(googleUser.displayName);
      }

      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'google-sign-up-error',
        message: 'Google sign-up failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserModel> signUpWithFacebook() async {
    try {
      final result = await _facebookAuth.login();

      if (result.status == LoginStatus.cancelled) {
        throw AuthException(
          code: 'facebook-sign-up-cancelled',
          message: 'Facebook sign-up was cancelled',
        );
      }

      if (result.status == LoginStatus.failed) {
        throw AuthException(
          code: 'facebook-sign-up-error',
          message: 'Facebook sign-up failed',
          details: result.message,
        );
      }

      final credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final authResult = await _firebaseAuth.signInWithCredential(credential);

      // If new user, set additional data if needed
      if (authResult.additionalUserInfo?.isNewUser ?? false) {
        await authResult.user?.updateDisplayName(authResult.additionalUserInfo?.profile?['name']);
      }

      return UserModel.fromFirebaseUser(authResult.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'facebook-sign-up-error',
        message: 'Facebook sign-up failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final futures = [
        _firebaseAuth.signOut(),
        _facebookAuth.logOut(),
      ];
      if (_googleSignIn != null) {
        futures.add(_googleSignIn.signOut());
      }
      await Future.wait(futures);
    } catch (e) {
      throw AuthException(
        code: 'sign-out-error',
        message: 'Sign out failed',
        details: e.toString(),
      );
    }
  }
}