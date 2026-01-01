part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

/// Login state - includes userType fetched from Firestore
class LoginState {
  final String email;
  final String password;
  final bool rememberMe;
  final LoginStatus status;
  final String? errorMessage;
  final String? userType; // Fetched from Firestore, not from intro page

  const LoginState({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.userType,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    LoginStatus? status,
    String? errorMessage,
    String? userType,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userType: userType ?? this.userType,
    );
  }
}
