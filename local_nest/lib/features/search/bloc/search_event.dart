import 'package:equatable/equatable.dart';
import '../models/models.dart';

/// Abstract class for search events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to get popular listings
class GetPopularListingsEvent extends SearchEvent {
  final int limit;
  final int offset;

  const GetPopularListingsEvent({
    this.limit = 10,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [limit, offset];
}

/// Event to search listings by query
class SearchQueryEvent extends SearchEvent {
  final String query;
  final int limit;
  final int offset;

  const SearchQueryEvent(
    this.query, {
    this.limit = 10,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, limit, offset];
}

/// Event to search with filters applied
class SearchWithFiltersEvent extends SearchEvent {
  final String query;
  final SearchFilter filter;
  final int limit;
  final int offset;

  const SearchWithFiltersEvent(
    this.query,
    this.filter, {
    this.limit = 10,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, filter, limit, offset];
}

/// Event to load more search results (pagination)
class LoadMoreSearchResultsEvent extends SearchEvent {
  final String query;
  final SearchFilter? filter;
  final int limit;
  final int offset;

  const LoadMoreSearchResultsEvent(
    this.query, {
    this.filter,
    this.limit = 10,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, filter, limit, offset];
}

/// Event to get search suggestions
class GetSearchSuggestionsEvent extends SearchEvent {
  final String query;

  const GetSearchSuggestionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to clear search results
class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}

/// Event to apply filters to current search
class ApplyFiltersEvent extends SearchEvent {
  final SearchFilter filter;
  final String? currentQuery;

  const ApplyFiltersEvent(
    this.filter, {
    this.currentQuery,
  });

  @override
  List<Object?> get props => [filter, currentQuery];
}

/// Event to clear applied filters
class ClearFiltersEvent extends SearchEvent {
  final String? currentQuery;

  const ClearFiltersEvent({this.currentQuery});

  @override
  List<Object?> get props => [currentQuery];
}
