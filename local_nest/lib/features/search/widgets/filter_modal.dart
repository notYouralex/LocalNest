import 'package:flutter/material.dart';
import '../../../core/widgets/widgets.dart';
import '../models/models.dart';

/// Wrapper filter modal for search feature
/// Uses core [AdvancedFilterModal] to maintain consistent filtering across features
class FilterModal extends StatefulWidget {
  final SearchFilter currentFilter;
  final List<String> availableAmenities;
  final Map<String, double> priceRange;
  final Function(SearchFilter) onApplyFilters;

  const FilterModal({
    super.key,
    required this.currentFilter,
    required this.availableAmenities,
    required this.priceRange,
    required this.onApplyFilters,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late SearchFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  void _handleApplyFilters(Map<String, dynamic> filterData) {
    _filter = _filter.copyWith(
      minPrice: filterData['minPrice'],
      maxPrice: filterData['maxPrice'],
      roomType: filterData['roomType'],
      capacity: filterData['capacity'],
      genderPreference: filterData['genderPreference'],
    );

    widget.onApplyFilters(_filter);
    // Note: Navigation is handled by the parent (search_page.dart)
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedFilterModal(
      minPrice: _filter.minPrice,
      maxPrice: _filter.maxPrice,
      roomType: _filter.roomType,
      capacity: _filter.capacity,
      genderPreference: _filter.genderPreference,
      onApply: _handleApplyFilters,
    );
  }
}
