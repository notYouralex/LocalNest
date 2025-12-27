import '../models/models.dart';
import '../../home/models/listing_model.dart';
import 'search_repository.dart';

/// Concrete implementation of SearchRepository
/// Uses mock data for demonstration
class SearchRepositoryImpl implements SearchRepository {
  // Mock available amenities
  static const List<String> _availableAmenities = [
    'WiFi',
    'Air Conditioning',
    'Kitchen',
    'Parking',
    'Laundry',
    'Security',
    'Water Supply',
    'Furnished',
  ];

  // Mock price range
  static const Map<String, double> _priceRange = {
    'min': 1000.0,
    'max': 50000.0,
  };

  // Sample listings from home feature
  final List<ListingModel> _mockListings = [
    ListingModel(
      id: '1',
      title: 'Sunny Studio on Elm Street',
      location: '123 P. Noval St., Sampaloc',
      price: 5500,
      imageUrl: 'https://via.placeholder.com/300x400?text=Studio+1',
      rating: 4.5,
      reviewCount: 24,
      amenities: const ['WiFi', 'Air Conditioning', 'Furnished'],
      isAvailable: true,
      isFavorite: false,
    ),
    ListingModel(
      id: '2',
      title: 'Cozy Haven Boarding House',
      location: '456 Lacson Ave., Sampaloc',
      price: 4200,
      imageUrl: 'https://via.placeholder.com/300x400?text=House+1',
      rating: 4.8,
      reviewCount: 56,
      amenities: const ['WiFi', 'Kitchen', 'Parking'],
      isAvailable: true,
      isFavorite: false,
    ),
    ListingModel(
      id: '3',
      title: 'Modern Apartment Suite',
      location: '789 España Blvd., Sampaloc',
      price: 12000,
      imageUrl: 'https://via.placeholder.com/300x400?text=Room+1',
      rating: 4.2,
      reviewCount: 15,
      amenities: const ['WiFi', 'Shared Kitchen', 'Laundry'],
      isAvailable: true,
      isFavorite: false,
    ),
    ListingModel(
      id: '4',
      title: 'Luxury Penthouse',
      location: 'City Center',
      price: 45000,
      imageUrl: 'https://via.placeholder.com/300x400?text=Penthouse+1',
      rating: 4.9,
      reviewCount: 89,
      amenities: const ['WiFi', 'Air Conditioning', 'Parking', 'Security'],
      isAvailable: true,
      isFavorite: false,
    ),
    ListingModel(
      id: '5',
      title: 'Budget Boarding House',
      location: 'Outskirts',
      price: 3500,
      imageUrl: 'https://via.placeholder.com/300x400?text=Budget+1',
      rating: 3.8,
      reviewCount: 32,
      amenities: const ['Water Supply', 'Security'],
      isAvailable: true,
      isFavorite: false,
    ),
    ListingModel(
      id: '6',
      title: 'Spacious 2BR House',
      location: 'Suburban Area',
      price: 15000,
      imageUrl: 'https://via.placeholder.com/300x400?text=House+2',
      rating: 4.6,
      reviewCount: 42,
      amenities: const ['WiFi', 'Kitchen', 'Parking', 'Garden'],
      isAvailable: true,
      isFavorite: false,
    ),
    ListingModel(
      id: '7',
      title: 'Cozy Bedroom in Shared House',
      location: 'College Town',
      price: 5000,
      imageUrl: 'https://via.placeholder.com/300x400?text=Room+2',
      rating: 4.3,
      reviewCount: 18,
      amenities: const ['WiFi', 'Shared Kitchen', 'Laundry'],
      isAvailable: true,
      isFavorite: false,
    ),
    ListingModel(
      id: '8',
      title: 'Premium Studio Loft',
      location: 'Downtown District',
      price: 8500,
      imageUrl: 'https://via.placeholder.com/300x400?text=Studio+2',
      rating: 4.7,
      reviewCount: 28,
      amenities: const ['WiFi', 'Air Conditioning', 'Furnished'],
      isAvailable: true,
      isFavorite: false,
    ),
  ];

  @override
  Future<List<ListingModel>> getPopularListings({
    int limit = 10,
    int offset = 0,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Sort by rating and return paginated results
    final sorted = List<ListingModel>.from(_mockListings)
      ..sort((a, b) => b.rating.compareTo(a.rating));

    final start = offset;
    final end = (offset + limit).clamp(0, sorted.length);

    return sorted.sublist(start, end);
  }

  @override
  Future<List<ListingModel>> searchListings(
    String query, {
    int limit = 10,
    int offset = 0,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter listings based on query
    final results = _mockListings
        .where((listing) =>
            listing.title.toLowerCase().contains(query.toLowerCase()) ||
            listing.location.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Apply pagination
    final start = offset;
    final end = (offset + limit).clamp(0, results.length);

    return results.sublist(start, end);
  }

  @override
  Future<List<ListingModel>> searchWithFilters(
    String query,
    SearchFilter filter, {
    int limit = 10,
    int offset = 0,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    // First search by query
    var results = _mockListings
        .where((listing) =>
            listing.title.toLowerCase().contains(query.toLowerCase()) ||
            listing.location.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Apply price filters
    if (filter.minPrice != null) {
      results =
          results.where((listing) => listing.price >= filter.minPrice!).toList();
    }

    if (filter.maxPrice != null) {
      results =
          results.where((listing) => listing.price <= filter.maxPrice!).toList();
    }

    // Apply amenities filter
    if (filter.amenities.isNotEmpty) {
      results = results
          .where((listing) => filter.amenities
              .every((amenity) => listing.amenities.contains(amenity)))
          .toList();
    }

    // Apply pagination
    final start = offset;
    final end = (offset + limit).clamp(0, results.length);

    return results.sublist(start, end);
  }

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Generate suggestions based on titles and locations
    final suggestions = _mockListings
        .expand((listing) => [listing.title, listing.location])
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toSet()
        .toList();

    return suggestions;
  }

  @override
  Future<List<String>> getAvailableAmenities() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _availableAmenities;
  }

  @override
  Future<Map<String, double>> getPriceRange() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _priceRange;
  }
}
