/// Image Handling Service
/// Single responsibility: Handle all image-related operations
import 'package:image_picker/image_picker.dart';

class ImageHandlingService {
  static const maxFileSize = 10 * 1024 * 1024; // 10MB
  static const allowedExtensions = ['jpg', 'jpeg', 'png'];
  static const maxPhotosCount = 10;

  final ImagePicker _imagePicker = ImagePicker();

  /// Pick multiple images from device
  Future<List<String>> pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxHeight: 1000,
        maxWidth: 1000,
        imageQuality: 85,
      );

      return images.map((image) => image.path).toList();
    } catch (e) {
      throw Exception('Failed to pick images: $e');
    }
  }

  /// Validate image file
  String? validateImageFile(String filePath) {
    // Check if file extension is allowed
    final extension = filePath.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'Only JPG and PNG images are allowed';
    }

    // Note: File size validation would be done during upload
    // as we can't easily check file size from path alone

    return null;
  }

  /// Check if can add more photos
  bool canAddMorePhotos(int currentCount) {
    return currentCount < maxPhotosCount;
  }

  /// Get remaining slots for photos
  int getRemainingPhotoSlots(int currentCount) {
    return maxPhotosCount - currentCount;
  }
}
