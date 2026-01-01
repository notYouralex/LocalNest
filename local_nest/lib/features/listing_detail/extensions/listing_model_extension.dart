import '../../home/models/listing_model.dart';
import '../models/models.dart';

/// Extension to convert ListingModel to ListingDetail
extension ListingModelToDetailExtension on ListingModel {
  /// Convert ListingModel to ListingDetail
  ListingDetail toDetailModel() {
    return ListingDetail(
      id: id,
      title: title,
      address: location,
      barangay: 'Barangay Sampaloc', // TODO: Add to ListingModel
      price: price.toDouble(),
      slotsAvailable: 2, // TODO: Add to ListingModel
      images: [
        imageUrl,
        'https://via.placeholder.com/440x320?text=Property+2',
        'https://via.placeholder.com/440x320?text=Property+3',
      ],
      description: 'Clean and safe boarding house near UST. Perfect for students.',
      inclusions: [
        'Water',
        'WiFi',
        'Electricity (up to ₱1000)',
      ],
      houseRules: [
        'No smoking inside',
        'Curfew at 10 PM',
        'Visitors allowed until 8 PM',
      ],
      tags: [
        'shared',
        'WiFi',
        'Private CR',
        'female only',
      ],
      landlordName: 'Maria Santos',
      isLandlordVerified: true,
      nearbyLandmarks: [
        NearbyLandmark(
          name: 'University of Santo Tomas',
          distance: '0.5 km',
        ),
        NearbyLandmark(
          name: 'España LRT Station',
          distance: '0.8 km',
        ),
        NearbyLandmark(
          name: 'SM City Manila',
          distance: '2.1 km',
        ),
      ],
    );
  }
}
