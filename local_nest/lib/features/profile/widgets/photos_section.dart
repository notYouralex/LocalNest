import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/image_moderation_service.dart';
import '../bloc/add_listing_bloc.dart';

class PhotosSection extends StatefulWidget {
  const PhotosSection({super.key});

  @override
  State<PhotosSection> createState() => _PhotosSectionState();
}

class _PhotosSectionState extends State<PhotosSection> {
  List<String> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  final ImageModerationService _moderationService = ImageModerationService();
  bool _isModeratingImages = false;
  bool _hasInitializedPhotos = false;

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
      
      if (pickedFiles.isEmpty) {
        return;
      }
      
      // Only take up to remaining slots
      final filesToAdd = pickedFiles.take(remainingSlots).toList();
      final newPaths = filesToAdd.map((f) => f.path).toList();
      
      // Moderate images before adding
      setState(() => _isModeratingImages = true);
      
      final approvedPaths = <String>[];
      final rejectedMessages = <String>[];
      
      for (int i = 0; i < newPaths.length; i++) {
        final path = newPaths[i];
        final result = await _moderationService.moderateImage(path);
        
        if (result.isAcceptable) {
          approvedPaths.add(path);
        } else {
          rejectedMessages.add(result.rejectionReason ?? 'Image rejected');
        }
      }
      
      setState(() => _isModeratingImages = false);
      
      // Show rejection messages if any
      if (rejectedMessages.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              rejectedMessages.length == 1
                  ? rejectedMessages.first
                  : '${rejectedMessages.length} image(s) rejected:\n${rejectedMessages.first}',
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
      
      // Add ONLY approved images
      if (approvedPaths.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(approvedPaths);
        });
        
        // Update bloc with ONLY approved images
        if (mounted) {
          context.read<AddListingBloc>().add(PhotosAdded(_selectedImages));
        }
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                approvedPaths.length == 1
                    ? '1 photo added successfully'
                    : '${approvedPaths.length} photos added successfully',
              ),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      setState(() => _isModeratingImages = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
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
          if (!_hasInitializedPhotos && state.formData.photoUrls.isNotEmpty) {
            setState(() {
              _selectedImages = List<String>.from(state.formData.photoUrls);
              _hasInitializedPhotos = true;
            });
          } else if (!_hasInitializedPhotos) {
            _hasInitializedPhotos = true;
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
                      color: Colors.purple.withValues(alpha: 0.2),
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
              // Loading indicator while moderating
              if (_isModeratingImages)
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple.withValues(alpha: 0.5), width: 1),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.purple.withValues(alpha: 0.05),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.purple),
                        const SizedBox(height: 16),
                        Text(
                          'Verifying image safety and content...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.purple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This may take a few moments',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.purple.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Upload Area
              if (!_isModeratingImages && _selectedImages.isEmpty)
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
                    onPressed: (_selectedImages.length < 3 && !_isModeratingImages) ? _pickImages : null,
                    icon: _isModeratingImages 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple),
                          )
                        : const Icon(Icons.add_photo_alternate),
                    label: Text(
                      _isModeratingImages 
                          ? 'Verifying images...' 
                          : 'Add More Photos (${_selectedImages.length}/3)',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: (_selectedImages.length < 3 && !_isModeratingImages) 
                            ? Colors.purple 
                            : Colors.grey,
                      ),
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
                    width: double.infinity,
                    height: double.infinity,
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
                    width: double.infinity,
                    height: double.infinity,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
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