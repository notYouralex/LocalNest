import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/repositories.dart';
import 'search_event.dart';
import 'search_state.dart';

/// BLoC for managing search functionality
/// Handles search queries, filtering, and pagination
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repository;

  SearchBloc({required this.repository}) : super(const SearchInitialState()) {
    // Register event handlers
    on<GetPopularListingsEvent>(_onGetPopularListings);
    on<SearchQueryEvent>(_onSearchQuery);
    on<SearchWithFiltersEvent>(_onSearchWithFilters);
    on<LoadMoreSearchResultsEvent>(_onLoadMoreResults);
    on<GetSearchSuggestionsEvent>(_onGetSuggestions);
    on<ClearSearchEvent>(_onClearSearch);
  }

  /// Handle getting popular listings
  Future<void> _onGetPopularListings(
    GetPopularListingsEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());

    try {
      final results = await repository.getPopularListings(
        limit: event.limit,
        offset: event.offset,
      );

      emit(PopularListingsState(
        listings: results,
        currentOffset: event.offset,
        hasMoreResults: results.length == event.limit,
      ));
    } catch (e) {
      emit(SearchErrorState('Failed to load popular listings: ${e.toString()}'));
    }
  }

  /// Handle search by query
  Future<void> _onSearchQuery(
    SearchQueryEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());

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
    emit(const SearchInitialState());
  }
}
