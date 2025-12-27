import 'package:flutter/material.dart';
import '../../../core/widgets/widgets.dart';

/// Wrapper filter modal for home feature
/// Uses core [AdvancedFilterModal] to maintain consistent filtering across features
class HomeFilterModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const HomeFilterModal({
    super.key,
    required this.onApplyFilters,
  });

  @override
  State<HomeFilterModal> createState() => _HomeFilterModalState();
}

class _HomeFilterModalState extends State<HomeFilterModal> {
  @override
  Widget build(BuildContext context) {
    return AdvancedFilterModal(
      onApply: (filterData) {
        widget.onApplyFilters(filterData);
        Navigator.pop(context);
      },
    );
  }
}
