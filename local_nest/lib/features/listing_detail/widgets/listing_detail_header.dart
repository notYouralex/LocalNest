import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../constants/constants.dart';

class ListingDetailHeader extends StatelessWidget {
  final String title;
  final String address;
  final double price;
  final int slotsAvailable;
  final List<String> tags;

  const ListingDetailHeader({
    super.key,
    required this.title,
    required this.address,
    required this.price,
    required this.slotsAvailable,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${price.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/month',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: itemSpacing),

        // Address
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: iconSize,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address,
                style: AppTextStyles.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: itemSpacing),

        // Availability
        Row(
          children: [
            Text(
              '$slotsAvailable slots available',
              style: AppTextStyles.bodyLarge.copyWith(
                color: const Color(0xFF00A63E),
              ),
            ),
          ],
        ),
        const SizedBox(height: itemSpacing),

        // Tags/Badges
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tags
                .map(
                  (tag) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4),
                      borderRadius: BorderRadius.circular(badgeBorderRadius),
                    ),
                    child: Text(
                      tag,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
