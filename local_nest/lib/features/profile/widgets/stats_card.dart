import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';

/// Stats card showing a count and label
class StatsCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color iconBackgroundColor;

  const StatsCard({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Count
          Text(
            count.toString(),
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.textPrimary,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
