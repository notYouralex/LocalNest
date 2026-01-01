import '../../home/models/listing_model.dart';
import '../../listing_detail/models/listing_detail_model.dart';
import '../models/listing.dart';

/// Extension to convert Firestore Listing to UI models
extension ListingToUIExtension on Listing {
  /// Convert to ListingModel for cards (home/search)
  ListingModel toListingModel() {
    return ListingModel(
      id: id,
      title: propertyName,
      location: '$city, $completeAddress',
      price: monthlyRent,
      imageUrl: photoUrls.isNotEmpty ? photoUrls[0] : '',
      amenities: _extractAmenities(),
      isAvailable: status == 'active' && availableSlots > 0,
      isFavorite: false, // TODO: Check from favorites service
    );
  }

  /// Convert to ListingDetail for detail page
  ListingDetail toListingDetail({
    String? landlordName,
    bool isLandlordVerified = false,
  }) {
    return ListingDetail(
      id: id,
      title: propertyName,
      address: completeAddress,
      barangay: city,
      price: monthlyRent,
      slotsAvailable: availableSlots,
      images: photoUrls.isNotEmpty ? photoUrls : ['https://via.placeholder.com/440x320'],
      description: description,
      inclusions: _getDefaultInclusions(),
      houseRules: _getDefaultHouseRules(),
      tags: _extractTags(),
      landlordName: landlordName ?? 'Property Owner',
      isLandlordVerified: isLandlordVerified,
      nearbyLandmarks: [], // TODO: Add to Listing model or fetch separately
    );
  }

  /// Extract amenities from room type and other fields
  List<String> _extractAmenities() {
    final amenities = <String>[roomType];
    
    // Add based on room type
    if (roomType == 'Solo' || roomType == 'Studio') {
      amenities.add('Private Space');
    }
    if (roomType == 'Shared') {
      amenities.add('Shared Room');
    }
    
    // Add gender preference as amenity
    if (genderPreference != 'Any') {
      amenities.add(genderPreference);
    }
    
    return amenities;
  }

  /// Extract tags from listing properties
  List<String> _extractTags() {
    final tags = <String>[
      roomType.toLowerCase(),
      genderPreference.toLowerCase().replaceAll(' ', '-'),
    ];
    
    if (availableSlots > 0) {
      tags.add('available');
    }
    
    return tags;
  }

  /// Default inclusions (TODO: add to Listing model)
  List<String> _getDefaultInclusions() {
    return [
      'Water',
      'Electricity',
      'Security',
    ];
  }

  /// Default house rules (TODO: add to Listing model)
  List<String> _getDefaultHouseRules() {
    return [
      'Respect quiet hours',
      'Keep common areas clean',
      'No illegal activities',
    ];
  }
}
