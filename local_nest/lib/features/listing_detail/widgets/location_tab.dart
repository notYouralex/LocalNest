import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../constants/constants.dart';
import '../models/models.dart';

class LocationTab extends StatelessWidget {
  final String address;
  final String barangay;
  final List<NearbyLandmark> nearbyLandmarks;

  const LocationTab({
    Key? key,
    required this.address,
    required this.barangay,
    required this.nearbyLandmarks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address Section
          _buildSection(
            title: 'Address',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  barangay,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: sectionSpacing),

          // Map Placeholder
          Container(
            height: mapViewHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDBEAFE),
                  Color(0xFFBEDBFF),
                ],
              ),
              borderRadius: BorderRadius.circular(mapBorderRadius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Map View',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: itemSpacing),

          // View Full Map Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Open full map
              },
              icon: const Icon(Icons.map),
              label: const Text('View Full Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(badgeBorderRadius),
                ),
              ),
            ),
          ),
          const SizedBox(height: sectionSpacing),

          // Nearby Landmarks
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(
                color: AppColors.border,
              ),
              borderRadius: BorderRadius.circular(cardBorderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby Landmarks',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: sectionSpacing),
                ...nearbyLandmarks.map((landmark) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: itemSpacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          landmark.name,
                          style: AppTextStyles.bodySmall,
                        ),
                        Text(
                          landmark.distance,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
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
          style: AppTextStyles.bodyLarge,
        ),
        const SizedBox(height: itemSpacing),
        child,
      ],
    );
  }
}
