import 'package:flutter/material.dart';
import '../../models/listing_model.dart';
import '../../constants/manage_listings_constants.dart';
import '../../../../app/theme/theme.dart';
import 'detail_column.dart';
import 'action_button.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const ListingCard({
    required this.listing,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = listing.isActive;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
          width: ManageListingsConstants.borderWidth,
        ),
        borderRadius: BorderRadius.circular(
          ManageListingsConstants.cardBorderRadius,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(ManageListingsConstants.cardSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and status badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.successDark
                            : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(
                          ManageListingsConstants.badgeBorderRadius,
                        ),
                      ),
                      child: Text(
                        isActive
                            ? ManageListingsConstants.activeLabel
                            : ManageListingsConstants.inactiveLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  listing.address,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: ManageListingsConstants.cardSpacing),
                // Details grid
                Row(
                  children: [
                    Expanded(
                      child: DetailColumn(
                        ManageListingsConstants.priceLabel,
                        listing.price,
                        isPrimary: true,
                      ),
                    ),
                    Expanded(
                      child: DetailColumn(
                        ManageListingsConstants.roomTypeLabel,
                        listing.roomType,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ManageListingsConstants.itemSpacing),
                Row(
                  children: [
                    Expanded(
                      child: DetailColumn(
                        ManageListingsConstants.availableLabel,
                        listing.available,
                      ),
                    ),
                    Expanded(
                      child: DetailColumn(
                        ManageListingsConstants.viewsLabel,
                        listing.views.toString(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.border,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ManageListingsConstants.cardSpacing,
              vertical: ManageListingsConstants.itemSpacing,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: ManageListingsConstants.iconSize,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(
                  width: ManageListingsConstants.itemSpacing,
                ),
                Text(
                  '${listing.views} views',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(
                  width: ManageListingsConstants.cardSpacing,
                ),
                Icon(
                  Icons.mail_outline,
                  size: ManageListingsConstants.iconSize,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(
                  width: ManageListingsConstants.itemSpacing,
                ),
                Text(
                  '${listing.inquiries} inquiries',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ManageListingsConstants.itemSpacing),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ManageListingsConstants.cardSpacing,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ActionButton(
                    label: ManageListingsConstants.editButton,
                    icon: Icons.edit_outlined,
                    onTap: onEdit,
                  ),
                ),
                const SizedBox(width: ManageListingsConstants.itemSpacing),
                Expanded(
                  child: ActionButton(
                    label: isActive
                        ? ManageListingsConstants.deactivateButton
                        : ManageListingsConstants.activateButton,
                    icon: isActive ? Icons.pause_circle_outline : Icons.check_circle_outline,
                    onTap: onToggleStatus,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ManageListingsConstants.itemSpacing),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ManageListingsConstants.cardSpacing,
              vertical: ManageListingsConstants.itemSpacing,
            ),
            child: ActionButton(
              label: ManageListingsConstants.deleteButton,
              icon: Icons.delete_outline,
              onTap: onDelete,
              backgroundColor: AppColors.error.withOpacity(0.1),
              iconColor: AppColors.error,
              textColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
