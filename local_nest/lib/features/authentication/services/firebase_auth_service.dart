import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';
import 'login_auth_service.dart';

/// Firebase implementation of LoginAuthService
class FirebaseLoginAuthService implements LoginAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;

  FirebaseLoginAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = kIsWeb ? null : (googleSignIn ?? GoogleSignIn());

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
      if (kIsWeb) {
        // For web, use Firebase's built-in Google Sign-In
        final provider = GoogleAuthProvider();
        provider.addScope('profile');
        provider.addScope('email');
        final result = await _firebaseAuth.signInWithPopup(provider);
        return UserModel.fromFirebaseUser(result.user!);
      } else {
        // Sign out first to force account picker to show
        await _googleSignIn!.signOut();
        
        // For mobile
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
      }
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
  Future<void> signOut() async {
    try {
      final futures = [_firebaseAuth.signOut()];
      
      if (!kIsWeb && _googleSignIn != null) {
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