import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../home/models/listing_model.dart';
import '../../home/widgets/listing_card.dart';
import '../constants/search_constants.dart';
import '../models/models.dart';
import '../../../app/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

/// Widget that displays search results in a list
class SearchResultsView extends StatelessWidget {
  final List<ListingModel> results;
  final String query;
  final VoidCallback? onListingTap;
  final Function(ListingModel)? onFavoriteTap;

  const SearchResultsView({
    super.key,
    required this.results,
    required this.query,
    this.onListingTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultsHeader(),
        const SizedBox(height: 16),
        _buildResultsList(context),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return Text(
      '${results.length} Properties found',
      style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final listing = results[index];
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
