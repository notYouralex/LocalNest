import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/add_listing_bloc.dart';

class BasicInfoSection extends StatefulWidget {
  const BasicInfoSection({super.key});

  @override
  State<BasicInfoSection> createState() => _BasicInfoSectionState();
}

class _BasicInfoSectionState extends State<BasicInfoSection> {
  late TextEditingController _propertyNameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _propertyNameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddListingBloc, AddListingState>(
      listener: (context, state) {
        if (state is AddListingFormUpdated) {
          // Update controllers with form data if they're empty
          if (_propertyNameController.text.isEmpty && state.formData.propertyName.isNotEmpty) {
            _propertyNameController.text = state.formData.propertyName;
          }
          if (_addressController.text.isEmpty && state.formData.completeAddress.isNotEmpty) {
            _addressController.text = state.formData.completeAddress;
          }
          if (_cityController.text.isEmpty && state.formData.city.isNotEmpty) {
            _cityController.text = state.formData.city;
          }
          if (_descriptionController.text.isEmpty && state.formData.description.isNotEmpty) {
            _descriptionController.text = state.formData.description;
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
                    color: Colors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.cyan, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Basic Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0f172a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Property Name
            _buildLabel('Property Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _propertyNameController,
              hintText: 'e.g., Cozy Haven Boarding House',
              onChanged: (value) {
                context.read<AddListingBloc>().add(PropertyNameChanged(value));
              },
            ),
            const SizedBox(height: 20),
            // Complete Address
            _buildLabel('Complete Address'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _addressController,
              hintText: 'e.g., 123 P. Noval St., Sampaloc',
              onChanged: (value) {
                context.read<AddListingBloc>().add(AddressChanged(value));
              },
            ),
            const SizedBox(height: 20),
            // City/Municipality
            _buildLabel('City/Municipality'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _cityController,
              hintText: 'e.g., Manila',
              onChanged: (value) {
                context.read<AddListingBloc>().add(CityChanged(value));
              },
            ),
            const SizedBox(height: 20),
            // Description
            _buildLabel('Description'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hintText: 'Describe your property, nearby landmarks, house rules...',
              maxLines: 4,
              onChanged: (value) {
                context.read<AddListingBloc>().add(DescriptionChanged(value));
              },
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
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
}
