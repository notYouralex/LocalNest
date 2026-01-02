import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../listing_detail/extensions/listing_model_extension.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';
import '../constants/home_constants.dart';
import '../models/listing_model.dart';
import '../repositories/listing_repository_impl.dart';
import '../widgets/home_filter_modal.dart';
import '../widgets/home_header.dart';
import '../widgets/listing_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ListingBloc _listingBloc;

  @override
  void initState() {
    super.initState();
    _listingBloc = ListingBloc(
      repository: ListingRepositoryImpl(),
    ); // BLoC automatically starts watching listings
  }

  @override
  void dispose() {
    _listingBloc.close();
    super.dispose();
  }

  void _handleSearch(String query) {
    // Navigate to search page with query parameter
    if (query.isNotEmpty) {
      context.go('/home/search', extra: query);
    }
  }

  void _handleFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => HomeFilterModal(
        onApplyFilters: (filters) {
          // Apply filters to listing BLoC
          _listingBloc.add(FilterListingsEvent(
            minPrice: filters['minPrice'] as double?,
            maxPrice: filters['maxPrice'] as double?,
            roomType: filters['roomType'] as String? ?? 'all',
            capacity: filters['capacity'] as String? ?? 'any',
            genderPreference: filters['genderPreference'] as String? ?? 'any',
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListingBloc>.value(
      value: _listingBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // Collapsible Header
            SliverAppBar(
              expandedHeight: HomeConstants.expandedHeaderHeight,
              floating: true,
              pinned: false,
              snap: false,
              backgroundColor: AppColors.background,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: HomeHeader(
                  onSearch: _handleSearch,
                  onFilterTap: _handleFilter,
                ),
                collapseMode: CollapseMode.none,
              ),
            ),
            
            // Content area
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(HomeConstants.contentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HomeConstants.availableListingsTitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    _buildListingsSection(),
                  ],
                ),
              ),
            ),
            
            // Bottom padding for navigation bar
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom +
                    HomeConstants.bottomNavPadding,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build listings section with BLoC state management
  Widget _buildListingsSection() {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        if (state is ListingInitialState || state is ListingLoadingState) {
          return _buildLoadingState();
        }

        if (state is ListingErrorState) {
          return _buildErrorState(state.message);
        }

        if (state is ListingLoadedState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show filter indicator if filters are active
              if (state.isFiltered) _buildFilterIndicator(),
              _buildListingsGrid(context, state.listings),
            ],
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(HomeConstants.cardBorderRadius),
      ),
      padding: const EdgeInsets.all(48),
      child: const LoadingStateWidget(
        message: 'Loading listings...',
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(HomeConstants.cardBorderRadius),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(48),
      child: ErrorStateWidget(
        message: message,
        onRetry: () {
          _listingBloc.add(const RefreshListingsEvent());
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(HomeConstants.cardBorderRadius),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(48),
      child: const EmptyStateWidget(
        title: 'No listings found',
        icon: Icons.search_off,
      ),
    );
  }

  /// Build grid of listing cards
  Widget _buildListingsGrid(BuildContext context, List<ListingModel> listings) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: HomeConstants.gridCrossAxisCount,
        mainAxisSpacing: HomeConstants.gridMainAxisSpacing,
        crossAxisSpacing: 0,
        childAspectRatio: HomeConstants.gridChildAspectRatio,
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return FavoriteListingCard(
          listing: listing,
          onTap: () async {
            // Navigate to listing detail page with converted model
            final detailModel = await listing.toDetailModelFromFirestore();
            if (context.mounted) {
              context.push(
                '/home/listing/${listing.id}',
                extra: detailModel,
              );
            }
          },
          onFavoriteChanged: () {
            // Refresh the listings to get updated favorite status
            context.read<ListingBloc>().add(const RefreshListingsEvent());
          },
        );
      },
    );
  }

  /// Build filter indicator chip
  Widget _buildFilterIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha:0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Filters applied',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                _listingBloc.add(const ClearFiltersEvent());
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}