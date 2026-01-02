import 'package:local_nest/features/home/models/listing_model.dart';

/// Abstract repository interface for listing data
abstract class ListingRepository {
  /// Fetch listings with optional filters
  Future<List<ListingModel>> fetchListings({
    int limit = 20,
    int offset = 0,
  });

  /// Get a single listing by ID
  Future<ListingModel> getListingById(String id);

  /// Search listings by query
  Future<List<ListingModel>> searchListings(String query);

  /// Toggle favorite status for a listing
  Future<ListingModel> toggleFavorite(String id);

  /// Get favorite listings
  Future<List<ListingModel>> getFavoriteListings();
  
  /// Watch listings stream for real-time updates
  Stream<List<ListingModel>> watchListings();
}
