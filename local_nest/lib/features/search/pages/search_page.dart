import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/bloc.dart';
import '../constants/search_constants.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  final SearchRepository? repository;
  final String? initialQuery;

  const SearchPage({super.key, this.repository, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late SearchRepository _repository;
  late SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize repository
    _repository = widget.repository ?? SearchRepositoryImpl();

    // Initialize BLoC
    _searchBloc = SearchBloc(repository: _repository);

    // Load popular listings initially, or search with initial query
    Future.microtask(() {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _searchController.text = widget.initialQuery!;
        _performSearch(widget.initialQuery!);
      } else {
        _searchBloc.add(const GetPopularListingsEvent());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
            filter: state.activeFilter.isActive ? state.activeFilter : null,
            offset: state.currentOffset + SearchConstants.itemsPerPage,
          ),
        );
      }
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _searchBloc.add(const GetPopularListingsEvent());
    } else {
      _searchBloc.add(SearchQueryEvent(query));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch('');
  }

  void _handleFilterTap() {
    final currentState = _searchBloc.state;
    final currentFilter = currentState is SearchSuccessState
        ? currentState.activeFilter
        : const SearchFilter();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Dismiss',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
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
            currentFilter: currentFilter,
            availableAmenities: amenities,
            priceRange: priceRange,
            onApplyFilters: (filter) {
              final currentQuery = _searchController.text;
              _searchBloc.add(
                ApplyFiltersEvent(filter, currentQuery: currentQuery),
              );
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>.value(
      value: _searchBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header with search bar
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              toolbarHeight: SearchConstants.headerHeight,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.primaryGradient,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: SearchConstants.horizontalPadding,
                ),
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
                            color: AppColors.textWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BlocBuilder<SearchBloc, SearchState>(
                          builder: (context, state) {
                            final isFilterActive = state is SearchSuccessState
                                ? state.activeFilter.isActive
                                : false;
                            return SearchBarWidget(
                              controller: _searchController,
                              onChanged: _performSearch,
                              onFilterTap: _handleFilterTap,
                              onClearTap: _clearSearch,
                              showClearButton:
                                  _searchController.text.isNotEmpty,
                              isFilterActive: isFilterActive,
                            );
                          },
                        ),
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
                      return const LoadingStateWidget(
                        message: 'Searching listings...',
                      );
                    }

                    if (state is SearchErrorState) {
                      return ErrorStateWidget(
                        message: state.message,
                        onRetry: () {
                          _searchBloc.add(const GetPopularListingsEvent());
                        },
                      );
                    }

                    if (state is PopularListingsState) {
                      if (state.listings.isEmpty) {
                        return SearchEmptyState(
                          icon: Icons.search,
                          message: SearchConstants.noPopularListingsText,
                        );
                      }

                      return PopularListingsView(listings: state.listings);
                    }

                    if (state is SearchSuccessState) {
                      if (state.results.isEmpty) {
                        return SearchEmptyState(
                          icon: Icons.search_off,
                          message: SearchConstants.noSearchResultsText,
                        );
                      }

                      return SearchResultsView(
                        results: state.results,
                        query: state.query,
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
            SliverToBoxAdapter(child: const SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
