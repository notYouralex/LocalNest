import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/add_listing_bloc.dart';

class AmenitiesSection extends StatefulWidget {
  const AmenitiesSection({Key? key}) : super(key: key);

  @override
  State<AmenitiesSection> createState() => _AmenitiesSectionState();
}

class _AmenitiesSectionState extends State<AmenitiesSection> {
  bool _wifiAvailable = false;
  bool _privateCR = false;
  bool _sharedCR = false;
  bool _petFriendly = false;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.star_outline, color: Colors.green, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Amenities & Features',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0f172a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // WiFi
            _buildAmenityItem(
              icon: Icons.wifi,
              iconColor: Colors.cyan,
              title: 'WiFi Available',
              description: 'High-speed internet connection',
              value: _wifiAvailable,
              onChanged: (value) {
                setState(() => _wifiAvailable = value);
                context.read<AddListingBloc>().add(AmenityToggled('wifi', value));
              },
            ),
            const SizedBox(height: 16),
            // Private CR
            _buildAmenityItem(
              icon: Icons.bathroom,
              iconColor: Colors.green,
              title: 'Private CR',
              description: 'Own bathroom inside room',
              value: _privateCR,
              onChanged: (value) {
                setState(() => _privateCR = value);
                context.read<AddListingBloc>().add(AmenityToggled('privateCR', value));
              },
            ),
            const SizedBox(height: 16),
            // Shared CR
            _buildAmenityItem(
              icon: Icons.shower,
              iconColor: Colors.amber,
              title: 'Shared CR',
              description: 'Common bathroom facilities',
              value: _sharedCR,
              onChanged: (value) {
                setState(() => _sharedCR = value);
                context.read<AddListingBloc>().add(AmenityToggled('sharedCR', value));
              },
            ),
            const SizedBox(height: 16),
            // Pet Friendly
            _buildAmenityItem(
              icon: Icons.pets,
              iconColor: Colors.purple,
              title: 'Pet-Friendly',
              description: 'Allows cats and dogs',
              value: _petFriendly,
              onChanged: (value) {
                setState(() => _petFriendly = value);
                context.read<AddListingBloc>().add(AmenityToggled('petFriendly', value));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0f172a),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF64748b),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.cyan,
          activeTrackColor: Colors.cyan.withOpacity(0.3),
        ),
      ],
    );
  }
}
