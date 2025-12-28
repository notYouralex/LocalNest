import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../constants/constants.dart';

class OverviewTab extends StatelessWidget {
  final String description;
  final List<String> inclusions;
  final List<String> houseRules;
  final String landlordName;
  final bool isLandlordVerified;

  const OverviewTab({
    Key? key,
    required this.description,
    required this.inclusions,
    required this.houseRules,
    required this.landlordName,
    required this.isLandlordVerified,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _buildSection(
            title: 'Description',
            child: Text(
              description,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const SizedBox(height: sectionSpacing),

          // Inclusions
          _buildSection(
            title: 'Inclusions',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: inclusions
                  .map(
                    (inclusion) => Padding(
                      padding: const EdgeInsets.only(bottom: itemSpacing),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: iconSize,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: itemSpacing),
                          Text(
                            inclusion,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: sectionSpacing),

          // House Rules
          _buildSection(
            title: 'House Rules',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: houseRules
                  .map(
                    (rule) => Padding(
                      padding: const EdgeInsets.only(bottom: itemSpacing),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: itemSpacing),
                          Text(
                            rule,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: sectionSpacing),

          // Landlord Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              border: Border.all(
                color: const Color(0xFFBEDBFF),
              ),
              borderRadius: BorderRadius.circular(cardBorderRadius),
            ),
            child: Row(
              children: [
                Container(
                  width: landlordAvatarSize,
                  height: landlordAvatarSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      landlordName[0].toUpperCase(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: itemSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            landlordName,
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(width: 8),
                          if (isLandlordVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF06B6D4),
                                borderRadius:
                                    BorderRadius.circular(badgeBorderRadius),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Verified',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Property Owner',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: itemSpacing),
        child,
      ],
    );
  }
}
