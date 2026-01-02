import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'search_event.dart';
import 'search_state.dart';

/// BLoC for managing search functionality
/// Handles search queries, filtering, and pagination
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repository;
  SearchFilter _currentFilter = const SearchFilter();

  SearchBloc({required this.repository}) : super(const SearchInitialState()) {
    // Register event handlers
    on<SearchQueryEvent>(_onSearchQuery);
    on<SearchWithFiltersEvent>(_onSearchWithFilters);
    on<LoadMoreSearchResultsEvent>(_onLoadMoreResults);
    on<GetSearchSuggestionsEvent>(_onGetSuggestions);
    on<ClearSearchEvent>(_onClearSearch);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ClearFiltersEvent>(_onClearFilters);
  }

  /// Handle search by query
  Future<void> _onSearchQuery(
    SearchQueryEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());
    _currentFilter = const SearchFilter();

    try {
      final results = await repository.searchListings(
        event.query,
        limit: event.limit,
        offset: event.offset,
      );

      emit(SearchSuccessState(
        results: results,
        query: event.query,
        currentOffset: event.offset,
        totalResults: results.length,
        hasMoreResults: results.length == event.limit,
        activeFilter: _currentFilter,
      ));
    } catch (e) {
      emit(SearchErrorState('Failed to search: ${e.toString()}'));
    }
  }

  /// Handle search with filters
  Future<void> _onSearchWithFilters(
    SearchWithFiltersEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());
    _currentFilter = event.filter;

    try {
      final results = await repository.searchWithFilters(
        event.query,
        event.filter,
        limit: event.limit,
        offset: event.offset,
      );

      emit(SearchSuccessState(
        results: results,
        query: event.query,
        currentOffset: event.offset,
        totalResults: results.length,
        hasMoreResults: results.length == event.limit,
        activeFilter: event.filter,
      ));
    } catch (e) {
      emit(SearchErrorState('Failed to search with filters: ${e.toString()}'));
    }
  }

  /// Handle loading more results (pagination)
  Future<void> _onLoadMoreResults(
    LoadMoreSearchResultsEvent event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is SearchSuccessState) {
      emit(SearchLoadingMoreState(
        currentResults: currentState.results,
        query: event.query,
        activeFilter: _currentFilter,
      ));

      try {
        final newResults = event.filter != null
            ? await repository.searchWithFilters(
                event.query,
                event.filter!,
                limit: event.limit,
                offset: event.offset,
              )
            : await repository.searchListings(
                event.query,
                limit: event.limit,
                offset: event.offset,
              );

        final allResults = [...currentState.results, ...newResults];

        emit(SearchSuccessState(
          results: allResults,
          query: event.query,
          currentOffset: event.offset,
          totalResults: allResults.length,
          hasMoreResults: newResults.length == event.limit,
          activeFilter: _currentFilter,
        ));
      } catch (e) {
        emit(SearchErrorState('Failed to load more results: ${e.toString()}'));
      }
    }
  }

  /// Handle getting search suggestions
  Future<void> _onGetSuggestions(
    GetSearchSuggestionsEvent event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final suggestions = await repository.getSearchSuggestions(event.query);
      emit(SearchSuggestionsState(suggestions));
    } catch (e) {
      emit(SearchErrorState('Failed to get suggestions: ${e.toString()}'));
    }
  }

  /// Handle clearing search
  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilter = const SearchFilter();
    emit(const SearchInitialState());
  }

  /// Handle applying filters
  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilter = event.filter;

    // Always search with filters (even with empty query to filter all listings)
    emit(const SearchLoadingState());
    try {
      final query = event.currentQuery ?? '';
      final results = await repository.searchWithFilters(
        query,
        event.filter,
        limit: 10,
        offset: 0,
      );

      emit(SearchSuccessState(
        results: results,
        query: query,
        currentOffset: 0,
        totalResults: results.length,
        hasMoreResults: results.length == 10,
        activeFilter: event.filter,
      ));
    } catch (e) {
      emit(SearchErrorState('Failed to apply filters: ${e.toString()}'));
    }
  }

  /// Handle clearing filters
  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilter = const SearchFilter();

    // If there's a current query, search without filters
    if (event.currentQuery != null && event.currentQuery!.isNotEmpty) {
      emit(const SearchLoadingState());
      try {
        final results = await repository.searchListings(
          event.currentQuery!,
          limit: 10,
          offset: 0,
        );

        emit(SearchSuccessState(
          results: results,
          query: event.currentQuery!,
          currentOffset: 0,
          totalResults: results.length,
          hasMoreResults: results.length == 10,
          activeFilter: const SearchFilter(),
        ));
      } catch (e) {
        emit(SearchErrorState('Failed to clear filters: ${e.toString()}'));
      }
    }
  }
}
