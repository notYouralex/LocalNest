import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/add_listing_bloc.dart';

class PhotosSection extends StatefulWidget {
  const PhotosSection({Key? key}) : super(key: key);

  @override
  State<PhotosSection> createState() => _PhotosSectionState();
}

class _PhotosSectionState extends State<PhotosSection> {
  List<String> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );
      if (pickedFiles.isNotEmpty) {
        final newPaths = pickedFiles.map((f) => f.path).toList();
        setState(() {
          _selectedImages.addAll(newPaths);
        });
        if (mounted) {
          context.read<AddListingBloc>().add(PhotosAdded(_selectedImages));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    context.read<AddListingBloc>().add(PhotosAdded(_selectedImages));
  }

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
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.image_outlined, color: Colors.purple, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Property Photos',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0f172a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              'Add beautiful photos of your property to attract renters',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 20),
            // Upload Area
            if (_selectedImages.isEmpty)
              _buildUploadArea(),
            // Photos Grid
            if (_selectedImages.isNotEmpty) ...[
              SizedBox(
                height: 120 * ((_selectedImages.length / 3).ceil()).toDouble() + 
                        12 * ((_selectedImages.length / 3).ceil() - 1).toDouble(),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return _buildPhotoItem(
                      imagePath: _selectedImages[index],
                      onDelete: () => _removeImage(index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _selectedImages.length < 10 ? _pickImages : null,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(
                    'Add More Photos (${_selectedImages.length}/10)',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.purple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF8fafc),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Upload Property Photos',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0f172a),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click here to select images',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF64748b),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem({
    required String imagePath,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
