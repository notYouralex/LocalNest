import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

/// Abstract repository for Firestore listing operations
abstract class FirestoreListingRepository {
  Future<String> createListing(Listing listing);
  Future<void> updateListing(Listing listing);
  Future<void> deleteListing(String listingId);
  Future<Listing?> getListingById(String listingId);
  Future<List<Listing>> getListingsByLandlord(String landlordId);
  Future<List<Listing>> getAllActiveListings();
  Future<List<Listing>> searchListings({
    String? city,
    String? roomType,
    double? minRent,
    double? maxRent,
    String? genderPreference,
  });
  Stream<List<Listing>> watchAllActiveListings();
  Stream<List<Listing>> watchLandlordListings(String landlordId);
}

/// Firestore implementation of Listing operations
class FirestoreListingRepositoryImpl implements FirestoreListingRepository {
  final FirebaseFirestore _firestore;
  
  FirestoreListingRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  CollectionReference<Map<String, dynamic>> get _listingsCollection =>
      _firestore.collection('listings');

  @override
  Future<String> createListing(Listing listing) async {
    try {
      final docRef = await _listingsCollection.add(listing.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  @override
  Future<void> updateListing(Listing listing) async {
    try {
      await _listingsCollection.doc(listing.id).update(
        listing.copyWith(updatedAt: DateTime.now()).toFirestore(),
      );
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  @override
  Future<void> deleteListing(String listingId) async {
    try {
      await _listingsCollection.doc(listingId).delete();
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
    }
  }

  @override
  Future<Listing?> getListingById(String listingId) async {
    try {
      final doc = await _listingsCollection.doc(listingId).get();
      if (doc.exists) {
        return Listing.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get listing: $e');
    }
  }

  @override
  Future<List<Listing>> getListingsByLandlord(String landlordId) async {
    try {
      final snapshot = await _listingsCollection
          .where('landlordId', isEqualTo: landlordId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get landlord listings: $e');
    }
  }

  @override
  Future<List<Listing>> getAllActiveListings() async {
    try {
      final snapshot = await _listingsCollection
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get active listings: $e');
    }
  }

  @override
  Future<List<Listing>> searchListings({
    String? city,
    String? roomType,
    double? minRent,
    double? maxRent,
    String? genderPreference,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _listingsCollection
          .where('status', isEqualTo: 'active');
      
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      
      if (roomType != null && roomType.isNotEmpty) {
        query = query.where('roomType', isEqualTo: roomType);
      }
      
      if (genderPreference != null && genderPreference.isNotEmpty) {
        query = query.where('genderPreference', isEqualTo: genderPreference);
      }
      
      final snapshot = await query.get();
      var listings = snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
      
      // Filter by rent range (Firestore doesn't support range queries on multiple fields)
      if (minRent != null) {
        listings = listings.where((l) => l.monthlyRent >= minRent).toList();
      }
      if (maxRent != null) {
        listings = listings.where((l) => l.monthlyRent <= maxRent).toList();
      }
      
      return listings;
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }

  @override
  Stream<List<Listing>> watchAllActiveListings() {
    return _listingsCollection
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<Listing>> watchLandlordListings(String landlordId) {
    return _listingsCollection
        .where('landlordId', isEqualTo: landlordId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }
}
