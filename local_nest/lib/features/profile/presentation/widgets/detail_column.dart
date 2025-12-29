import 'package:flutter/material.dart';
import '../../constants/manage_listings_constants.dart';
import '../../../../app/theme/theme.dart';

class DetailColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const DetailColumn(
    this.label,
    this.value, {
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: ManageListingsConstants.statLabelFontSize,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isPrimary ? AppColors.cyan : AppColors.textPrimary,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
