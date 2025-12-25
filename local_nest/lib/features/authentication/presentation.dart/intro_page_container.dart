import 'package:flutter/material.dart';
import 'intro_page.dart';

// ============================================================================
// CONCRETE NAVIGATION SERVICE IMPLEMENTATION
// ============================================================================

class AppIntroNavigationService implements IntroNavigationService {
  final BuildContext context;

  AppIntroNavigationService({required this.context});

  @override
  void onRenterSelected() {
    // Navigate to renter flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Renter mode selected')),
    );
    // Navigator.pushNamed(context, '/renter-home');
  }

  @override
  void onLandlordSelected() {
    // Navigate to landlord flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Landlord mode selected')),
    );
    // Navigator.pushNamed(context, '/landlord-home');
  }
}

// ============================================================================
// USAGE EXAMPLE
// ============================================================================

class IntroScreenContainer extends StatelessWidget {
  const IntroScreenContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntroScreen(
      navigationService: AppIntroNavigationService(context: context),
      dataProvider: DefaultIntroDataProvider(),
    );
  }
}
