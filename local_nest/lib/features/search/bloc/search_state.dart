import 'package:equatable/equatable.dart';
import '../../home/models/listing_model.dart';

/// Abstract class for search states
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no search performed
class SearchInitialState extends SearchState {
  const SearchInitialState();
}

/// Loading state - search in progress
class SearchLoadingState extends SearchState {
  const SearchLoadingState();
}

/// Success state - search results available
class SearchSuccessState extends SearchState {
  final List<ListingModel> results;
  final String query;
  final int currentOffset;
  final int totalResults;
  final bool hasMoreResults;

  const SearchSuccessState({
    required this.results,
    required this.query,
    this.currentOffset = 0,
    this.totalResults = 0,
    this.hasMoreResults = false,
  });

  @override
  List<Object?> get props => [results, query, currentOffset, totalResults, hasMoreResults];
}

/// Loading more results state - pagination in progress
class SearchLoadingMoreState extends SearchState {
  final List<ListingModel> currentResults;
  final String query;

  const SearchLoadingMoreState({
    required this.currentResults,
    required this.query,
  });

  @override
  List<Object?> get props => [currentResults, query];
}

/// Error state - search failed
class SearchErrorState extends SearchState {
  final String message;

  const SearchErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for search suggestions
class SearchSuggestionsState extends SearchState {
  final List<String> suggestions;

  const SearchSuggestionsState(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

/// State for popular listings
class PopularListingsState extends SearchState {
  final List<ListingModel> listings;
  final int currentOffset;
  final bool hasMoreResults;

  const PopularListingsState({
    required this.listings,
    this.currentOffset = 0,
    this.hasMoreResults = false,
  });

  @override
  List<Object?> get props => [listings, currentOffset, hasMoreResults];
}
