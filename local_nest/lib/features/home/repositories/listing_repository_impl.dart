import 'package:local_nest/features/home/models/listing_model.dart';
import 'package:local_nest/features/home/repositories/listing_repository.dart';

/// Implementation of ListingRepository with mock data
class ListingRepositoryImpl implements ListingRepository {
  // Mock data - in production, this would fetch from an API or local database
  static final List<ListingModel> _mockListings = [
    ListingModel(
      id: '1',
      title: 'Green Haven Residence',
      location: 'España Blvd., Sampaloc',
      price: 6500,
      imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=500&h=500&fit=crop',
      rating: 4.8,
      reviewCount: 156,
      amenities: ['Solo', 'WiFi'],
      isAvailable: true,
      isFavorite: false,
    ),
    ListingModel(
      id: '2',
      title: 'Cozy Urban Studio',
      location: 'Recto Ave., Manila',
      price: 5200,
      imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500&h=500&fit=crop',
      rating: 4.5,
      reviewCount: 98,
      amenities: ['WiFi', 'AC'],
      isAvailable: true,
      isFavorite: false,
    ),
    ListingModel(
      id: '3',
      title: 'Modern Loft Space',
      location: 'Shaw Blvd., Mandaluyong',
      price: 7800,
      imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=500&h=500&fit=crop',
      rating: 4.9,
      reviewCount: 203,
      amenities: ['Solo', 'WiFi', 'Kitchen'],
      isAvailable: true,
      isFavorite: false,
    ),
    ListingModel(
      id: '4',
      title: 'Bright Family Home',
      location: 'EDSA, Quezon City',
      price: 8500,
      imageUrl: 'https://images.unsplash.com/photo-1530129387789-4c1017266635?w=500&h=500&fit=crop',
      rating: 4.7,
      reviewCount: 142,
      amenities: ['WiFi', 'AC', 'Parking'],
      isAvailable: false,
      isFavorite: false,
    ),
    ListingModel(
      id: '5',
      title: 'Minimalist Apartment',
      location: 'Makati Ave., Makati',
      price: 9200,
      imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500&h=500&fit=crop',
      rating: 4.6,
      reviewCount: 187,
      amenities: ['Solo', 'WiFi', 'AC'],
      isAvailable: true,
      isFavorite: false,
    ),
  ];

  @override
  Future<List<ListingModel>> fetchListings({
    int limit = 20,
    int offset = 0,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final endIndex = (offset + limit).clamp(0, _mockListings.length);
    return _mockListings.sublist(offset, endIndex);
  }

  @override
  Future<ListingModel> getListingById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _mockListings.firstWhere((listing) => listing.id == id);
    } catch (e) {
      throw Exception('Listing not found');
    }
  }

  @override
  Future<List<ListingModel>> searchListings(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final lowerQuery = query.toLowerCase();
    return _mockListings
        .where((listing) =>
            listing.title.toLowerCase().contains(lowerQuery) ||
            listing.location.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<ListingModel> toggleFavorite(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      final index = _mockListings.indexWhere((listing) => listing.id == id);
      final listing = _mockListings[index];
      final updated = listing.copyWith(isFavorite: !listing.isFavorite);
      _mockListings[index] = updated;
      return updated;
    } catch (e) {
      throw Exception('Failed to toggle favorite');
    }
  }

  @override
  Future<List<ListingModel>> getFavoriteListings() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _mockListings.where((listing) => listing.isFavorite).toList();
  }
}
