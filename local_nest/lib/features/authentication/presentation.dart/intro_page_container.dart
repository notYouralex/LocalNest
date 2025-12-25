import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'intro_page.dart';
import '../../../app/router/app_router.dart';

// ============================================================================
// CONCRETE NAVIGATION SERVICE IMPLEMENTATION
// ============================================================================

class AppIntroNavigationService implements IntroNavigationService {
  final BuildContext context;

  AppIntroNavigationService({required this.context});

  @override
  void onRenterSelected() {
    // Navigate to login as renter
    context.push(AppRoutes.login);
  }

  @override
  void onLandlordSelected() {
    // Navigate to login as landlord
    context.push(AppRoutes.login);
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
