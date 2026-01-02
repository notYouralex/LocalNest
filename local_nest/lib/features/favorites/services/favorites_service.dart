import 'package:cloud_firestore/cloud_firestore.dart';

/// Abstract interface for favorites service
abstract class FavoritesService {
  /// Add a listing to user's favorites
  Future<void> addFavorite(String userId, String listingId);

  /// Remove a listing from user's favorites
  Future<void> removeFavorite(String userId, String listingId);

  /// Check if a listing is in user's favorites
  Future<bool> isFavorite(String userId, String listingId);

  /// Get all favorite listing IDs for a user
  Future<List<String>> getUserFavoriteIds(String userId);

  /// Toggle favorite status (add if not exists, remove if exists)
  Future<bool> toggleFavorite(String userId, String listingId);

  /// Watch favorites count in real-time
  Stream<int> watchFavoritesCount(String userId);
}

/// Firestore implementation of favorites service
class FavoritesServiceImpl implements FavoritesService {
  final FirebaseFirestore _firestore;

  FavoritesServiceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get the document ID for a favorite (userId__listingId)
  String _getFavoriteDocId(String userId, String listingId) {
    return '${userId}__$listingId';
  }

  @override
  Future<void> addFavorite(String userId, String listingId) async {
    try {
      final docId = _getFavoriteDocId(userId, listingId);
      await _firestore.collection('favorites').doc(docId).set({
        'userId': userId,
        'listingId': listingId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(String userId, String listingId) async {
    try {
      final docId = _getFavoriteDocId(userId, listingId);
      await _firestore.collection('favorites').doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite(String userId, String listingId) async {
    try {
      final docId = _getFavoriteDocId(userId, listingId);
      final doc = await _firestore.collection('favorites').doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  @override
  Future<List<String>> getUserFavoriteIds(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['listingId'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to get user favorites: $e');
    }
  }

  @override
  Future<bool> toggleFavorite(String userId, String listingId) async {
    try {
      final isFav = await isFavorite(userId, listingId);
      
      if (isFav) {
        await removeFavorite(userId, listingId);
        return false; // Now not favorited
      } else {
        await addFavorite(userId, listingId);
        return true; // Now favorited
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Stream<int> watchFavoritesCount(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
