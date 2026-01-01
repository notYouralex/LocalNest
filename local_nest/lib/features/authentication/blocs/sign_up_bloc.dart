import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/services.dart';
import '../../profile/repositories/firestore_user_repository.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

/// Sign Up Bloc - handles sign up state management
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpAuthService _authService;
  final FirestoreUserRepository _userRepository;

  SignUpBloc({
    required SignUpAuthService authService,
    FirestoreUserRepository? userRepository,
  })  : _authService = authService,
        _userRepository = userRepository ?? FirestoreUserRepository(),
        super(const SignUpState()) {
    on<SignUpNameChanged>(_onNameChanged);
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignUpTermsToggled>(_onTermsToggled);
    on<SignUpSubmitted>(_onSubmitted);
    on<SignUpWithGooglePressed>(_onGooglePressed);
    on<SignUpWithFacebookPressed>(_onFacebookPressed);
  }

  void _onNameChanged(SignUpNameChanged event, Emitter<SignUpState> emit) {
    emit(state.copyWith(name: event.name));
  }

  void _onEmailChanged(SignUpEmailChanged event, Emitter<SignUpState> emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(SignUpPasswordChanged event, Emitter<SignUpState> emit) {
    emit(state.copyWith(password: event.password));
  }

  void _onConfirmPasswordChanged(
    SignUpConfirmPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.confirmPassword));
  }

  void _onTermsToggled(SignUpTermsToggled event, Emitter<SignUpState> emit) {
    emit(state.copyWith(agreeToTerms: event.agreed));
  }

  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(state.copyWith(status: SignUpStatus.loading));

    try {
      // Create Firebase Auth user
      await _authService.signUpWithEmail(
        state.name,
        state.email,
        state.password,
      );

      // Get the newly created user
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('Failed to get user ID');
      }

      // Create user profile in Firestore
      await _userRepository.createUserProfile(
        userId: userId,
        email: state.email,
        userType: event.userType,
        displayName: state.name,
      );

      emit(state.copyWith(status: SignUpStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGooglePressed(
    SignUpWithGooglePressed event,
    Emitter<SignUpState> emit,
  ) async {
    emit(state.copyWith(status: SignUpStatus.loading));

    try {
      await _authService.signUpWithGoogle();
      emit(state.copyWith(status: SignUpStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFacebookPressed(
    SignUpWithFacebookPressed event,
    Emitter<SignUpState> emit,
  ) async {
    emit(state.copyWith(status: SignUpStatus.loading));

    try {
      await _authService.signUpWithFacebook();
      emit(state.copyWith(status: SignUpStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}