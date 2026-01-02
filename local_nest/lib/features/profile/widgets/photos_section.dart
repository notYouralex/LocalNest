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
    if (_selectedImages.length >= 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 photos allowed')),
        );
      }
      return;
    }
    
    try {
      final int remainingSlots = 3 - _selectedImages.length;
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );
      if (pickedFiles.isNotEmpty) {
        // Only take up to remaining slots
        final filesToAdd = pickedFiles.take(remainingSlots).toList();
        final newPaths = filesToAdd.map((f) => f.path).toList();
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
    return BlocListener<AddListingBloc, AddListingState>(
      listener: (context, state) {
        if (state is AddListingFormUpdated) {
          // Load existing photos when form is initialized
          if (_selectedImages.isEmpty && state.formData.photoUrls.isNotEmpty) {
            setState(() {
              _selectedImages = List<String>.from(state.formData.photoUrls);
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
              'Add 2-3 photos of your property to attract renters',
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
                  onPressed: _selectedImages.length < 3 ? _pickImages : null,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(
                    'Add More Photos (${_selectedImages.length}/3)',
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
    // Check if it's a network URL or local file path
    final isNetworkImage = imagePath.startsWith('http://') || imagePath.startsWith('https://');
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isNetworkImage
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  )
                : Image.file(
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
