import 'package:equatable/equatable.dart';

/// Search filter model for advanced search functionality
class SearchFilter extends Equatable {
  final double? minPrice;
  final double? maxPrice;
  final String roomType; // 'all', 'solo', 'shared', 'studio', 'apartment'
  final String capacity; // 'any', '1+', '2+', '4+'
  final String genderPreference; // 'any', 'male', 'female'
  final List<String> amenities;

  const SearchFilter({
    this.minPrice,
    this.maxPrice,
    this.roomType = 'all',
    this.capacity = 'any',
    this.genderPreference = 'any',
    this.amenities = const [],
  });

  /// Copy with method for immutability
  SearchFilter copyWith({
    double? minPrice,
    double? maxPrice,
    String? roomType,
    String? capacity,
    String? genderPreference,
    List<String>? amenities,
  }) {
    return SearchFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      roomType: roomType ?? this.roomType,
      capacity: capacity ?? this.capacity,
      genderPreference: genderPreference ?? this.genderPreference,
      amenities: amenities ?? this.amenities,
    );
  }

  /// Check if any filter is active
  bool get isActive =>
      minPrice != null ||
      maxPrice != null ||
      roomType != 'all' ||
      capacity != 'any' ||
      genderPreference != 'any' ||
      amenities.isNotEmpty;

  /// Clear all filters
  SearchFilter clearFilters() {
    return const SearchFilter();
  }

  @override
  List<Object?> get props => [
        minPrice,
        maxPrice,
        roomType,
        capacity,
        genderPreference,
        amenities,
      ];
}
