import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// Main intro screen where users select their role (Renter or Landlord)
class IntroPage extends StatelessWidget {
  final IntroNavigationService navigationService;
  final IntroDataProvider dataProvider;

  const IntroPage({
    super.key,
    required this.navigationService,
    required this.dataProvider,
  });

  /// Factory constructor with default data provider
  factory IntroPage.withDefaults({
    required IntroNavigationService navigationService,
  }) {
    return IntroPage(
      navigationService: navigationService,
      dataProvider: DefaultIntroDataProvider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: Column(
          children: [
            const IntroHeader(),
            Expanded(
              child: IntroContent(
                dataProvider: dataProvider,
                navigationService: navigationService,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
