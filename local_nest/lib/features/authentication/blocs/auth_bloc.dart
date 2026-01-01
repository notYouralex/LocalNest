import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/repositories/firestore_user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// AuthBloc - Manages global authentication state and app routing
/// Handles:
/// - Checking if user is already logged in on app start
/// - Loading user profile from Firestore
/// - Determining if user should see IntroPage or go to home
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirestoreUserRepository _userRepository;

  AuthBloc({FirestoreUserRepository? userRepository})
      : _userRepository = userRepository ?? FirestoreUserRepository(),
        super(const AuthState.initial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Check if user is already authenticated and load their profile
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      // Check if Firebase Auth has a current user
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        // Not logged in - show IntroPage
        emit(const AuthState.unauthenticated());
        return;
      }

      // User is in Firebase Auth, fetch their profile from Firestore
      final userProfile = await _userRepository.getUserProfile(currentUser.uid);

      if (userProfile == null) {
        // User in Auth but not in Firestore - incomplete registration
        await FirebaseAuth.instance.signOut();
        emit(const AuthState.unauthenticated());
        return;
      }

      // User is fully registered - authenticated
      emit(AuthState.authenticated(userProfile));
    } catch (e) {
      // Error checking auth status - treat as unauthenticated
      emit(AuthState.error(e.toString()));
    }
  }

  /// Handle logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await FirebaseAuth.instance.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error('Failed to logout: ${e.toString()}'));
    }
  }
}
