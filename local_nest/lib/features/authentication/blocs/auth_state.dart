part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Authentication state
class AuthState {
  final AuthStatus status;
  final UserProfile? userProfile;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.userProfile,
    this.errorMessage,
  });

  /// Initial state
  const AuthState.initial()
      : status = AuthStatus.initial,
        userProfile = null,
        errorMessage = null;

  /// Loading state
  const AuthState.loading()
      : status = AuthStatus.loading,
        userProfile = null,
        errorMessage = null;

  /// Authenticated state - user is logged in
  const AuthState.authenticated(this.userProfile)
      : status = AuthStatus.authenticated,
        errorMessage = null;

  /// Unauthenticated state - user is not logged in
  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        userProfile = null,
        errorMessage = null;

  /// Error state
  const AuthState.error(this.errorMessage)
      : status = AuthStatus.error,
        userProfile = null;

  /// Whether user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Whether app is checking auth status
  bool get isLoading => status == AuthStatus.loading;

  /// User type (renter or landlord) if authenticated
  String? get userType => userProfile?.userType;
}
