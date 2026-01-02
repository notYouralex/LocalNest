import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_nest/features/home/models/listing_model.dart';
import 'package:local_nest/features/home/bloc/listing_event.dart';
import 'package:local_nest/features/home/bloc/listing_state.dart';
import 'package:local_nest/features/home/repositories/listing_repository.dart';

/// BLoC for managing listing state and business logic
class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final ListingRepository _repository;
  StreamSubscription<List<ListingModel>>? _listingsSubscription;
  
  int _currentOffset = 0;
  List<ListingModel> _allListings = [];
  static const int _pageSize = 20;

  ListingBloc({required ListingRepository repository})
      : _repository = repository,
        super(const ListingInitialState()) {
    on<FetchListingsEvent>(_onFetchListings);
    on<LoadMoreListingsEvent>(_onLoadMoreListings);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<SearchListingsEvent>(_onSearchListings);
    on<GetFavoriteListingsEvent>(_onGetFavoriteListings);
    on<RefreshListingsEvent>(_onRefreshListings);
    on<WatchListingsEvent>(_onWatchListings);
    
    // Start watching listings immediately
    add(const WatchListingsEvent());
  }

  /// Handle fetch listings event
  Future<void> _onFetchListings(
    FetchListingsEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      emit(const ListingLoadingState());
      
      _currentOffset = event.offset;
      final listings = await _repository.fetchListings(
        limit: event.limit,
        offset: event.offset,
      );
      
      _allListings = listings;
      emit(ListingLoadedState(
        listings: listings,
        hasMoreData: listings.length >= _pageSize,
      ));
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }

  /// Handle load more listings event
  Future<void> _onLoadMoreListings(
    LoadMoreListingsEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      if (state is ListingLoadedState) {
        final currentState = state as ListingLoadedState;
        emit(ListingLoadingMoreState(currentState.listings));

        _currentOffset += _pageSize;
        final newListings = await _repository.fetchListings(
          limit: _pageSize,
          offset: _currentOffset,
        );

        final allListings = [...currentState.listings, ...newListings];
        emit(ListingLoadedState(
          listings: allListings,
          hasMoreData: newListings.length >= _pageSize,
        ));
      }
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }

  /// Handle toggle favorite event
  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      final updatedListing = await _repository.toggleFavorite(event.listingId);
      
      // Update the listing in the current list and keep favorites in sync
      if (state is ListingLoadedState) {
        final currentState = state as ListingLoadedState;
        final updatedListings = currentState.listings.map((listing) {
          if (listing.id == event.listingId) {
            return updatedListing;
          }
          return listing;
        }).toList();
        
        emit(ListingLoadedState(
          listings: updatedListings,
          hasMoreData: currentState.hasMoreData,
        ));
      } else if (state is ListingSearchResultsState) {
        // Also update search results if they exist
        final currentState = state as ListingSearchResultsState;
        final updatedResults = currentState.results.map((listing) {
          if (listing.id == event.listingId) {
            return updatedListing;
          }
          return listing;
        }).toList();
        
        emit(ListingSearchResultsState(updatedResults));
      } else if (state is ListingFavoritesState) {
        // Update favorites list - remove if unfavorited
        final currentState = state as ListingFavoritesState;
        
        if (updatedListing.isFavorite) {
          // Still favorited - just update the listing
          final updatedFavorites = currentState.favorites.map((listing) {
            if (listing.id == event.listingId) {
              return updatedListing;
            }
            return listing;
          }).toList();
          emit(ListingFavoritesState(updatedFavorites));
        } else {
          // Unfavorited - remove from the list
          final updatedFavorites = currentState.favorites
              .where((listing) => listing.id != event.listingId)
              .toList();
          emit(ListingFavoritesState(updatedFavorites));
        }
      }
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }

  /// Handle search listings event
  Future<void> _onSearchListings(
    SearchListingsEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        emit(ListingLoadedState(listings: _allListings));
      } else {
        emit(const ListingLoadingState());
        final results = await _repository.searchListings(event.query);
        emit(ListingSearchResultsState(results));
      }
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }

  /// Handle get favorite listings event
  Future<void> _onGetFavoriteListings(
    GetFavoriteListingsEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      emit(const ListingLoadingState());
      final favorites = await _repository.getFavoriteListings();
      emit(ListingFavoritesState(favorites));
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }

  /// Handle refresh listings event
  Future<void> _onRefreshListings(
    RefreshListingsEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      // Use cached listings from stream if available
      if (_allListings.isNotEmpty) {
        emit(ListingLoadedState(
          listings: _allListings,
          hasMoreData: _allListings.length >= _pageSize,
        ));
      } else {
        // Fallback to fetching if no cached data
        _currentOffset = 0;
        final listings = await _repository.fetchListings(
          limit: _pageSize,
          offset: 0,
        );
        
        _allListings = listings;
        emit(ListingLoadedState(
          listings: listings,
          hasMoreData: listings.length >= _pageSize,
        ));
      }
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }

  /// Handle watch listings event - subscribes to real-time updates
  Future<void> _onWatchListings(
    WatchListingsEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      emit(const ListingLoadingState());
      
      await _listingsSubscription?.cancel();
      _listingsSubscription = _repository.watchListings().listen(
        (listings) {
          _allListings = listings;
          add(const RefreshListingsEvent()); // Trigger UI update
        },
        onError: (error) {
          emit(ListingErrorState(error.toString()));
        },
      );
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _listingsSubscription?.cancel();
    return super.close();
  }
}
