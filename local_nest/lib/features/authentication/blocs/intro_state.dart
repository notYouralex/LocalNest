part of 'intro_bloc.dart';

enum UserType { none, renter, landlord }

/// Intro state
class IntroState {
  final UserType selectedUserType;

  const IntroState({
    this.selectedUserType = UserType.none,
  });

  IntroState copyWith({
    UserType? selectedUserType,
  }) {
    return IntroState(
      selectedUserType: selectedUserType ?? this.selectedUserType,
    );
  }
}
