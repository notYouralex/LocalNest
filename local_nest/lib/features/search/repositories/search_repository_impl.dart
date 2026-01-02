import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../../home/models/listing_model.dart';
import '../../listings/repositories/firestore_listing_repository.dart';
import '../../listings/extensions/listing_extensions.dart';
import '../../favorites/services/favorites_service.dart';
import 'search_repository.dart';

/// Concrete implementation of SearchRepository
/// Now uses Firestore instead of mock data
class SearchRepositoryImpl implements SearchRepository {
  final FirestoreListingRepository _firestoreRepo;
  final FavoritesService _favoritesService;
  final FirebaseAuth _auth;

  SearchRepositoryImpl({
    FirestoreListingRepository? firestoreRepo,
    FavoritesService? favoritesService,
    FirebaseAuth? auth,
  })  : _firestoreRepo = firestoreRepo ?? FirestoreListingRepositoryImpl(),
        _favoritesService = favoritesService ?? FavoritesServiceImpl(),
        _auth = auth ?? FirebaseAuth.instance;

  /// Get the current user's favorite IDs
  Future<List<String>> _getFavoriteIds() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];
    return await _favoritesService.getUserFavoriteIds(userId);
  }

  @override
  Future<List<ListingModel>> searchListings(
    String query, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final listings = await _firestoreRepo.getAllActiveListings();
      final favoriteIds = await _getFavoriteIds();
      
      if (query.isEmpty) {
        // Return all active listings with favorite status
        return listings.map((l) => l.toListingModel(favoriteIds: favoriteIds)).toList();
      }
      
      // Filter by query
      final lowerQuery = query.toLowerCase();
      final results = listings
          .where((listing) =>
              listing.propertyName.toLowerCase().contains(lowerQuery) ||
              listing.city.toLowerCase().contains(lowerQuery) ||
              listing.completeAddress.toLowerCase().contains(lowerQuery))
          .map((listing) => listing.toListingModel(favoriteIds: favoriteIds))
          .toList();

      // TODO: Implement pagination with offset
      return results;
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }

  @override
  Future<List<ListingModel>> searchWithFilters(
    String query,
    SearchFilter filter, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // Convert gender preference to database format
      // Filter uses 'male'/'female', database stores 'Male Only'/'Female Only'
      String? dbGenderPreference;
      if (filter.genderPreference == 'male') {
        dbGenderPreference = 'Male Only';
      } else if (filter.genderPreference == 'female') {
        dbGenderPreference = 'Female Only';
      }
      
      // Convert room type to database format (capitalize first letter)
      String? dbRoomType;
      if (filter.roomType != 'all') {
        dbRoomType = filter.roomType[0].toUpperCase() + filter.roomType.substring(1);
      }
      
      // Use Firestore's searchListings method with filters
      final listings = await _firestoreRepo.searchListings(
        city: null,
        roomType: dbRoomType,
        minRent: filter.minPrice,
        maxRent: filter.maxPrice,
        genderPreference: dbGenderPreference,
      );
      
      final favoriteIds = await _getFavoriteIds();

      // Convert to ListingModel with favorite status
      var results = listings.map((l) => l.toListingModel(favoriteIds: favoriteIds)).toList();

      // Apply additional query filtering if needed
      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        results = results
            .where((listing) =>
                listing.title.toLowerCase().contains(lowerQuery) ||
                listing.location.toLowerCase().contains(lowerQuery))
            .toList();
      }

      // Apply capacity filter (client-side)
      if (filter.capacity != 'any') {
        final minCapacity = _parseCapacity(filter.capacity);
        results = results
            .where((listing) => listing.availableSlots >= minCapacity)
            .toList();
      }

      // TODO: Apply amenities filter (need to add amenities to Listing model)
      
      // TODO: Implement pagination with offset
      return results;
    } catch (e) {
      throw Exception('Failed to search with filters: $e');
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

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final listings = await _firestoreRepo.getAllActiveListings();
      final suggestions = listings
          .expand((listing) => [listing.propertyName, listing.city])
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toSet()
          .toList();
      return suggestions;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> getAvailableAmenities() async {
    // TODO: Get amenities from Firestore or config
    return const [
      'WiFi',
      'Air Conditioning',
      'Kitchen',
      'Parking',
      'Laundry',
      'Security',
      'Water Supply',
      'Furnished',
    ];
  }

  @override
  Future<Map<String, double>> getPriceRange() async {
    try {
      final listings = await _firestoreRepo.getAllActiveListings();
      if (listings.isEmpty) {
        return {'min': 1000.0, 'max': 50000.0};
      }
      
      final prices = listings.map((l) => l.monthlyRent).toList();
      return {
        'min': prices.reduce((a, b) => a < b ? a : b),
        'max': prices.reduce((a, b) => a > b ? a : b),
      };
    } catch (e) {
      return {'min': 1000.0, 'max': 50000.0};
    }
  }
}
