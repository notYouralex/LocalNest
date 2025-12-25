import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../services/services.dart';
import 'option_card.dart';

/// Content section of the intro screen with welcome text and option cards
class IntroContent extends StatelessWidget {
  final IntroDataProvider dataProvider;
  final IntroNavigationService navigationService;

  const IntroContent({
    super.key,
    required this.dataProvider,
    required this.navigationService,
  });

  @override
  Widget build(BuildContext context) {
    final options = dataProvider.getIntroOptions();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Welcome text
            Text(
              'Welcome! 👋',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'How can we help you today?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Option cards
            ...options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: OptionCard(
                  option: option,
                  onTap: () => _handleOptionSelection(option.id),
                ),
              );
            }),
            
            // Footer text
            Text(
              'You can change your account type anytime',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _handleOptionSelection(String optionId) {
    if (optionId == 'renter') {
      navigationService.onRenterSelected();
    } else if (optionId == 'landlord') {
      navigationService.onLandlordSelected();
    }
  }
}
