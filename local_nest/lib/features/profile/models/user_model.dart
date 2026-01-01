/// User profile data model
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String accountType; // 'renter' or 'landlord'
  final String? profileImageUrl;
  final DateTime? createdAt;
  final bool isVerified;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    this.profileImageUrl,
    this.createdAt,
    this.isVerified = false,
  });

  /// Create a copy with modifications
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? accountType,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      accountType: accountType ?? this.accountType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'accountType': accountType,
    'profileImageUrl': profileImageUrl,
    'createdAt': createdAt?.toIso8601String(),
    'isVerified': isVerified,
  };

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    accountType: json['accountType'] as String,
    profileImageUrl: json['profileImageUrl'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
    isVerified: json['isVerified'] as bool? ?? false,
  );
}

/// User notification settings
class NotificationSettings {
  final bool newListings;
  final bool messages;
  final bool availability;

  NotificationSettings({
    this.newListings = true,
    this.messages = true,
    this.availability = false,
  });

  NotificationSettings copyWith({
    bool? newListings,
    bool? messages,
    bool? availability,
  }) {
    return NotificationSettings(
      newListings: newListings ?? this.newListings,
      messages: messages ?? this.messages,
      availability: availability ?? this.availability,
    );
  }

  Map<String, dynamic> toJson() => {
    'newListings': newListings,
    'messages': messages,
    'availability': availability,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        newListings: json['newListings'] as bool? ?? true,
        messages: json['messages'] as bool? ?? true,
        availability: json['availability'] as bool? ?? false,
      );
}

/// User stats for renter dashboard
class RenterStats {
  final int favorites;
  final int messages;

  RenterStats({
    this.favorites = 0,
    this.messages = 0,
  });

  RenterStats copyWith({
    int? favorites,
    int? messages,
  }) {
    return RenterStats(
      favorites: favorites ?? this.favorites,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() => {
    'favorites': favorites,
    'messages': messages,
  };

  factory RenterStats.fromJson(Map<String, dynamic> json) => RenterStats(
    favorites: json['favorites'] as int? ?? 0,
    messages: json['messages'] as int? ?? 0,
  );
}
