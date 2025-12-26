import 'package:equatable/equatable.dart';

/// Base event for listing BLoC
abstract class ListingEvent extends Equatable {
  const ListingEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch listings with pagination
class FetchListingsEvent extends ListingEvent {
  final int limit;
  final int offset;

  const FetchListingsEvent({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [limit, offset];
}

/// Load more listings
class LoadMoreListingsEvent extends ListingEvent {
  const LoadMoreListingsEvent();
}

/// Toggle favorite status for a listing
class ToggleFavoriteEvent extends ListingEvent {
  final String listingId;

  const ToggleFavoriteEvent(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

/// Search listings by query
class SearchListingsEvent extends ListingEvent {
  final String query;

  const SearchListingsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Get favorite listings
class GetFavoriteListingsEvent extends ListingEvent {
  const GetFavoriteListingsEvent();
}

/// Refresh listings
class RefreshListingsEvent extends ListingEvent {
  const RefreshListingsEvent();
}
