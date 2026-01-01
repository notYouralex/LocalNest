import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'user_repository.dart';

/// Firestore implementation of UserRepository
class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';

  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserProfile> createUserProfile({
    required String userId,
    required String email,
    required String userType,
    String? displayName,
  }) async {
    try {
      final now = DateTime.now();
      final userProfile = UserProfile(
        id: userId,
        email: email,
        displayName: displayName,
        userType: userType,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set(userProfile.toJson());

      return userProfile;
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserProfile.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      final updatedProfile = userProfile.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_usersCollection)
          .doc(userProfile.id)
          .update(updatedProfile.toJson());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  @override
  Future<UserProfile?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return UserProfile.fromJson(query.docs.first.data(), query.docs.first.id);
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  @override
  Future<bool> userExists(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }
}
