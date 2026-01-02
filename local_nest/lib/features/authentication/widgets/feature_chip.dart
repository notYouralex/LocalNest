import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../models/models.dart';

/// Feature chip widget displaying an icon and label
class FeatureChip extends StatelessWidget {
  final FeatureItem feature;

  const FeatureChip({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: feature.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(feature.icon, size: 12, color: feature.color),
          const SizedBox(width: 6),
          Text(
            feature.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// List of feature chips displayed in a wrap layout
class FeaturesList extends StatelessWidget {
  final List<FeatureItem> features;

  const FeaturesList({
    super.key,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((feature) => FeatureChip(feature: feature)).toList(),
    );
  }
}
