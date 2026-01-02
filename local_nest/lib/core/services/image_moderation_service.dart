import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Image content categories for moderation
enum ContentCategory {
  safe,
  adult,
  violence,
  racy,
  medical,
  spoof,
}

/// Result of image moderation check
class ModerationResult {
  final bool isAcceptable;
  final bool isPropertyRelated;
  final String? rejectionReason;
  final Map<String, String> safeSearchAnnotations;
  final List<String> detectedLabels;

  ModerationResult({
    required this.isAcceptable,
    required this.isPropertyRelated,
    this.rejectionReason,
    this.safeSearchAnnotations = const {},
    this.detectedLabels = const [],
  });

  factory ModerationResult.acceptable() {
    return ModerationResult(
      isAcceptable: true,
      isPropertyRelated: true,
    );
  }

  factory ModerationResult.rejected(String reason) {
    return ModerationResult(
      isAcceptable: false,
      isPropertyRelated: false,
      rejectionReason: reason,
    );
  }
}

/// Service for moderating images using Google Cloud Vision API
/// Checks for inappropriate content and property relevance
class ImageModerationService {
  // TODO: Move this to a secure configuration (e.g., environment variables or Firebase Remote Config)
  // IMPORTANT: Replace with your actual API key from Google Cloud Console
  // Go to: https://console.cloud.google.com/apis/credentials
  // Enable: Cloud Vision API
  static const String _apiKey = 'AIzaSyARdR-s2rQsf0jDwBY33eoFkZoj8slHa3s';
  
  static const String _baseUrl = 'https://vision.googleapis.com/v1/images:annotate';

  // Labels that indicate property-related content
  static const List<String> _propertyRelatedLabels = [
    'building',
    'house',
    'room',
    'apartment',
    'bedroom',
    'bathroom',
    'kitchen',
    'living room',
    'interior design',
    'furniture',
    'property',
    'real estate',
    'home',
    'residential',
    'floor',
    'ceiling',
    'wall',
    'window',
    'door',
    'architecture',
    'balcony',
    'terrace',
    'garden',
    'yard',
    'parking',
    'garage',
    'swimming pool',
    'lobby',
    'hallway',
    'corridor',
    'staircase',
    'roof',
    'facade',
    'exterior',
    'interior',
    'dining room',
    'office',
    'closet',
    'laundry',
    'storage',
  ];

  /// Check if the API key is configured
  bool get isConfigured => _apiKey != 'AIzaSyARdR-s2rQsf0jDwBY33eoFkZoj8slHa3s' && _apiKey.isNotEmpty;

  /// Moderate a single image
  /// Returns a ModerationResult indicating if the image is acceptable
  Future<ModerationResult> moderateImage(String imagePath) async {
    if (!isConfigured) {
      // If API key is not configured, allow all images (for development)
      // In production, you should always have this configured
      return ModerationResult.acceptable();
    }

    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return ModerationResult.rejected('Image file not found');
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'SAFE_SEARCH_DETECTION'},
                {'type': 'LABEL_DETECTION', 'maxResults': 20},
              ],
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        // If API fails, allow image (fail-open for better UX)
        // In production, you might want to fail-closed instead
        return ModerationResult.acceptable();
      }

      final data = jsonDecode(response.body);
      final responses = data['responses'] as List?;
      
      if (responses == null || responses.isEmpty) {
        return ModerationResult.acceptable();
      }

      final result = responses.first;
      
      // Check for inappropriate content
      final safeSearch = result['safeSearchAnnotation'] as Map<String, dynamic>?;
      if (safeSearch != null) {
        final moderationCheck = _checkSafeSearch(safeSearch);
        if (!moderationCheck.isAcceptable) {
          return moderationCheck;
        }
      }

      // Check for property-related content
      final labels = result['labelAnnotations'] as List?;
      final detectedLabels = labels
          ?.map((l) => (l['description'] as String).toLowerCase())
          .toList() ?? [];

      final isPropertyRelated = _isPropertyRelated(detectedLabels);
      
      if (!isPropertyRelated) {
        return ModerationResult(
          isAcceptable: false,
          isPropertyRelated: false,
          rejectionReason: 'Image does not appear to be related to a property. Please upload photos of your room, apartment, or building. Detected: ${detectedLabels.take(3).join(", ")}',
          detectedLabels: detectedLabels.cast<String>(),
        );
      }

      return ModerationResult(
        isAcceptable: true,
        isPropertyRelated: true,
        safeSearchAnnotations: safeSearch?.map((k, v) => MapEntry(k, v.toString())) ?? {},
        detectedLabels: detectedLabels.cast<String>(),
      );
    } catch (e) {
      // Fail-open: allow image if moderation fails
      return ModerationResult.acceptable();
    }
  }

  /// Moderate multiple images
  /// Returns a map of image path to moderation result
  Future<Map<String, ModerationResult>> moderateImages(List<String> imagePaths) async {
    final results = <String, ModerationResult>{};
    
    for (final path in imagePaths) {
      results[path] = await moderateImage(path);
    }
    
    return results;
  }

  /// Check safe search annotations for inappropriate content
  ModerationResult _checkSafeSearch(Map<String, dynamic> safeSearch) {
    final adult = safeSearch['adult'] as String? ?? 'UNKNOWN';
    final violence = safeSearch['violence'] as String? ?? 'UNKNOWN';
    final racy = safeSearch['racy'] as String? ?? 'UNKNOWN';
    final medical = safeSearch['medical'] as String? ?? 'UNKNOWN';

    // Reject if adult content is LIKELY or VERY_LIKELY
    if (_isLikelyOrHigher(adult)) {
      return ModerationResult.rejected(
        'This image contains adult content and cannot be used.',
      );
    }

    // Reject if violence is LIKELY or VERY_LIKELY
    if (_isLikelyOrHigher(violence)) {
      return ModerationResult.rejected(
        'This image contains violent content and cannot be used.',
      );
    }

    // Warn but allow racy content at LIKELY level, reject at VERY_LIKELY
    if (racy == 'VERY_LIKELY') {
      return ModerationResult.rejected(
        'This image contains inappropriate content and cannot be used.',
      );
    }

    // Medical images might not be appropriate for property listings
    if (_isLikelyOrHigher(medical)) {
      return ModerationResult.rejected(
        'This image appears to be medical content and is not appropriate for property listings.',
      );
    }

    return ModerationResult(
      isAcceptable: true,
      isPropertyRelated: true,
      safeSearchAnnotations: safeSearch.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  /// Check if likelihood is LIKELY or VERY_LIKELY
  bool _isLikelyOrHigher(String likelihood) {
    return likelihood == 'LIKELY' || likelihood == 'VERY_LIKELY';
  }

  /// Check if detected labels indicate property-related content
  bool _isPropertyRelated(List<dynamic> labels) {
    // Require at least some labels to be detected
    if (labels.isEmpty) {
      return false;
    }

    // Check if any property-related labels are present
    for (final label in labels) {
      final labelStr = label.toString().toLowerCase();
      for (final propertyLabel in _propertyRelatedLabels) {
        if (labelStr.contains(propertyLabel) || propertyLabel.contains(labelStr)) {
          return true;
        }
      }
    }

    return false;
  }
}
