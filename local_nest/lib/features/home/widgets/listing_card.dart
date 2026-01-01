import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_nest/app/theme/app_colors.dart';
import 'package:local_nest/app/theme/app_text_styles.dart';
import 'package:local_nest/features/home/bloc/listing_bloc.dart';
import 'package:local_nest/features/home/bloc/listing_event.dart';
import 'package:local_nest/features/home/models/listing_model.dart';

/// Listing card widget for displaying a single property listing
class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback? onTap;

  const ListingCard({
    Key? key,
    required this.listing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            _buildImageSection(),
            // Content section
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  /// Build image section with availability badge
  Widget _buildImageSection() {
    return Stack(
      children: [
        // Image
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: AppColors.border,
          ),
          child: Image.network(
            listing.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.greenBackground,
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              );
            },
          ),
        ),
        // Availability badge - Green with white text
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successDark,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              listing.isAvailable ? 'Available' : 'Unavailable',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        // Favorite button
        Positioned(
          top: 12,
          left: 12,
          child: _buildFavoriteButton(),
        ),
      ],
    );
  }

  /// Build favorite button
  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: () {
        // This will be handled by BLoC
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            listing.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: listing.isFavorite ? AppColors.error : AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Build content section
  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      listing.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Price - Right aligned
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${listing.price.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '/month',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Divider
          Divider(
            color: AppColors.border,
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 10),
          // Amenities Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: listing.amenities
                .take(3)
                .map((amenity) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _buildAmenityBadge(amenity),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Build amenity badge
  Widget _buildAmenityBadge(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        amenity,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Listing card with BLoC integration for favorite functionality
class ListingCardWithBloc extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteChanged;

  const ListingCardWithBloc({
    Key? key,
    required this.listing,
    this.onTap,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            _buildImageSection(context),
            // Content section
            _buildContentSection(),
          ],
        ),
      ),
    );
  }

  /// Build image section with availability badge
  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Image
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: AppColors.border,
          ),
          child: Image.network(
            listing.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.greenBackground,
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              );
            },
          ),
        ),
        // Availability badge - Green with white text
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successDark,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              listing.isAvailable ? 'Available' : 'Unavailable',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        // Favorite button
        Positioned(
          top: 12,
          left: 12,
          child: _buildFavoriteButton(context),
        ),
      ],
    );
  }

  /// Build favorite button with BLoC integration
  Widget _buildFavoriteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ListingBloc>().add(ToggleFavoriteEvent(listing.id));
        onFavoriteChanged?.call();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            listing.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: listing.isFavorite ? AppColors.error : AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Build content section
  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      listing.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Price - Right aligned
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${listing.price.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '/month',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Divider
          Divider(
            color: AppColors.border,
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 6),
          // Amenities Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: listing.amenities
                .take(3)
                .map((amenity) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _buildAmenityBadge(amenity),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Build amenity badge
  Widget _buildAmenityBadge(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        amenity,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}
