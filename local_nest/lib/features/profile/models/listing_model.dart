/// Listing data model for manage listings
class Listing {
  final String id;
  final String title;
  final String address;
  final String price;
  final String roomType;
  final String available; // e.g., "3/5 slots"
  final int views;
  final int inquiries;
  final bool isActive;
  final DateTime createdAt;

  Listing({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.roomType,
    required this.available,
    required this.views,
    required this.inquiries,
    this.isActive = true,
    required this.createdAt,
  });

  /// Toggle active status
  Listing toggleStatus() => copyWith(isActive: !isActive);

  /// Create a copy with modifications
  Listing copyWith({
    String? id,
    String? title,
    String? address,
    String? price,
    String? roomType,
    String? available,
    int? views,
    int? inquiries,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      price: price ?? this.price,
      roomType: roomType ?? this.roomType,
      available: available ?? this.available,
      views: views ?? this.views,
      inquiries: inquiries ?? this.inquiries,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'address': address,
    'price': price,
    'roomType': roomType,
    'available': available,
    'views': views,
    'inquiries': inquiries,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from JSON
  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
    id: json['id'] as String,
    title: json['title'] as String,
    address: json['address'] as String,
    price: json['price'] as String,
    roomType: json['roomType'] as String,
    available: json['available'] as String,
    views: json['views'] as int? ?? 0,
    inquiries: json['inquiries'] as int? ?? 0,
    isActive: json['isActive'] as bool? ?? true,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}

/// Listings stats summary
class ListingsStats {
  final int activeCount;
  final int totalViews;
  final int totalInquiries;

  ListingsStats({
    required this.activeCount,
    required this.totalViews,
    required this.totalInquiries,
  });

  /// Calculate stats from list of listings
  factory ListingsStats.fromListings(List<Listing> listings) {
    return ListingsStats(
      activeCount: listings.where((l) => l.isActive).length,
      totalViews: listings.fold(0, (sum, l) => sum + l.views),
      totalInquiries: listings.fold(0, (sum, l) => sum + l.inquiries),
    );
  }

  Map<String, dynamic> toJson() => {
    'activeCount': activeCount,
    'totalViews': totalViews,
    'totalInquiries': totalInquiries,
  };

  factory ListingsStats.fromJson(Map<String, dynamic> json) => ListingsStats(
    activeCount: json['activeCount'] as int? ?? 0,
    totalViews: json['totalViews'] as int? ?? 0,
    totalInquiries: json['totalInquiries'] as int? ?? 0,
  );
}
