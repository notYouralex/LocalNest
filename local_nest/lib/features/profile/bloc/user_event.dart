import 'package:equatable/equatable.dart';

/// Events for UserBloc
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Load user profile
class LoadUserProfileEvent extends UserEvent {
  final String userId;

  const LoadUserProfileEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Update user profile
class UpdateUserProfileEvent extends UserEvent {
  final String userId;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? barangay;
  final String? profileImageUrl;

  const UpdateUserProfileEvent({
    required this.userId,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.address,
    this.city,
    this.barangay,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        displayName,
        phoneNumber,
        address,
        city,
        barangay,
        profileImageUrl,
      ];
}

/// Clear user profile
class ClearUserProfileEvent extends UserEvent {
  const ClearUserProfileEvent();
}
