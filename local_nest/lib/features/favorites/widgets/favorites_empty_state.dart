import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../constants/favorites_constants.dart';

/// Empty state widget when no favorites exist
class FavoritesEmptyState extends StatelessWidget {
  final VoidCallback onBrowsePressed;

  const FavoritesEmptyState({
    super.key,
    required this.onBrowsePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(
              height: FavoritesConstants.emptyStateSpacing,
            ),
            _buildTitle(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(
              height: FavoritesConstants.emptyStateSpacing,
            ),
            _buildBrowseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: FavoritesConstants.headerIconContainerSize,
      height: FavoritesConstants.headerIconContainerSize,
      decoration: BoxDecoration(
        color: AppColors.greenBackground,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.favorite_border,
          size: FavoritesConstants.emptyStateIconSize,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'No Favorites Yet',
      style: AppTextStyles.heading2.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FavoritesConstants.emptyStateDescriptionHorizontalPadding,
      ),
      child: Text(
        'Start exploring and save your favorite boarding houses to find them here',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildBrowseButton() {
    return ElevatedButton(
      onPressed: onBrowsePressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: FavoritesConstants.emptyStateButtonHorizontalPadding,
          vertical: FavoritesConstants.emptyStateButtonVerticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            FavoritesConstants.emptyStateButtonBorderRadius,
          ),
        ),
        elevation: 0,
      ),
      child: Text(
        'Browse Listings',
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
