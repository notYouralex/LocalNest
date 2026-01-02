import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/add_listing_bloc.dart';

class PricingCapacitySection extends StatefulWidget {
  const PricingCapacitySection({Key? key}) : super(key: key);

  @override
  State<PricingCapacitySection> createState() => _PricingCapacitySectionState();
}

class _PricingCapacitySectionState extends State<PricingCapacitySection> {
  late TextEditingController _rentController;
  late TextEditingController _availableSlotsController;
  late TextEditingController _totalSlotsController;

  String _selectedRoomType = 'Solo';
  String _selectedGender = 'Any';

  @override
  void initState() {
    super.initState();
    _rentController = TextEditingController();
    _availableSlotsController = TextEditingController();
    _totalSlotsController = TextEditingController();
  }

  @override
  void dispose() {
    _rentController.dispose();
    _availableSlotsController.dispose();
    _totalSlotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddListingBloc, AddListingState>(
      listener: (context, state) {
        if (state is AddListingFormUpdated) {
          // Update controllers and selections with form data
          if (_rentController.text.isEmpty && state.formData.monthlyRent > 0) {
            _rentController.text = state.formData.monthlyRent.toString();
          }
          if (_availableSlotsController.text.isEmpty && state.formData.availableSlots > 0) {
            _availableSlotsController.text = state.formData.availableSlots.toString();
          }
          if (_totalSlotsController.text.isEmpty && state.formData.totalSlots > 0) {
            _totalSlotsController.text = state.formData.totalSlots.toString();
          }
          if (state.formData.roomType.isNotEmpty && _selectedRoomType != state.formData.roomType) {
            setState(() {
              _selectedRoomType = state.formData.roomType;
            });
          }
          if (state.formData.genderPreference.isNotEmpty && _selectedGender != state.formData.genderPreference) {
            setState(() {
              _selectedGender = state.formData.genderPreference;
            });
          }
        }
      },
      child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.payments, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pricing & Capacity',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0f172a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Monthly Rent
            _buildLabel('Monthly Rent (₱)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _rentController,
              hintText: '5000',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                context.read<AddListingBloc>().add(RentChanged(value));
              },
            ),
            const SizedBox(height: 20),
            // Room Type
            _buildLabel('Room Type'),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: ['Solo', 'Shared', 'Studio', 'Apartment'].map((type) {
                  final isSelected = _selectedRoomType == type;
                  return _buildToggleButton(
                    label: type,
                    isSelected: isSelected,
                    onPressed: () {
                      setState(() => _selectedRoomType = type);
                      context.read<AddListingBloc>().add(RoomTypeChanged(type));
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Available & Total Slots
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Available Slots'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _availableSlotsController,
                        hintText: '3',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          context.read<AddListingBloc>().add(AvailableSlotsChanged(value));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Total Slots'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _totalSlotsController,
                        hintText: '5',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          context.read<AddListingBloc>().add(TotalSlotsChanged(value));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Gender Preference
            _buildLabel('Gender Preference'),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['Any', 'Male Only', 'Female Only'].map((gender) {
                  final isSelected = _selectedGender == gender;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildToggleButton(
                      label: gender,
                      isSelected: isSelected,
                      onPressed: () {
                        setState(() => _selectedGender = gender);
                        context.read<AddListingBloc>().add(GenderPreferenceChanged(gender));
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0f172a),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color(0xFF64748b),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.cyan, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(fontSize: 16),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.cyan, Color(0xFF0891b2)],
                  )
                : null,
            color: isSelected ? null : const Color(0xFFF8fafc),
            border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xFFe2e8f0),
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF0f172a),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
