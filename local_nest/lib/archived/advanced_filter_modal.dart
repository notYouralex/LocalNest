import 'package:flutter/material.dart';
import '../app/theme/theme.dart';

/// Reusable advanced filter modal for search and home features
/// Filters by: price range, room type, and capacity
class AdvancedFilterModal extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;
  final String roomType; // 'all', 'solo', 'shared', 'studio', 'apartment'
  final String capacity; // 'any', '1+', '2+', '4+'
  final String genderPreference; // 'any', 'male', 'female'
  final Function(Map<String, dynamic>) onApply;

  const AdvancedFilterModal({
    super.key,
    this.minPrice,
    this.maxPrice,
    this.roomType = 'all',
    this.capacity = 'any',
    this.genderPreference = 'any',
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
  late String _genderPreference;

  // ===== DESIGN CONSTANTS =====

  // Spacing
  static const double _horizontalPadding = 24;
  static const double _verticalPadding = 16;
  static const double _sectionSpacing = 12;
  static const double _itemSpacing = 12;
  static const double _titleBottomSpacing = 24;

  // Border radius
  static const double _buttonBorderRadius = 14;
  static const double _inputBorderRadius = 8;
  static const double _modalBorderRadius = 16;

  // Colors - using app theme
  static final Color _selectedColorStart = AppColors.primary;
  static final Color _selectedColorEnd = AppColors.primary;
  static const Color _unselectedColor = AppColors.surface;
  static final Color _unselectedBorder = AppColors.border;
  static final Color _headerDarkStart = AppColors.primary;
  static final Color _headerDarkEnd = AppColors.primary;
  static final Color _textPrimary = AppColors.textPrimary;
  static final Color _textSecondary = AppColors.textSecondary;
  static final Color _textTertiary = AppColors.textSecondary;
  static const Color _lightBg = AppColors.background;
  static final Color _borderColor = AppColors.border;

  // Text styles
  static final TextStyle _sectionTitleStyle = TextStyle(
    color: _textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle _labelStyle = TextStyle(
    color: _textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle _buttonTextStyle = TextStyle(
    color: _textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle _buttonTextSelectedStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ===== LIFECYCLE =====

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: widget.minPrice?.toInt().toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.maxPrice?.toInt().toString() ?? '',
    );
    _roomType = widget.roomType;
    _capacity = widget.capacity;
    _genderPreference = widget.genderPreference;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  // ===== PRICE VALIDATION =====

  void _validatePriceField(String value, bool isMinPrice) {
    setState(() {
      final otherController = isMinPrice
          ? _maxPriceController
          : _minPriceController;

      if (value.isEmpty) {
        if (isMinPrice) {
          _minPriceError = null;
        } else {
          _maxPriceError = null;
        }
        return;
      }

      final price = double.tryParse(value);

      // Check for invalid input
      if (price == null) {
        if (isMinPrice) {
          _minPriceError = 'Invalid price';
        } else {
          _maxPriceError = 'Invalid price';
        }
        return;
      }

      // Check for negative values
      if (price < 0) {
        if (isMinPrice) {
          _minPriceError = 'Price cannot be negative';
        } else {
          _maxPriceError = 'Price cannot be negative';
        }
        return;
      }

      // Check for price range consistency
      if (otherController.text.isNotEmpty) {
        final otherPrice = double.tryParse(otherController.text);
        if (otherPrice != null) {
          if (isMinPrice && price > otherPrice) {
            _minPriceError = 'Min price cannot exceed max';
            return;
          } else if (!isMinPrice && price < otherPrice) {
            _maxPriceError = 'Max price cannot be less than min';
            return;
          }
        }
      }

      // Clear error
      if (isMinPrice) {
        _minPriceError = null;
      } else {
        _maxPriceError = null;
      }
    });
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_modalBorderRadius),
          topRight: Radius.circular(_modalBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildHeader(), _buildContent(), _buildActionButtons()],
      ),
    );
  }

  // ===== HEADER =====

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_headerDarkStart, _headerDarkEnd],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_modalBorderRadius),
          topRight: Radius.circular(_modalBorderRadius),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  // ===== CONTENT =====

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(_horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Price Range'),
            const SizedBox(height: _sectionSpacing),
            _buildPriceSection(),
            const SizedBox(height: _titleBottomSpacing),
            _buildSectionTitle('Room Type'),
            const SizedBox(height: _sectionSpacing),
            _buildRoomTypeSection(),
            const SizedBox(height: _titleBottomSpacing),
            _buildSectionTitle('Minimum Capacity'),
            const SizedBox(height: _sectionSpacing),
            _buildCapacitySection(),
            const SizedBox(height: _titleBottomSpacing),
            _buildSectionTitle('Gender Preference'),
            const SizedBox(height: _sectionSpacing),
            _buildGenderPreferenceSection(),
          ],
        ),
      ),
    );
  }

  // ===== SECTIONS =====

  Widget _buildSectionTitle(String title) {
    return Text(title, style: _sectionTitleStyle);
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        Expanded(
          child: _buildPriceInput(
            label: 'Min',
            controller: _minPriceController,
            error: _minPriceError,
            onChanged: (value) => _validatePriceField(value, true),
          ),
        ),
        const SizedBox(width: _itemSpacing),
        Expanded(
          child: _buildPriceInput(
            label: 'Max',
            controller: _maxPriceController,
            error: _maxPriceError,
            onChanged: (value) => _validatePriceField(value, false),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomTypeSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSelectButton(
                label: 'All',
                isSelected: _roomType == 'all',
                onTap: () => setState(() => _roomType = 'all'),
              ),
            ),
            const SizedBox(width: _itemSpacing),
            Expanded(
              child: _buildSelectButton(
                label: 'Solo',
                isSelected: _roomType == 'solo',
                onTap: () => setState(() => _roomType = 'solo'),
              ),
            ),
            const SizedBox(width: _itemSpacing),
            Expanded(
              child: _buildSelectButton(
                label: 'Shared',
                isSelected: _roomType == 'shared',
                onTap: () => setState(() => _roomType = 'shared'),
              ),
            ),
          ],
        ),
        const SizedBox(height: _itemSpacing),
        Row(
          children: [
            Expanded(
              child: _buildSelectButton(
                label: 'Studio',
                isSelected: _roomType == 'studio',
                onTap: () => setState(() => _roomType = 'studio'),
              ),
            ),
            const SizedBox(width: _itemSpacing),
            Expanded(
              child: _buildSelectButton(
                label: 'Apartment',
                isSelected: _roomType == 'apartment',
                onTap: () => setState(() => _roomType = 'apartment'),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildCapacitySection() {
    return Row(
      children: [
        Expanded(
          child: _buildSelectButton(
            label: 'Any',
            isSelected: _capacity == 'any',
            onTap: () => setState(() => _capacity = 'any'),
          ),
        ),
        const SizedBox(width: _itemSpacing),
        Expanded(
          child: _buildSelectButton(
            label: '1+',
            isSelected: _capacity == '1+',
            onTap: () => setState(() => _capacity = '1+'),
          ),
        ),
        const SizedBox(width: _itemSpacing),
        Expanded(
          child: _buildSelectButton(
            label: '2+',
            isSelected: _capacity == '2+',
            onTap: () => setState(() => _capacity = '2+'),
          ),
        ),
        const SizedBox(width: _itemSpacing),
        Expanded(
          child: _buildSelectButton(
            label: '4+',
            isSelected: _capacity == '4+',
            onTap: () => setState(() => _capacity = '4+'),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderPreferenceSection() {
    return Row(
      children: [
        Expanded(
          child: _buildSelectButton(
            label: 'Any',
            isSelected: _genderPreference == 'any',
            onTap: () => setState(() => _genderPreference = 'any'),
          ),
        ),
        const SizedBox(width: _itemSpacing),
        Expanded(
          child: _buildSelectButton(
            label: 'Male',
            isSelected: _genderPreference == 'male',
            onTap: () => setState(() => _genderPreference = 'male'),
          ),
        ),
        const SizedBox(width: _itemSpacing),
        Expanded(
          child: _buildSelectButton(
            label: 'Female',
            isSelected: _genderPreference == 'female',
            onTap: () => setState(() => _genderPreference = 'female'),
          ),
        ),
      ],
    );
  }

  // ===== WIDGETS =====

  Widget _buildPriceInput({
    required String label,
    required TextEditingController controller,
    required String? error,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: _textTertiary, fontSize: 14),
            filled: true,
            fillColor: _unselectedColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_inputBorderRadius),
              borderSide: BorderSide(color: _unselectedBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_inputBorderRadius),
              borderSide: BorderSide(color: _unselectedBorder),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_inputBorderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            errorText: error,
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          style: TextStyle(color: _textPrimary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSelectButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: _buildButtonDecoration(isSelected),
        child: Text(
          label,
          style: isSelected ? _buttonTextSelectedStyle : _buttonTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ===== ACTION BUTTONS =====

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      padding: const EdgeInsets.all(_horizontalPadding),
      child: Row(
        children: [
          Expanded(child: _buildResetButton()),
          const SizedBox(width: _itemSpacing),
          Expanded(child: _buildApplyButton()),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: _resetFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
          color: _lightBg,
          border: Border.all(color: _borderColor),
        ),
        child: Text(
          'Reset',
          style: _buttonTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: _buildSelectedButtonDecoration(),
      child: GestureDetector(
        onTap: _applyFilters,
        child: const Text(
          'Apply Filters',
          style: _buttonTextSelectedStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ===== HELPERS =====

  BoxDecoration _buildButtonDecoration(bool isSelected) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_buttonBorderRadius),
      gradient: isSelected
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_selectedColorStart, _selectedColorEnd],
            )
          : null,
      color: isSelected ? null : _unselectedColor,
      border: !isSelected ? Border.all(color: _unselectedBorder) : null,
      boxShadow: isSelected ? _buildButtonShadow() : null,
    );
  }

  BoxDecoration _buildSelectedButtonDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_buttonBorderRadius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_selectedColorStart, _selectedColorEnd],
      ),
      boxShadow: _buildButtonShadow(),
    );
  }

  List<BoxShadow> _buildButtonShadow() {
    return [
      BoxShadow(
        color: _selectedColorStart.withValues(alpha: 0.3),
        blurRadius: 15,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: _selectedColorStart.withValues(alpha: 0.3),
        blurRadius: 6,
        offset: const Offset(0, 4),
      ),
    ];
  }

  void _resetFilters() {
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();
      _roomType = 'all';
      _capacity = 'any';
      _genderPreference = 'any';
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
      'genderPreference': _genderPreference,
    });
    // Note: Navigation should be handled by the parent wrapper (HomeFilterModal, SearchFilterModal)
    // This ensures proper route management in showModalBottomSheet context
  }
}
