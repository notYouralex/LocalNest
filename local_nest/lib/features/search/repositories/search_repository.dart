import '../models/models.dart';
import '../../home/models/listing_model.dart';

/// Abstract repository interface for search operations
/// Following Dependency Inversion Principle (DIP)
abstract class SearchRepository {
  /// Get popular listings
  Future<List<ListingModel>> getPopularListings({
    int limit = 10,
    int offset = 0,
  });

  /// Search listings by query
  Future<List<ListingModel>> searchListings(
    String query, {
    int limit = 10,
    int offset = 0,
  });

  /// Search with filters applied
  Future<List<ListingModel>> searchWithFilters(
    String query,
    SearchFilter filter, {
    int limit = 10,
    int offset = 0,
  });

  /// Get search suggestions based on query
  Future<List<String>> getSearchSuggestions(String query);

  /// Get available amenities for filtering
  Future<List<String>> getAvailableAmenities();

  /// Get price range for filtering
  Future<Map<String, double>> getPriceRange();
}
