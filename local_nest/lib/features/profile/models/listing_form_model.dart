/// Model for Add/Edit Listing form data
class ListingFormData {
  // Basic Information
  String propertyName;
  String completeAddress;
  String city;
  String description;

  // Location
  double? latitude;
  double? longitude;

  // Pricing & Capacity
  double monthlyRent;
  String roomType; // Solo, Shared, Studio, Apartment
  int availableSlots;
  int totalSlots;
  String genderPreference; // Any, Male Only, Female Only

  // Photos
  List<String> photoUrls; // Firestore URLs or file paths

  ListingFormData({
    this.propertyName = '',
    this.completeAddress = '',
    this.city = '',
    this.description = '',
    this.latitude,
    this.longitude,
    this.monthlyRent = 0,
    this.roomType = 'Solo',
    this.availableSlots = 0,
    this.totalSlots = 0,
    this.genderPreference = 'Any',
    this.photoUrls = const [],
  });

  /// Create a copy with modifications
  ListingFormData copyWith({
    String? propertyName,
    String? completeAddress,
    String? city,
    String? description,
    double? latitude,
    double? longitude,
    double? monthlyRent,
    String? roomType,
    int? availableSlots,
    int? totalSlots,
    String? genderPreference,
    List<String>? photoUrls,
  }) {
    return ListingFormData(
      propertyName: propertyName ?? this.propertyName,
      completeAddress: completeAddress ?? this.completeAddress,
      city: city ?? this.city,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      roomType: roomType ?? this.roomType,
      availableSlots: availableSlots ?? this.availableSlots,
      totalSlots: totalSlots ?? this.totalSlots,
      genderPreference: genderPreference ?? this.genderPreference,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }

  /// Validate form data
  String? validate() {
    if (propertyName.isEmpty) return 'Property name is required';
    if (completeAddress.isEmpty) return 'Complete address is required';
    if (city.isEmpty) return 'City is required';
    if (description.isEmpty) return 'Description is required';
    if (monthlyRent <= 0) return 'Monthly rent must be greater than 0';
    if (availableSlots < 0) return 'Available slots cannot be negative';
    if (totalSlots <= 0) return 'Total slots must be greater than 0';
    if (availableSlots > totalSlots) return 'Available slots cannot exceed total slots';
    if (photoUrls.length < 2) return 'At least 2 photos are required';
    if (photoUrls.length > 3) return 'Maximum 3 photos allowed';
    return null;
  }

  /// Convert to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'propertyName': propertyName,
      'completeAddress': completeAddress,
      'city': city,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'monthlyRent': monthlyRent,
      'roomType': roomType,
      'availableSlots': availableSlots,
      'totalSlots': totalSlots,
      'genderPreference': genderPreference,
      'photoUrls': photoUrls,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
