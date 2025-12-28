import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_nest/core/widgets/main_navigation_shell.dart';
import '../../../app/theme/theme.dart';
import '../../home/bloc/listing_bloc.dart';
import '../../home/bloc/listing_event.dart';
import '../../home/bloc/listing_state.dart';
import '../../home/widgets/listing_card.dart';
import '../constants/favorites_constants.dart';
import '../widgets/favorites_empty_state.dart';
import '../widgets/favorites_header.dart';

/// Favorites page showing saved listings
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // Load favorites when page is initialized
    context.read<ListingBloc>().add(const GetFavoriteListingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        final favorites = state is ListingFavoritesState ? state.favorites : [];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // Header with gradient
              FavoritesHeader(
                count: favorites.length,
              ),

              // Content
              if (favorites.isEmpty)
                SliverFillRemaining(
                  child: FavoritesEmptyState(
                    onBrowsePressed: _handleBrowseListings,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: _buildFavoritesGrid(context, favorites),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Favorites grid showing favorite listings
  Widget _buildFavoritesGrid(BuildContext context, List favorites) {
    return Padding(
      padding: const EdgeInsets.all(FavoritesConstants.contentPadding),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final listing = favorites[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListingCardWithBloc(
              listing: listing,
              onTap: () {
                // Navigate to listing detail page with converted model
                context.push(
                  '/home/listing/${listing.id}',
                  extra: listing.toDetailModel(),
                );
              },
              onFavoriteChanged: () {
                // Reload favorites after toggling
                context.read<ListingBloc>().add(const GetFavoriteListingsEvent());
              },
            ),
          );
        },
      ),
    );
  }

  void _handleBrowseListings() {
    MainNavigationShell.switchToTab(context, 1); // Search tab
  }
}