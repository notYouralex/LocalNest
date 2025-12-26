import 'package:equatable/equatable.dart';
import 'package:local_nest/features/home/models/listing_model.dart';

/// Base state for listing BLoC
abstract class ListingState extends Equatable {
  const ListingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ListingInitialState extends ListingState {
  const ListingInitialState();
}

/// Loading state
class ListingLoadingState extends ListingState {
  const ListingLoadingState();
}

/// Loaded state with listings
class ListingLoadedState extends ListingState {
  final List<ListingModel> listings;
  final bool hasMoreData;

  const ListingLoadedState({
    required this.listings,
    this.hasMoreData = true,
  });

  @override
  List<Object?> get props => [listings, hasMoreData];
}

/// Loading more listings state
class ListingLoadingMoreState extends ListingState {
  final List<ListingModel> currentListings;

  const ListingLoadingMoreState(this.currentListings);

  @override
  List<Object?> get props => [currentListings];
}

/// Error state
class ListingErrorState extends ListingState {
  final String message;

  const ListingErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Favorite toggled state
class ListingFavoriteToggledState extends ListingState {
  final ListingModel listing;

  const ListingFavoriteToggledState(this.listing);

  @override
  List<Object?> get props => [listing];
}

/// Search results state
class ListingSearchResultsState extends ListingState {
  final List<ListingModel> results;

  const ListingSearchResultsState(this.results);

  @override
  List<Object?> get props => [results];
}

/// Favorites list state
class ListingFavoritesState extends ListingState {
  final List<ListingModel> favorites;

  const ListingFavoritesState(this.favorites);

  @override
  List<Object?> get props => [favorites];
}
