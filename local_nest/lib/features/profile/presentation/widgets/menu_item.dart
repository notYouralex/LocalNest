import 'package:flutter/material.dart';
import '../../constants/profile_constants.dart';
import '../../../../app/theme/theme.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ProfileConstants.contentPadding,
              vertical: ProfileConstants.itemSpacing,
            ),
            child: Row(
              children: [
                Container(
                  width: ProfileConstants.largeIconSize * 2,
                  height: ProfileConstants.largeIconSize * 2,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.textPrimary,
                    size: ProfileConstants.mediumIconSize,
                  ),
                ),
                const SizedBox(width: ProfileConstants.itemSpacing),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: ProfileConstants.largeIconSize,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.border,
            thickness: 1,
          ),
      ],
    );
  }
}
