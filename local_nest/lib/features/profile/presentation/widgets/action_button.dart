import 'package:flutter/material.dart';
import '../../constants/manage_listings_constants.dart';
import '../../../../app/theme/theme.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const ActionButton({super.key, 
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: ManageListingsConstants.itemSpacing,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.background,
          border: Border.all(
            color: AppColors.border,
            width: ManageListingsConstants.borderWidth,
          ),
          borderRadius: BorderRadius.circular(
            ManageListingsConstants.buttonBorderRadius,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor ?? AppColors.textPrimary,
              size: ManageListingsConstants.smallIconSize,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: textColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
