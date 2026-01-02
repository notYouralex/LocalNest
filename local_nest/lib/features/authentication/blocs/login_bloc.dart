import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../../profile/repositories/firestore_user_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Login Bloc - handles login state management and Firestore profile validation
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginAuthService _authService;
  final FirestoreUserRepository _userRepository;

  LoginBloc({
    required LoginAuthService authService,
    FirestoreUserRepository? userRepository,
  })  : _authService = authService,
        _userRepository = userRepository ?? FirestoreUserRepository(),
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginWithGooglePressed>(_onGooglePressed);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // Sign in with Firebase Auth
      await _authService.signInWithEmail(state.email, state.password);

      // Get the authenticated user
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('Failed to get user ID after login');
      }

      // Fetch user profile from Firestore
      final userProfile = await _userRepository.getUserProfile(userId);
      if (userProfile == null) {
        throw Exception('User profile not found. Please complete registration.');
      }

      // Emit success with the real userType from Firestore (not from intro page)
      emit(state.copyWith(
        status: LoginStatus.success,
        userType: userProfile.userType,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Login failed. Please try again.',
      ));
    }
  }

  Future<void> _onGooglePressed(LoginWithGooglePressed event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // Sign in with Google
      await _authService.signInWithGoogle();

      // Get the authenticated user
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('Failed to get user ID after Google login');
      }

      // Fetch user profile from Firestore
      final userProfile = await _userRepository.getUserProfile(userId);
      if (userProfile == null) {
        throw Exception('User profile not found. Please complete registration.');
      }

      // Emit success with the real userType from Firestore
      emit(state.copyWith(
        status: LoginStatus.success,
        userType: userProfile.userType,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Google login failed. Please try again.',
      ));
    }
  }
}
