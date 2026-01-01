import 'package:equatable/equatable.dart';
import '../models/user_profile.dart';

/// States for UserBloc
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class UserInitial extends UserState {
  const UserInitial();
}

/// Loading user profile
class UserLoading extends UserState {
  const UserLoading();
}

/// User profile loaded successfully
class UserLoaded extends UserState {
  final UserProfile userProfile;

  const UserLoaded(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

/// User profile updated successfully
class UserUpdated extends UserState {
  final UserProfile userProfile;
  final String message;

  const UserUpdated(this.userProfile, {this.message = 'Profile updated successfully'});

  @override
  List<Object?> get props => [userProfile, message];
}

/// Error state
class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

/// User profile cleared
class UserCleared extends UserState {
  const UserCleared();
}
