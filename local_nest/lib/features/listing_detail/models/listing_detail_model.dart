class ListingDetail {
  final String id;
  final String title;
  final String address;
  final String barangay;
  final double price;
  final double rating;
  final int reviewCount;
  final int slotsAvailable;
  final List<String> images;
  final String description;
  final List<String> inclusions;
  final List<String> houseRules;
  final List<String> tags;
  final String landlordName;
  final bool isLandlordVerified;
  final List<NearbyLandmark> nearbyLandmarks;

  ListingDetail({
    required this.id,
    required this.title,
    required this.address,
    required this.barangay,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.slotsAvailable,
    required this.images,
    required this.description,
    required this.inclusions,
    required this.houseRules,
    required this.tags,
    required this.landlordName,
    required this.isLandlordVerified,
    required this.nearbyLandmarks,
  });

  factory ListingDetail.fromJson(Map<String, dynamic> json) {
    return ListingDetail(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      barangay: json['barangay'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      slotsAvailable: json['slotsAvailable'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      description: json['description'] ?? '',
      inclusions: List<String>.from(json['inclusions'] ?? []),
      houseRules: List<String>.from(json['houseRules'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      landlordName: json['landlordName'] ?? '',
      isLandlordVerified: json['isLandlordVerified'] ?? false,
      nearbyLandmarks: (json['nearbyLandmarks'] as List?)
              ?.map((e) => NearbyLandmark.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class NearbyLandmark {
  final String name;
  final String distance;

  NearbyLandmark({
    required this.name,
    required this.distance,
  });

  factory NearbyLandmark.fromJson(Map<String, dynamic> json) {
    return NearbyLandmark(
      name: json['name'] ?? '',
      distance: json['distance'] ?? '',
    );
  }
}
