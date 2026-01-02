import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/models/listing_model.dart';
import '../models/models.dart';

/// Extension to convert ListingModel to ListingDetail
extension ListingModelToDetailExtension on ListingModel {
  /// Convert ListingModel to ListingDetail by fetching from Firestore
  Future<ListingDetail> toDetailModelFromFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Fetch the full listing data from Firestore
      final listingDoc = await firestore.collection('listings').doc(id).get();
      
      if (!listingDoc.exists) {
        // Fallback to basic data if Firestore fetch fails
        return _createBasicDetail();
      }
      
      final data = listingDoc.data()!;
      
      // Fetch landlord information
      String landlordName = 'Property Owner';
      String? landlordProfileImageUrl;
      final landlordId = data['landlordId'] as String? ?? '';
      
      if (landlordId.isNotEmpty) {
        try {
          final landlordDoc = await firestore.collection('users').doc(landlordId).get();
          if (landlordDoc.exists) {
            final landlordData = landlordDoc.data()!;
            landlordName = landlordData['displayName'] as String? ?? 
                          landlordData['firstName'] as String? ?? 
                          'Property Owner';
            landlordProfileImageUrl = landlordData['profileImageUrl'] as String?;
          }
        } catch (e) {
          // Silently ignore landlord fetch error
        }
      }
      
      // Get photo URLs and filter out invalid ones
      final photoUrls = List<String>.from(data['photoUrls'] ?? [imageUrl]);
      final validPhotos = photoUrls.where((url) => 
        url.isNotEmpty && 
        !url.contains('via.placeholder.com') &&
        (url.startsWith('http://') || url.startsWith('https://'))
      ).toList();
      
      // If no valid photos, use the main image
      if (validPhotos.isEmpty && imageUrl.isNotEmpty) {
        validPhotos.add(imageUrl);
      }
      
      return ListingDetail(
        id: id,
        title: data['propertyName'] as String? ?? title,
        address: data['completeAddress'] as String? ?? location,
        barangay: data['city'] as String? ?? '',
        price: (data['monthlyRent'] as num?)?.toDouble() ?? price,
        slotsAvailable: data['availableSlots'] as int? ?? 1,
        images: validPhotos,
        description: data['description'] as String? ?? '',
        tags: [
          data['roomType'] as String? ?? 'Room',
          data['genderPreference'] as String? ?? 'Any',
        ],
        landlordId: landlordId,
        landlordName: landlordName,
        landlordProfileImageUrl: landlordProfileImageUrl,
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
      );
    } catch (e) {
      // Silently ignore - return basic detail as fallback
      return _createBasicDetail();
    }
  }
  
  /// Synchronous fallback method (for compatibility)
  ListingDetail toDetailModel() {
    return _createBasicDetail();
  }
  
  /// Create basic detail from available ListingModel data
  ListingDetail _createBasicDetail() {
    return ListingDetail(
      id: id,
      title: title,
      address: location,
      barangay: '',
      price: price,
      slotsAvailable: 1,
      images: [imageUrl].where((url) => url.isNotEmpty).toList(),
      description: '',
      tags: [],
      landlordId: '',
      landlordName: 'Property Owner',
    );
  }
}
