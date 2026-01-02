import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/favorites_service.dart';

/// State for favorites - holds list of favorite listing IDs
class FavoritesState {
  final Set<String> favoriteIds;
  final bool isLoading;

  const FavoritesState({
    this.favoriteIds = const {},
    this.isLoading = false,
  });

  FavoritesState copyWith({
    Set<String>? favoriteIds,
    bool? isLoading,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isFavorite(String listingId) => favoriteIds.contains(listingId);
}

/// Cubit that manages favorites state globally across the app
class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesService _favoritesService;
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSubscription;

  FavoritesCubit({
    FavoritesService? favoritesService,
    FirebaseAuth? auth,
  })  : _favoritesService = favoritesService ?? FavoritesServiceImpl(),
        _auth = auth ?? FirebaseAuth.instance,
        super(const FavoritesState()) {
    // Listen to auth changes and reload favorites when user changes
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadFavorites();
      } else {
        emit(const FavoritesState());
      }
    });
    
    // Load favorites if user is already logged in
    if (_auth.currentUser != null) {
      loadFavorites();
    }
  }

  /// Load all favorite IDs for the current user
  Future<void> loadFavorites() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      final favoriteIds = await _favoritesService.getUserFavoriteIds(userId);
      emit(FavoritesState(
        favoriteIds: favoriteIds.toSet(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Toggle favorite status for a listing
  Future<void> toggleFavorite(String listingId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final currentlyFavorite = state.isFavorite(listingId);
    
    // Optimistic update
    final newFavorites = Set<String>.from(state.favoriteIds);
    if (currentlyFavorite) {
      newFavorites.remove(listingId);
    } else {
      newFavorites.add(listingId);
    }
    emit(state.copyWith(favoriteIds: newFavorites));

    try {
      await _favoritesService.toggleFavorite(userId, listingId);
    } catch (e) {
      // Revert on error
      final revertedFavorites = Set<String>.from(state.favoriteIds);
      if (currentlyFavorite) {
        revertedFavorites.add(listingId);
      } else {
        revertedFavorites.remove(listingId);
      }
      emit(state.copyWith(favoriteIds: revertedFavorites));
    }
  }

  /// Check if a listing is favorited
  bool isFavorite(String listingId) => state.isFavorite(listingId);

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
