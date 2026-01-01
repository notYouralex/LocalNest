import 'package:equatable/equatable.dart';

/// User profile model representing a user in the system
class UserProfile extends Equatable {
  final String id; // Firebase user ID
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String userType; // 'renter' or 'landlord'
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  /// Create a copy with optional field updates
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? profileImageUrl,
    String? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'userType': userType,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
    };
  }

  /// Create from Firestore document
  factory UserProfile.fromJson(Map<String, dynamic> json, String docId) {
    return UserProfile(
      id: docId,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      userType: json['userType'] as String? ?? 'renter',
      createdAt: (json['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        phoneNumber,
        profileImageUrl,
        userType,
        createdAt,
        updatedAt,
        isActive,
      ];
}
