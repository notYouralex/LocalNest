import '../models/user_profile.dart';

/// Abstract repository for user profile data operations
abstract class UserRepository {
  /// Create a new user profile
  Future<UserProfile> createUserProfile({
    required String userId,
    required String email,
    required String userType,
    String? displayName,
  });

  /// Get user profile by ID
  /// Returns null if user profile does not exist
  Future<UserProfile?> getUserProfile(String userId);

  /// Update user profile
  Future<void> updateUserProfile(UserProfile userProfile);

  /// Delete user profile
  Future<void> deleteUserProfile(String userId);

  /// Get user by email
  Future<UserProfile?> getUserByEmail(String email);

  /// Check if user exists
  Future<bool> userExists(String userId);
}
