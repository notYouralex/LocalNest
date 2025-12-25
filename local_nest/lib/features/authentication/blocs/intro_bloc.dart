import 'package:flutter_bloc/flutter_bloc.dart';

part 'intro_event.dart';
part 'intro_state.dart';

/// Intro Bloc - handles user type selection state
class IntroBloc extends Bloc<IntroEvent, IntroState> {
  IntroBloc() : super(const IntroState()) {
    on<IntroRenterSelected>(_onRenterSelected);
    on<IntroLandlordSelected>(_onLandlordSelected);
  }

  void _onRenterSelected(IntroRenterSelected event, Emitter<IntroState> emit) {
    emit(state.copyWith(selectedUserType: UserType.renter));
  }

  void _onLandlordSelected(IntroLandlordSelected event, Emitter<IntroState> emit) {
    emit(state.copyWith(selectedUserType: UserType.landlord));
  }
}
