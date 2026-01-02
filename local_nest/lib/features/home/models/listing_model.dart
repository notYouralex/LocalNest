/// Listing model representing a property listing
class ListingModel {
  final String id;
  final String title;
  final String location;
  final double price;
  final String imageUrl;
  final List<String> amenities;
  final bool isAvailable;
  final bool isFavorite;
  
  // Additional fields for filtering
  final String roomType;
  final int availableSlots;
  final String genderPreference;
  final double monthlyRent; // Alias for price for filtering clarity

  const ListingModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.amenities,
    this.isAvailable = true,
    this.isFavorite = false,
    this.roomType = 'Solo',
    this.availableSlots = 1,
    this.genderPreference = 'Any',
    double? monthlyRent,
  }) : monthlyRent = monthlyRent ?? price;

  /// Create a copy with optional field updates
  ListingModel copyWith({
    String? id,
    String? title,
    String? location,
    double? price,
    String? imageUrl,
    List<String>? amenities,
    bool? isAvailable,
    bool? isFavorite,
    String? roomType,
    int? availableSlots,
    String? genderPreference,
  }) {
    return ListingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      amenities: amenities ?? this.amenities,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      roomType: roomType ?? this.roomType,
      availableSlots: availableSlots ?? this.availableSlots,
      genderPreference: genderPreference ?? this.genderPreference,
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
          amenities == other.amenities &&
          isAvailable == other.isAvailable &&
          isFavorite == other.isFavorite &&
          roomType == other.roomType &&
          availableSlots == other.availableSlots &&
          genderPreference == other.genderPreference;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      location.hashCode ^
      price.hashCode ^
      imageUrl.hashCode ^
      amenities.hashCode ^
      isAvailable.hashCode ^
      isFavorite.hashCode ^
      roomType.hashCode ^
      availableSlots.hashCode ^
      genderPreference.hashCode;
}
