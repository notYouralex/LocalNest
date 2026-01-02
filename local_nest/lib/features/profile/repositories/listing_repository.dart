import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../listings/models/listing.dart';
import '../../listings/repositories/firestore_listing_repository.dart';

/// Listing Repository for Add/Edit Listing operations
/// This wraps FirestoreListingRepository and CloudinaryService for form submissions
abstract class ListingRepository {
  Future<String> addListing(Map<String, dynamic> listingData, List<String> imagePaths);
  Future<void> updateListing(String listingId, Map<String, dynamic> listingData);
  Future<void> deleteListing(String listingId);
}

class ListingRepositoryImpl implements ListingRepository {
  final FirestoreListingRepository _firestoreRepo;
  final CloudinaryService _cloudinaryService;
  final FirebaseAuth _auth;
  
  ListingRepositoryImpl({
    FirestoreListingRepository? firestoreRepo,
    CloudinaryService? cloudinaryService,
    FirebaseAuth? auth,
  })  : _firestoreRepo = firestoreRepo ?? FirestoreListingRepositoryImpl(),
        _cloudinaryService = cloudinaryService ?? CloudinaryService(),
        _auth = auth ?? FirebaseAuth.instance;
  
  @override
  Future<String> addListing(Map<String, dynamic> listingData, List<String> imagePaths) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // 1. Upload images to Cloudinary
      final photoUrls = await _cloudinaryService.uploadImages(
        imagePaths,
        folder: 'localnest/listings',
      );
      
      // 2. Create Listing object
      final now = DateTime.now();
      final listing = Listing(
        id: '', // Will be assigned by Firestore
        landlordId: currentUser.uid,
        propertyName: listingData['propertyName'] as String? ?? '',
        completeAddress: listingData['completeAddress'] as String? ?? '',
        city: listingData['city'] as String? ?? '',
        description: listingData['description'] as String? ?? '',
        latitude: listingData['latitude'] as double?,
        longitude: listingData['longitude'] as double?,
        monthlyRent: (listingData['monthlyRent'] as num?)?.toDouble() ?? 0,
        roomType: listingData['roomType'] as String? ?? 'Solo',
        availableSlots: listingData['availableSlots'] as int? ?? 0,
        totalSlots: listingData['totalSlots'] as int? ?? 0,
        genderPreference: listingData['genderPreference'] as String? ?? 'Any',
        photoUrls: photoUrls,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );
      
      // 3. Save to Firestore
      final listingId = await _firestoreRepo.createListing(listing);
      
      return listingId;
    } catch (e) {
      throw Exception('Failed to add listing: $e');
    }
  }

  @override
  Future<void> updateListing(String listingId, Map<String, dynamic> listingData) async {
    try {
      final existingListing = await _firestoreRepo.getListingById(listingId);
      if (existingListing == null) {
        throw Exception('Listing not found');
      }
      
      // Get photoUrls from form data
      List<String> photoUrls = List<String>.from(listingData['photoUrls'] as List? ?? existingListing.photoUrls);
      
      // Check if any photos are local files (need to be uploaded)
      final localPaths = <String>[];
      final existingUrls = <String>[];
      
      for (final path in photoUrls) {
        if (path.startsWith('http://') || path.startsWith('https://')) {
          existingUrls.add(path);
        } else {
          localPaths.add(path);
        }
      }
      
      // Upload any new local images to Cloudinary
      if (localPaths.isNotEmpty) {
        final uploadedUrls = await _cloudinaryService.uploadImages(
          localPaths,
          folder: 'localnest/listings',
        );
        existingUrls.addAll(uploadedUrls);
      }
      
      photoUrls = existingUrls;
      
      // Update listing
      final updatedListing = existingListing.copyWith(
        propertyName: listingData['propertyName'] as String?,
        completeAddress: listingData['completeAddress'] as String?,
        city: listingData['city'] as String?,
        description: listingData['description'] as String?,
        latitude: listingData['latitude'] as double?,
        longitude: listingData['longitude'] as double?,
        monthlyRent: (listingData['monthlyRent'] as num?)?.toDouble(),
        roomType: listingData['roomType'] as String?,
        availableSlots: listingData['availableSlots'] as int?,
        totalSlots: listingData['totalSlots'] as int?,
        genderPreference: listingData['genderPreference'] as String?,
        photoUrls: photoUrls,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreRepo.updateListing(updatedListing);
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  @override
  Future<void> deleteListing(String listingId) async {
    try {
      await _firestoreRepo.deleteListing(listingId);
      // Note: Images remain in Cloudinary - can be cleaned up manually or via backend
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
    }
  }
}
