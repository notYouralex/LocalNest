import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_nest/features/home/models/listing_model.dart';
import 'package:local_nest/features/home/bloc/listing_event.dart';
import 'package:local_nest/features/home/bloc/listing_state.dart';
import 'package:local_nest/features/home/repositories/listing_repository.dart';

/// BLoC for managing listing state and business logic
class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final ListingRepository _repository;
  
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
      
      // Update the listing in the current list
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
      }
      
      emit(ListingFavoriteToggledState(updatedListing));
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
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }
}
