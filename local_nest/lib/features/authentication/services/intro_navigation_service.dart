/// Abstract interface for intro navigation actions
/// Follows Dependency Inversion Principle
abstract class IntroNavigationService {
  void onRenterSelected();
  void onLandlordSelected();
}
