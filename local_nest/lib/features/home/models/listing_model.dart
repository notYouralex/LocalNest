/// Listing model representing a property listing
class ListingModel {
  final String id;
  final String title;
  final String location;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final bool isAvailable;
  final bool isFavorite;

  const ListingModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    this.isAvailable = true,
    this.isFavorite = false,
  });

  /// Create a copy with optional field updates
  ListingModel copyWith({
    String? id,
    String? title,
    String? location,
    double? price,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    List<String>? amenities,
    bool? isAvailable,
    bool? isFavorite,
  }) {
    return ListingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      amenities: amenities ?? this.amenities,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          location == other.location &&
          price == other.price &&
          imageUrl == other.imageUrl &&
          rating == other.rating &&
          reviewCount == other.reviewCount &&
          amenities == other.amenities &&
          isAvailable == other.isAvailable &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      location.hashCode ^
      price.hashCode ^
      imageUrl.hashCode ^
      rating.hashCode ^
      reviewCount.hashCode ^
      amenities.hashCode ^
      isAvailable.hashCode ^
      isFavorite.hashCode;
}
