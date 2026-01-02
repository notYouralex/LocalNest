class ListingDetail {
  final String id;
  final String title;
  final String address;
  final String barangay;
  final double price;
  final int slotsAvailable;
  final List<String> images;
  final String description;
  final List<String> tags;
  final String landlordId;
  final String landlordName;
  final String? landlordProfileImageUrl;
  final double? latitude;
  final double? longitude;

  ListingDetail({
    required this.id,
    required this.title,
    required this.address,
    required this.barangay,
    required this.price,
    required this.slotsAvailable,
    required this.images,
    required this.description,
    required this.tags,
    this.landlordId = '',
    required this.landlordName,
    this.landlordProfileImageUrl,
    this.latitude,
    this.longitude,
  });

  factory ListingDetail.fromJson(Map<String, dynamic> json) {
    return ListingDetail(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      barangay: json['barangay'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      slotsAvailable: json['slotsAvailable'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      landlordId: json['landlordId'] ?? json['userId'] ?? '',
      landlordName: json['landlordName'] ?? '',
      landlordProfileImageUrl: json['landlordProfileImageUrl'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}


