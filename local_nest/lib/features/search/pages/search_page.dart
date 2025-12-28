import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/bloc/listing_bloc.dart';
import '../../home/repositories/listing_repository_impl.dart';
import '../../home/widgets/listing_card.dart';
import '../bloc/bloc.dart';
import '../constants/search_constants.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  final SearchRepository? repository;
  final String? initialQuery;

  const SearchPage({
    super.key,
    this.repository,
    this.initialQuery,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late SearchRepository _repository;
  late SearchBloc _searchBloc;
  SearchFilter _currentFilter = const SearchFilter();
  String _currentQuery = '';
  bool _isFiltering = false;

  // Debounce timer for search
  Future<void>? _debounceSearch;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize repository
    _repository = widget.repository ?? SearchRepositoryImpl();

    // Initialize BLoC
    _searchBloc = SearchBloc(repository: _repository)
      ..add(const GetPopularListingsEvent());

    // Load popular listings initially, or search with initial query
    Future.microtask(() {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _searchController.text = widget.initialQuery!;
        _handleSearch(widget.initialQuery!);
      } else {
        _searchBloc.add(const GetPopularListingsEvent());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceSearch?.ignore();
    _searchBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent -
            SearchConstants.paginationThreshold) {
      final state = _searchBloc.state;

      if (state is SearchSuccessState && state.hasMoreResults) {
        _searchBloc.add(
          LoadMoreSearchResultsEvent(
            state.query,
            filter: _isFiltering ? _currentFilter : null,
            offset: state.currentOffset + SearchConstants.itemsPerPage,
          ),
        );
      }
    }
  }

  void _handleSearch(String query) {
    // Cancel previous debounce
    _debounceSearch?.ignore();

    // Debounce search requests
    _debounceSearch = Future.delayed(
      Duration(milliseconds: SearchConstants.searchDebounceMs),
      () {
        if (!mounted) return;

        if (query.isEmpty) {
          _searchBloc.add(const GetPopularListingsEvent());
          setState(() {
            _currentQuery = '';
            _isFiltering = false;
          });
        } else {
          _currentQuery = query;
          if (_isFiltering) {
            _searchBloc.add(
              SearchWithFiltersEvent(query, _currentFilter),
            );
          } else {
            _searchBloc.add(SearchQueryEvent(query));
          }
        }
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _handleSearch('');
  }

  void _handleFilterTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SearchConstants.filterModalBorderRadius),
          topRight: Radius.circular(SearchConstants.filterModalBorderRadius),
        ),
      ),
      builder: (context) => FutureBuilder(
        future: Future.wait([
          _repository.getAvailableAmenities(),
          _repository.getPriceRange(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: SearchConstants.largeIconSize,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load filters',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final amenities = snapshot.data![0] as List<String>;
          final priceRange = snapshot.data![1] as Map<String, double>;

          return FilterModal(
            currentFilter: _currentFilter,
            availableAmenities: amenities,
            priceRange: priceRange,
            onApplyFilters: (filter) {
              setState(() {
                _currentFilter = filter;
                _isFiltering = true;
              });

              if (_currentQuery.isNotEmpty) {
                _searchBloc.add(
                  SearchWithFiltersEvent(_currentQuery, filter),
                );
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListingBloc>(
      create: (context) => ListingBloc(
        repository: ListingRepositoryImpl(),
      ),
      child: BlocProvider<SearchBloc>.value(
        value: _searchBloc,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header with search bar and filter icon
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                pinned: true,
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 0,
                toolbarHeight: SearchConstants.headerHeight,
                flexibleSpace: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.symmetric(
                      horizontal: SearchConstants.horizontalPadding),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Search Results',
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        // Search Bar with Filter Icon
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildSearchBar(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SearchConstants.horizontalPadding,
                    vertical: SearchConstants.verticalPadding,
                  ),
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if (state is SearchLoadingState) {
                        return _buildLoadingState();
                      }

                      if (state is SearchErrorState) {
                        return _buildErrorState(state.message);
                      }

                      if (state is PopularListingsState) {
                        if (state.listings.isEmpty) {
                          return _buildEmptyState(
                            icon: Icons.search,
                            message: SearchConstants.noPopularListingsText,
                          );
                        }

                        return _buildResults(
                          state.listings,
                          SearchConstants.popularListingsTitle,
                        );
                      }

                      if (state is SearchSuccessState) {
                        if (state.results.isEmpty) {
                          return _buildEmptyState(
                            icon: Icons.search_off,
                            message: SearchConstants.noSearchResultsText,
                          );
                        }

                        return _buildResults(
                          state.results,
                          '${state.results.length} Properties found',
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

            // Loading indicator for pagination
            SliverToBoxAdapter(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoadingMoreState) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Bottom padding
            SliverToBoxAdapter(
              child: const SizedBox(height: 32),
            ),
          ],
        ),
      ),
        ),
    );
  }

  Widget _buildResults(List listings, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: SearchConstants.itemSpacing),
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
                  // Favorite status changed
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: SearchConstants.searchBarHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(SearchConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Icon
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: SearchConstants.iconSize,
            ),
          ),
          // Input Field
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: SearchConstants.searchHintText,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),
          // Clear Button
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: _clearSearch,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: SearchConstants.iconSize,
                ),
              ),
            ),
          // Filter Button
          GestureDetector(
            onTap: _handleFilterTap,
            child: Semantics(
              label: 'Open filters',
              button: true,
              enabled: true,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.tune,
                  color: AppColors.primary,
                  size: SearchConstants.filterIconSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const LoadingStateWidget(
      message: 'Searching listings...',
    );
  }

  Widget _buildErrorState(String message) {
    return ErrorStateWidget(
      message: message,
      onRetry: () {
        _searchBloc.add(const GetPopularListingsEvent());
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return EmptyStateWidget(
      title: message,
      icon: icon,
    );
  }
}
