import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:local_nest/core/config/cloudinary_config.dart';

/// Service for uploading images to Cloudinary
class CloudinaryService {
  /// Uploads a single image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage(String imagePath, {String? folder}) async {
    try {
      // Read and compress image
      final compressedBytes = await _compressImage(imagePath);
      
      // Create multipart request
      final uri = Uri.parse(CloudinaryConfig.uploadUrl);
      final request = http.MultipartRequest('POST', uri);
      
      // Add upload preset
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      
      // Add folder if specified
      if (folder != null) {
        request.fields['folder'] = folder;
      }
      
      // Add the image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          compressedBytes,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['secure_url'] as String;
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
  
  /// Uploads multiple images to Cloudinary
  /// Returns a list of secure URLs
  Future<List<String>> uploadImages(List<String> imagePaths, {String? folder}) async {
    final List<String> urls = [];
    
    for (final path in imagePaths) {
      final url = await uploadImage(path, folder: folder);
      urls.add(url);
    }
    
    return urls;
  }
  
  /// Compresses an image before upload
  Future<Uint8List> _compressImage(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    
    // Decode the image
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Could not decode image');
    }
    
    // Resize if needed (maintain aspect ratio)
    img.Image resized = image;
    if (image.width > CloudinaryConfig.maxImageWidth || 
        image.height > CloudinaryConfig.maxImageHeight) {
      resized = img.copyResize(
        image,
        width: image.width > image.height 
            ? CloudinaryConfig.maxImageWidth 
            : null,
        height: image.height >= image.width 
            ? CloudinaryConfig.maxImageHeight 
            : null,
      );
    }
    
    // Encode as JPEG with quality setting
    final compressedBytes = img.encodeJpg(
      resized, 
      quality: CloudinaryConfig.imageQuality,
    );
    
    return Uint8List.fromList(compressedBytes);
  }
  
  /// Deletes an image from Cloudinary (requires signed request - not implemented)
  /// For now, images can be deleted manually from Cloudinary dashboard
  Future<void> deleteImage(String publicId) async {
    // Note: Deletion requires signed API requests with API secret
    // This should be done from a backend server, not the mobile app
    debugPrint('Image deletion should be handled server-side: $publicId');
  }
}
