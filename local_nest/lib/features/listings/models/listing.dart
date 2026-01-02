import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Listing model for Firestore database
class Listing extends Equatable {
  final String id;
  final String landlordId;
  
  // Basic Information
  final String propertyName;
  final String completeAddress;
  final String city;
  final String description;
  
  // Location
  final double? latitude;
  final double? longitude;
  
  // Pricing & Capacity
  final double monthlyRent;
  final String roomType; // Solo, Shared, Studio, Apartment
  final int availableSlots;
  final int totalSlots;
  final String genderPreference; // Any, Male Only, Female Only
  
  // Photos (Cloudinary URLs)
  final List<String> photoUrls;
  
  // Status
  final String status; // active, inactive
  
  // Analytics
  final int views;
  final int inquiries;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const Listing({
    required this.id,
    required this.landlordId,
    required this.propertyName,
    required this.completeAddress,
    required this.city,
    required this.description,
    this.latitude,
    this.longitude,
    required this.monthlyRent,
    required this.roomType,
    required this.availableSlots,
    required this.totalSlots,
    required this.genderPreference,
    required this.photoUrls,
    this.status = 'active',
    this.views = 0,
    this.inquiries = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    landlordId,
    propertyName,
    completeAddress,
    city,
    description,
    latitude,
    longitude,
    monthlyRent,
    roomType,
    availableSlots,
    totalSlots,
    genderPreference,
    photoUrls,
    status,
    views,
    inquiries,
    createdAt,
    updatedAt,
  ];

  /// Create Listing from Firestore document
  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      landlordId: data['landlordId'] as String? ?? '',
      propertyName: data['propertyName'] as String? ?? '',
      completeAddress: data['completeAddress'] as String? ?? '',
      city: data['city'] as String? ?? '',
      description: data['description'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      monthlyRent: (data['monthlyRent'] as num?)?.toDouble() ?? 0,
      roomType: data['roomType'] as String? ?? 'Solo',
      availableSlots: data['availableSlots'] as int? ?? 0,
      totalSlots: data['totalSlots'] as int? ?? 0,
      genderPreference: data['genderPreference'] as String? ?? 'Any',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      status: data['status'] as String? ?? 'active',
      views: data['views'] as int? ?? 0,
      inquiries: data['inquiries'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Listing to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'landlordId': landlordId,
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
      'status': status,
      'views': views,
      'inquiries': inquiries,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with modifications
  Listing copyWith({
    String? id,
    String? landlordId,
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
    String? status,
    int? views,
    int? inquiries,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Listing(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
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
      status: status ?? this.status,
      views: views ?? this.views,
      inquiries: inquiries ?? this.inquiries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
