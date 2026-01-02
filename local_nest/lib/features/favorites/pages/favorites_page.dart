import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_nest/core/widgets/main_navigation_shell.dart';
import '../../../app/theme/theme.dart';
import '../../home/models/listing_model.dart';
import '../../home/widgets/listing_card.dart';
import '../../home/repositories/listing_repository_impl.dart';
import '../../listing_detail/extensions/listing_model_extension.dart';
import '../bloc/favorites_cubit.dart';
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
  final ListingRepositoryImpl _repository = ListingRepositoryImpl();
  List<ListingModel> _allFavoriteListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteListings();
  }

  Future<void> _loadFavoriteListings() async {
    setState(() => _isLoading = true);
    try {
      final listings = await _repository.getFavoriteListings();
      if (mounted) {
        setState(() {
          _allFavoriteListings = listings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesCubit, FavoritesState>(
      listener: (context, state) {
        // Small delay to allow Firestore to complete the operation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _loadFavoriteListings();
          }
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Header with gradient
                  FavoritesHeader(
                    count: _allFavoriteListings.length,
                  ),

                  // Content
                  if (_allFavoriteListings.isEmpty)
                    SliverFillRemaining(
                      child: FavoritesEmptyState(
                        onBrowsePressed: _handleBrowseListings,
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: _buildFavoritesGrid(context, _allFavoriteListings),
                    ),
                ],
              ),
      ),
    );
  }

  /// Favorites grid showing favorite listings
  Widget _buildFavoritesGrid(BuildContext context, List<ListingModel> favoriteListings) {
    return Padding(
      padding: const EdgeInsets.all(FavoritesConstants.contentPadding),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: favoriteListings.length,
        itemBuilder: (context, index) {
          final listing = favoriteListings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FavoriteListingCard(
              listing: listing,
              onTap: () async {
                // Navigate to listing detail page
                final detailModel = await listing.toDetailModelFromFirestore();
                if (context.mounted) {
                  context.push(
                    '/home/listing/${listing.id}',
                    extra: detailModel,
                  );
                }
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