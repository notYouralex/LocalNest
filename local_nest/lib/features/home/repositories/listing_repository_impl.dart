import 'package:local_nest/features/home/models/listing_model.dart';
import 'package:local_nest/features/home/repositories/listing_repository.dart';
import '../../listings/repositories/firestore_listing_repository.dart';
import '../../listings/extensions/listing_extensions.dart';

/// Implementation of ListingRepository
/// Now uses Firestore instead of mock data
class ListingRepositoryImpl implements ListingRepository {
  final FirestoreListingRepository _firestoreRepo;

  ListingRepositoryImpl({FirestoreListingRepository? firestoreRepo})
      : _firestoreRepo = firestoreRepo ?? FirestoreListingRepositoryImpl();

  @override
  Future<List<ListingModel>> fetchListings({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final listings = await _firestoreRepo.getAllActiveListings();
      // TODO: Implement pagination with offset
      return listings.map((listing) => listing.toListingModel()).toList();
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
      return listing.toListingModel();
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
      final lowerQuery = query.toLowerCase();
      return listings
          .where((listing) =>
              listing.propertyName.toLowerCase().contains(lowerQuery) ||
              listing.city.toLowerCase().contains(lowerQuery) ||
              listing.completeAddress.toLowerCase().contains(lowerQuery))
          .map((listing) => listing.toListingModel())
          .toList();
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }

  @override
  Future<ListingModel> toggleFavorite(String id) async {
    // TODO: Implement favorites service with Firestore
    try {
      final listing = await getListingById(id);
      return listing.copyWith(isFavorite: !listing.isFavorite);
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<ListingModel>> getFavoriteListings() async {
    // TODO: Implement favorites service with Firestore
    // For now, return empty list
    return [];
  }
}
