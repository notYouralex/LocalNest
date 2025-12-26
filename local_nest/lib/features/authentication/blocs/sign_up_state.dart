part of 'sign_up_bloc.dart';

enum SignUpStatus { initial, loading, success, failure }

/// Sign up state
class SignUpState {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool agreeToTerms;
  final SignUpStatus status;
  final String? errorMessage;

  const SignUpState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.agreeToTerms = false,
    this.status = SignUpStatus.initial,
    this.errorMessage,
  });

  SignUpState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? agreeToTerms,
    SignUpStatus? status,
    String? errorMessage,
  }) {
    return SignUpState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}