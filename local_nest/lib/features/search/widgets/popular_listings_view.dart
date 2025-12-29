import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../home/models/listing_model.dart';
import '../../home/widgets/listing_card.dart';
import '../constants/search_constants.dart';
import '../../../app/theme/theme.dart';

/// Widget that displays popular listings in a list
class PopularListingsView extends StatelessWidget {
  final List<ListingModel> listings;
  final VoidCallback? onListingTap;
  final Function(ListingModel)? onFavoriteTap;

  const PopularListingsView({
    super.key,
    required this.listings,
    this.onListingTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildListingsList(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Text(
      SearchConstants.popularListingsTitle,
      style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildListingsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return Padding(
          padding: const EdgeInsets.only(
            bottom: SearchConstants.itemSpacing,
          ),
          child: ListingCardWithBloc(
            listing: listing,
            onTap: () {
              context.push('/home/listing/${listing.id}');
              onListingTap?.call();
            },
            onFavoriteChanged: () {
              onFavoriteTap?.call(listing);
            },
          ),
        );
      },
    );
  }
}
