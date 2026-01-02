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
  
  // Current filter state
  double? _currentMinPrice;
  double? _currentMaxPrice;
  String _currentRoomType = 'all';
  String _currentCapacity = 'any';
  String _currentGenderPreference = 'any';
  bool _isFiltered = false;

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
    on<FilterListingsEvent>(_onFilterListings);
    on<ClearFiltersEvent>(_onClearFilters);
    
    // Start watching listings immediately
    add(const WatchListingsEvent());
  }
  
  /// Getter to check if filters are active
  bool get isFiltered => _isFiltered;

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
        isFiltered: _isFiltered,
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
          isFiltered: currentState.isFiltered,
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
          isFiltered: currentState.isFiltered,
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
        emit(ListingLoadedState(listings: _allListings, isFiltered: _isFiltered));
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
          isFiltered: _isFiltered,
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
          isFiltered: _isFiltered,
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
          // If filters are active, apply them; otherwise just refresh
          if (_isFiltered) {
            add(FilterListingsEvent(
              minPrice: _currentMinPrice,
              maxPrice: _currentMaxPrice,
              roomType: _currentRoomType,
              capacity: _currentCapacity,
              genderPreference: _currentGenderPreference,
            ));
          } else {
            add(const RefreshListingsEvent()); // Trigger UI update
          }
        },
        onError: (error) {
          emit(ListingErrorState(error.toString()));
        },
      );
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }

  /// Handle filter listings event - filters cached listings based on criteria
  Future<void> _onFilterListings(
    FilterListingsEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      // Store filter state
      _currentMinPrice = event.minPrice;
      _currentMaxPrice = event.maxPrice;
      _currentRoomType = event.roomType;
      _currentCapacity = event.capacity;
      _currentGenderPreference = event.genderPreference;
      
      // Check if any filters are active
      _isFiltered = event.minPrice != null ||
          event.maxPrice != null ||
          event.roomType != 'all' ||
          event.capacity != 'any' ||
          event.genderPreference != 'any';

      // Filter the cached listings with null-safe checks
      List<ListingModel> filteredListings = _allListings.where((listing) {
        try {
          // Price filter - use price as fallback for monthlyRent
          final rent = listing.monthlyRent;
          if (event.minPrice != null && rent < event.minPrice!) {
            return false;
          }
          if (event.maxPrice != null && rent > event.maxPrice!) {
            return false;
          }

          // Room type filter
          if (event.roomType != 'all') {
            final listingRoomType = (listing.roomType).toLowerCase();
            final filterRoomType = event.roomType.toLowerCase();
            
            // Match room types - handle "solo" matching "single"
            if (filterRoomType == 'solo' && listingRoomType != 'solo' && listingRoomType != 'single') {
              return false;
            } else if (filterRoomType == 'shared' && listingRoomType != 'shared') {
              return false;
            } else if (filterRoomType == 'studio' && listingRoomType != 'studio') {
              return false;
            } else if (filterRoomType == 'apartment' && listingRoomType != 'apartment') {
              return false;
            }
          }

          // Capacity filter (available slots)
          if (event.capacity != 'any') {
            final minCapacity = _parseCapacity(event.capacity);
            if (listing.availableSlots < minCapacity) {
              return false;
            }
          }

          // Gender preference filter
          if (event.genderPreference != 'any') {
            final listingGender = listing.genderPreference.toLowerCase();
            final filterGender = event.genderPreference.toLowerCase();
            
            // Database stores 'Any', 'Male Only', 'Female Only'
            // Filter uses 'any', 'male', 'female'
            
            // If listing is 'any', it's available to all genders
            if (listingGender == 'any') {
              // Include this listing
            } else if (filterGender == 'male' && listingGender.startsWith('male')) {
              // Include male only listings when filtering for male
            } else if (filterGender == 'female' && listingGender.startsWith('female')) {
              // Include female only listings when filtering for female
            } else {
              // Exclude if gender doesn't match
              return false;
            }
          }

          return true;
        } catch (e) {
          // If any error occurs during filtering, include the listing
          return true;
        }
      }).toList();

      emit(ListingLoadedState(
        listings: filteredListings,
        hasMoreData: false, // Disable pagination for filtered results
        isFiltered: _isFiltered,
      ));
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }

  /// Helper to parse capacity string to minimum value
  int _parseCapacity(String capacity) {
    switch (capacity) {
      case '1+':
        return 1;
      case '2+':
        return 2;
      case '4+':
        return 4;
      default:
        return 0;
    }
  }

  /// Handle clear filters event
  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<ListingState> emit,
  ) async {
    _currentMinPrice = null;
    _currentMaxPrice = null;
    _currentRoomType = 'all';
    _currentCapacity = 'any';
    _currentGenderPreference = 'any';
    _isFiltered = false;

    emit(ListingLoadedState(
      listings: _allListings,
      hasMoreData: _allListings.length >= _pageSize,
      isFiltered: false,
    ));
  }

  @override
  Future<void> close() {
    _listingsSubscription?.cancel();
    return super.close();
  }
}
