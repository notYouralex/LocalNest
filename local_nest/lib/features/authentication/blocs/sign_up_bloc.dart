import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/services.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

/// Sign Up Bloc - handles sign up state management
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpAuthService _authService;

  SignUpBloc({required SignUpAuthService authService})
      : _authService = authService,
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
      await _authService.signUpWithEmail(
        state.name,
        state.email,
        state.password,
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