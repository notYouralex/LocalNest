import '../models/models.dart';
import '../../home/models/listing_model.dart';
import '../../listings/repositories/firestore_listing_repository.dart';
import '../../listings/extensions/listing_extensions.dart';
import 'search_repository.dart';

/// Concrete implementation of SearchRepository
/// Now uses Firestore instead of mock data
class SearchRepositoryImpl implements SearchRepository {
  final FirestoreListingRepository _firestoreRepo;

  SearchRepositoryImpl({FirestoreListingRepository? firestoreRepo})
      : _firestoreRepo = firestoreRepo ?? FirestoreListingRepositoryImpl();

  @override
  Future<List<ListingModel>> searchListings(
    String query, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final listings = await _firestoreRepo.getAllActiveListings();
      
      if (query.isEmpty) {
        // Return all active listings
        return listings.map((l) => l.toListingModel()).toList();
      }
      
      // Filter by query
      final lowerQuery = query.toLowerCase();
      final results = listings
          .where((listing) =>
              listing.propertyName.toLowerCase().contains(lowerQuery) ||
              listing.city.toLowerCase().contains(lowerQuery) ||
              listing.completeAddress.toLowerCase().contains(lowerQuery))
          .map((listing) => listing.toListingModel())
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
      // Use Firestore's searchListings method with filters
      final listings = await _firestoreRepo.searchListings(
        city: query.isNotEmpty ? null : null, // TODO: parse city from query
        roomType: filter.roomType != 'all' ? filter.roomType : null,
        minRent: filter.minPrice,
        maxRent: filter.maxPrice,
      );

      // Convert to ListingModel
      var results = listings.map((l) => l.toListingModel()).toList();

      // Apply additional query filtering if needed
      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        results = results
            .where((listing) =>
                listing.title.toLowerCase().contains(lowerQuery) ||
                listing.location.toLowerCase().contains(lowerQuery))
            .toList();
      }

      // TODO: Apply amenities filter (need to add amenities to Listing model)
      
      // TODO: Implement pagination with offset
      return results;
    } catch (e) {
      throw Exception('Failed to search with filters: $e');
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
