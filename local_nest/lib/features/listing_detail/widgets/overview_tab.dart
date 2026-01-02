import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../../../core/widgets/user_avatar.dart';
import '../constants/constants.dart';

class OverviewTab extends StatelessWidget {
  final String description;
  final String landlordName;
  final String? landlordProfileImageUrl;

  const OverviewTab({
    super.key,
    required this.description,
    required this.landlordName,
    this.landlordProfileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (description.isNotEmpty) ...[
            _buildSection(
              title: 'Description',
              child: Text(
                description,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const SizedBox(height: sectionSpacing),
          ],

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
                UserAvatar(
                  imageUrl: landlordProfileImageUrl,
                  displayName: landlordName,
                  radius: landlordAvatarSize / 2,
                  fontSize: 20,
                ),
                const SizedBox(width: itemSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        landlordName,
                        style: AppTextStyles.bodyLarge,
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
