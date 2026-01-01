import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

/// BLoC for managing user profile operations
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const UserInitial()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<ClearUserProfileEvent>(_onClearUserProfile);
  }

  /// Load user profile from repository
  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final userProfile = await _userRepository.getUserProfile(event.userId);
      if (userProfile == null) {
        emit(const UserError('User profile not found'));
        return;
      }
      emit(UserLoaded(userProfile));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Update user profile
  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! UserLoaded) {
        throw Exception('No user profile loaded');
      }

      final updatedProfile = currentState.userProfile.copyWith(
        displayName: event.displayName ?? currentState.userProfile.displayName,
        phoneNumber: event.phoneNumber ?? currentState.userProfile.phoneNumber,
        profileImageUrl:
            event.profileImageUrl ?? currentState.userProfile.profileImageUrl,
      );

      await _userRepository.updateUserProfile(updatedProfile);
      emit(UserUpdated(updatedProfile));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Clear user profile
  Future<void> _onClearUserProfile(
    ClearUserProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserCleared());
  }
}
