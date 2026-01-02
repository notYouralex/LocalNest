import 'package:flutter/material.dart';
import '../../constants/profile_constants.dart';
import '../../../../app/theme/theme.dart';

class StatCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ProfileConstants.cardSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
          width: ProfileConstants.borderWidth,
        ),
        borderRadius: BorderRadius.circular(ProfileConstants.cardBorderRadius),
      ),
      child: Column(
        children: [
          Container(
            width: ProfileConstants.largeIconSize * 2,
            height: ProfileConstants.largeIconSize * 2,
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: ProfileConstants.mediumIconSize,
            ),
          ),
          const SizedBox(height: 20),
          isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textSecondary,
                  ),
                )
              : Text(
                  count.toString(),
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: ProfileConstants.largeFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
