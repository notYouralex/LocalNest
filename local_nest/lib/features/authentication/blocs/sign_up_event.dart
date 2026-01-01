part of 'sign_up_bloc.dart';

/// Base event for sign up
abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

/// Event when name changes
class SignUpNameChanged extends SignUpEvent {
  final String name;

  const SignUpNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

/// Event when email changes
class SignUpEmailChanged extends SignUpEvent {
  final String email;

  const SignUpEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// Event when password changes
class SignUpPasswordChanged extends SignUpEvent {
  final String password;

  const SignUpPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

/// Event when confirm password changes
class SignUpConfirmPasswordChanged extends SignUpEvent {
  final String confirmPassword;

  const SignUpConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

/// Event when terms checkbox is toggled
class SignUpTermsToggled extends SignUpEvent {
  final bool agreed;

  const SignUpTermsToggled(this.agreed);

  @override
  List<Object?> get props => [agreed];
}

/// Event when form is submitted
class SignUpSubmitted extends SignUpEvent {
  final String userType; // 'renter' or 'landlord'

  const SignUpSubmitted(this.userType);

  @override
  List<Object?> get props => [userType];
}

/// Event when signing up with Google
class SignUpWithGooglePressed extends SignUpEvent {
  const SignUpWithGooglePressed();
}

/// Event when signing up with Facebook
class SignUpWithFacebookPressed extends SignUpEvent {
  const SignUpWithFacebookPressed();
}