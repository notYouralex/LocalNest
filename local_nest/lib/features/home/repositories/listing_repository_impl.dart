import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_nest/features/home/models/listing_model.dart';
import 'package:local_nest/features/home/repositories/listing_repository.dart';
import '../../listings/repositories/firestore_listing_repository.dart';
import '../../listings/extensions/listing_extensions.dart';
import '../../favorites/services/favorites_service.dart';

/// Implementation of ListingRepository
/// Now uses Firestore instead of mock data
class ListingRepositoryImpl implements ListingRepository {
  final FirestoreListingRepository _firestoreRepo;
  final FavoritesService _favoritesService;
  final FirebaseAuth _auth;

  ListingRepositoryImpl({
    FirestoreListingRepository? firestoreRepo,
    FavoritesService? favoritesService,
    FirebaseAuth? auth,
  })  : _firestoreRepo = firestoreRepo ?? FirestoreListingRepositoryImpl(),
        _favoritesService = favoritesService ?? FavoritesServiceImpl(),
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<List<ListingModel>> fetchListings({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final listings = await _firestoreRepo.getAllActiveListings();
      
      // Get user's favorite IDs
      final userId = _auth.currentUser?.uid;
      final favoriteIds = userId != null 
          ? await _favoritesService.getUserFavoriteIds(userId)
          : <String>[];
      
      // TODO: Implement pagination with offset
      return listings
          .map((listing) => listing.toListingModel(favoriteIds: favoriteIds))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch listings: $e');
    }
  }

  @override
  Future<ListingModel> getListingById(String id) async {
    try {
      final listing = await _firestoreRepo.getListingById(id);
      if (listing == null) {
        throw Exception('Listing not found');
      }
      
      // Get user's favorite IDs
      final userId = _auth.currentUser?.uid;
      final favoriteIds = userId != null 
          ? await _favoritesService.getUserFavoriteIds(userId)
          : <String>[];
      
      return listing.toListingModel(favoriteIds: favoriteIds);
    } catch (e) {
      throw Exception('Failed to get listing: $e');
    }
  }

  @override
  Future<List<ListingModel>> searchListings(String query) async {
    try {
      // For now, get all listings and filter client-side
      // TODO: Implement server-side search
      final listings = await _firestoreRepo.getAllActiveListings();
      
      // Get user's favorite IDs
      final userId = _auth.currentUser?.uid;
      final favoriteIds = userId != null 
          ? await _favoritesService.getUserFavoriteIds(userId)
          : <String>[];
      
      final lowerQuery = query.toLowerCase();
      return listings
          .where((listing) =>
              listing.propertyName.toLowerCase().contains(lowerQuery) ||
              listing.city.toLowerCase().contains(lowerQuery) ||
              listing.completeAddress.toLowerCase().contains(lowerQuery))
          .map((listing) => listing.toListingModel(favoriteIds: favoriteIds))
          .toList();
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }

  @override
  Future<ListingModel> toggleFavorite(String id) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User must be logged in to toggle favorites');
      }
      
      // Toggle favorite in Firestore
      await _favoritesService.toggleFavorite(userId, id);
      
      // Get the listing with updated favorite status
      final listing = await _firestoreRepo.getListingById(id);
      if (listing == null) {
        throw Exception('Listing not found');
      }
      
      // Get user's favorite IDs for consistency
      final favoriteIds = await _favoritesService.getUserFavoriteIds(userId);
      
      return listing.toListingModel(favoriteIds: favoriteIds);
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<ListingModel>> getFavoriteListings() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return []; // Return empty if not logged in
      }
      
      // Get user's favorite listing IDs
      final favoriteIds = await _favoritesService.getUserFavoriteIds(userId);
      
      if (favoriteIds.isEmpty) {
        return [];
      }
      
      // Fetch all favorite listings
      final favoriteListings = <ListingModel>[];
      for (final listingId in favoriteIds) {
        try {
          final listing = await _firestoreRepo.getListingById(listingId);
          if (listing != null) {
            favoriteListings.add(
              listing.toListingModel(favoriteIds: favoriteIds),
            );
          }
        } catch (e) {
          // Skip listings that can't be fetched (e.g., deleted)
          continue;
        }
      }
      
      return favoriteListings;
    } catch (e) {
      throw Exception('Failed to get favorite listings: $e');
    }
  }

  @override
  Stream<List<ListingModel>> watchListings() async* {
    try {
      final userId = _auth.currentUser?.uid;
      
      await for (final listings in _firestoreRepo.watchAllActiveListings()) {
        // Get user's favorite IDs for each update
        final favoriteIds = userId != null 
            ? await _favoritesService.getUserFavoriteIds(userId)
            : <String>[];
        
        yield listings
            .map((listing) => listing.toListingModel(favoriteIds: favoriteIds))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to watch listings: $e');
    }
  }
}
