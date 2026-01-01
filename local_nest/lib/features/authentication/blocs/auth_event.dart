part of 'auth_bloc.dart';

/// Events for AuthBloc
abstract class AuthEvent {
  const AuthEvent();
}

/// Check if user is authenticated on app start
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Handle user logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
