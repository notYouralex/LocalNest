import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';
import '../repositories/listing_repository_impl.dart';
import '../widgets/home_header.dart';
import '../widgets/listing_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _handleSearch(String query) {
    // Navigate to search page with query parameter
    context.push('/search?q=$query');
  }

  void _handleFilter() {
    // TODO: Show filter modal
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListingBloc(
        repository: ListingRepositoryImpl(),
      )..add(const FetchListingsEvent()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // Collapsible Header
            SliverAppBar(
              expandedHeight: 220,
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Listings',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildListingsSection(),
                  ],
                ),
              ),
            ),
            
            // Bottom padding for navigation bar
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 80,
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
        if (state is ListingInitialState) {
          return Container(
            
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is ListingLoadingState) {
          return Container(
            
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is ListingLoadedState) {
          return _buildListingsGrid(context, state.listings);
        } else if (state is ListingErrorState) {
          return Container(
            
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading listings',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ListingBloc>().add(const RefreshListingsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'No listings found',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  /// Build grid of listing cards
  Widget _buildListingsGrid(BuildContext context, List listings) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 0,
        childAspectRatio: 1.1,
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return ListingCardWithBloc(
          listing: listing,
          onTap: () {
            // TODO: Navigate to listing detail page
            // context.push('/listing/${listing.id}');
          },
          onFavoriteChanged: () {
            // Favorite status changed - can add custom logic here
          },
        );
      },
    );
  }
}