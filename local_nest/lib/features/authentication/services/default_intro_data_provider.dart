import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../models/models.dart';
import 'intro_data_provider.dart';

/// Default implementation of IntroDataProvider
/// Provides the renter and landlord options data
class DefaultIntroDataProvider implements IntroDataProvider {
  @override
  List<IntroOption> getIntroOptions() {
    return [
      IntroOption(
        id: 'renter',
        title: 'Looking for a Place',
        subtitle: 'Find verified boarding houses near you',
        icon: Icons.search,
        iconColor: AppColors.primary,
        iconBgColor: AppColors.primary.withOpacity(0.1),
        features: const [
          FeatureItem(
            icon: Icons.location_on,
            label: 'Map Search',
            color: AppColors.primary,
          ),
          FeatureItem(
            icon: Icons.shield,
            label: 'Verified',
            color: AppColors.primaryLight,
          ),
          FeatureItem(
            icon: Icons.favorite,
            label: 'Save Favorites',
            color: Color(0xFFFB7185),
          ),
        ],
        buttonText: 'Continue as Renter',
        buttonColor: AppColors.primary,
        borderColor: AppColors.primary,
      ),
      IntroOption(
        id: 'landlord',
        title: "I'm a Landlord",
        subtitle: 'List and manage your properties',
        icon: Icons.home,
        iconColor: AppColors.textPrimary,
        iconBgColor: AppColors.textPrimary.withOpacity(0.1),
        features: const [
          FeatureItem(
            icon: Icons.auto_awesome,
            label: 'Easy Listing',
            color: AppColors.textPrimary,
          ),
          FeatureItem(
            icon: Icons.shield,
            label: 'Get Verified',
            color: AppColors.primaryLight,
          ),
        ],
        buttonText: 'Continue as Landlord',
        buttonColor: Colors.transparent,
        borderColor: AppColors.textPrimary,
        isOutline: true,
      ),
    ];
  }
}
