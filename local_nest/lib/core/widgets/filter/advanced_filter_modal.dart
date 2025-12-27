import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';

/// Reusable advanced filter modal for search and home features
/// Filters by: price range, room type, and capacity
class AdvancedFilterModal extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;
  final String roomType; // 'all', 'solo', 'shared'
  final String capacity; // 'any', '1+', '2+', '4+'
  final Function(Map<String, dynamic>) onApply;

  const AdvancedFilterModal({
    super.key,
    this.minPrice,
    this.maxPrice,
    this.roomType = 'all',
    this.capacity = 'any',
    required this.onApply,
  });

  @override
  State<AdvancedFilterModal> createState() => _AdvancedFilterModalState();
}

class _AdvancedFilterModalState extends State<AdvancedFilterModal> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  String? _minPriceError;
  String? _maxPriceError;
  late String _roomType;
  late String _capacity;

  static const double _horizontalPadding = 24;
  static const double _sectionSpacing = 24;
  static const double _itemSpacing = 12;
  static const double _sectionTitleFontSize = 16;

  @override
  void initState() {
    super.initState();
    _minPriceController =
        TextEditingController(text: widget.minPrice?.toInt().toString() ?? '');
    _maxPriceController =
        TextEditingController(text: widget.maxPrice?.toInt().toString() ?? '');
    _roomType = widget.roomType;
    _capacity = widget.capacity;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _validateMinPrice(String value) {
    setState(() {
      if (value.isEmpty) {
        _minPriceError = null;
      } else {
        final price = double.tryParse(value);
        if (price == null) {
          _minPriceError = 'Invalid price';
        } else if (price < 0) {
          _minPriceError = 'Price cannot be negative';
        } else if (_maxPriceController.text.isNotEmpty) {
          final maxPrice = double.tryParse(_maxPriceController.text);
          if (maxPrice != null && price > maxPrice) {
            _minPriceError = 'Min price cannot exceed max';
          } else {
            _minPriceError = null;
          }
        } else {
          _minPriceError = null;
        }
      }
    });
  }

  void _validateMaxPrice(String value) {
    setState(() {
      if (value.isEmpty) {
        _maxPriceError = null;
      } else {
        final price = double.tryParse(value);
        if (price == null) {
          _maxPriceError = 'Invalid price';
        } else if (price < 0) {
          _maxPriceError = 'Price cannot be negative';
        } else if (_minPriceController.text.isNotEmpty) {
          final minPrice = double.tryParse(_minPriceController.text);
          if (minPrice != null && price < minPrice) {
            _maxPriceError = 'Max price cannot be less than min';
          } else {
            _maxPriceError = null;
          }
        } else {
          _maxPriceError = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _sectionSpacing),

              // Price Range Section
              Text(
                'Price Range',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontSize: _sectionTitleFontSize,
                ),
              ),
              const SizedBox(height: _itemSpacing),
              Row(
                children: [
                  Expanded(
                    child: _buildPriceInput(
                      label: 'Min',
                      controller: _minPriceController,
                      error: _minPriceError,
                      onChanged: _validateMinPrice,
                    ),
                  ),
                  const SizedBox(width: _itemSpacing),
                  Expanded(
                    child: _buildPriceInput(
                      label: 'Max',
                      controller: _maxPriceController,
                      error: _maxPriceError,
                      onChanged: _validateMaxPrice,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _sectionSpacing),

              // Room Type Section
              Text(
                'Room Type',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontSize: _sectionTitleFontSize,
                ),
              ),
              const SizedBox(height: _itemSpacing),
              _buildRoomTypeChips(),
              const SizedBox(height: _sectionSpacing),

              // Capacity Section
              Text(
                'Minimum Capacity',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontSize: _sectionTitleFontSize,
                ),
              ),
              const SizedBox(height: _itemSpacing),
              _buildCapacityChips(),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Reset',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: _itemSpacing),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInput({
    required String label,
    required TextEditingController controller,
    required String? error,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            errorText: error,
            errorStyle: AppTextStyles.bodySmall.copyWith(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomTypeChips() {
    return Row(
      children: [
        _buildFilterChip(
          label: 'All',
          isSelected: _roomType == 'all',
          onTap: () => setState(() => _roomType = 'all'),
        ),
        const SizedBox(width: _itemSpacing),
        _buildFilterChip(
          label: 'Solo',
          isSelected: _roomType == 'solo',
          onTap: () => setState(() => _roomType = 'solo'),
        ),
        const SizedBox(width: _itemSpacing),
        _buildFilterChip(
          label: 'Shared',
          isSelected: _roomType == 'shared',
          onTap: () => setState(() => _roomType = 'shared'),
        ),
      ],
    );
  }

  Widget _buildCapacityChips() {
    return Row(
      children: [
        _buildFilterChip(
          label: 'Any',
          isSelected: _capacity == 'any',
          onTap: () => setState(() => _capacity = 'any'),
        ),
        const SizedBox(width: _itemSpacing),
        _buildFilterChip(
          label: '1+',
          isSelected: _capacity == '1+',
          onTap: () => setState(() => _capacity = '1+'),
        ),
        const SizedBox(width: _itemSpacing),
        _buildFilterChip(
          label: '2+',
          isSelected: _capacity == '2+',
          onTap: () => setState(() => _capacity = '2+'),
        ),
        const SizedBox(width: _itemSpacing),
        _buildFilterChip(
          label: '4+',
          isSelected: _capacity == '4+',
          onTap: () => setState(() => _capacity = '4+'),
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();
      _roomType = 'all';
      _capacity = 'any';
      _minPriceError = null;
      _maxPriceError = null;
    });
  }

  void _applyFilters() {
    widget.onApply({
      'minPrice': _minPriceController.text.isEmpty
          ? null
          : double.tryParse(_minPriceController.text),
      'maxPrice': _maxPriceController.text.isEmpty
          ? null
          : double.tryParse(_maxPriceController.text),
      'roomType': _roomType,
      'capacity': _capacity,
    });
    Navigator.pop(context);
  }
}
