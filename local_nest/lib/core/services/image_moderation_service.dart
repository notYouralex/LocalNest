import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';

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

/// Image moderation using Sightengine with Firebase Remote Config
/// API keys are stored securely in Firebase Remote Config
class ImageModerationService {
  static const String _baseUrl = 'https://api.sightengine.com/1.0/check.json';
  
  String? _apiUser;
  String? _apiSecret;
  bool _isInitialized = false;

  /// Initialize the service by fetching API keys from Firebase Remote Config
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      
      try {
        await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 0),
        ));
      } catch (e) {
        // Ignore settings error
      }

      try {
        await remoteConfig.setDefaults(const {
          'sightengine_api_user': '',
          'sightengine_api_secret': '',
        });
      } catch (e) {
        // Ignore defaults error
      }

      try {
        await remoteConfig.fetchAndActivate();
      } catch (e) {
        // Try to use cached values
      }

      try {
        _apiUser = remoteConfig.getString('sightengine_api_user');
        _apiSecret = remoteConfig.getString('sightengine_api_secret');
      } catch (e) {
        _apiUser = '';
        _apiSecret = '';
      }

      _isInitialized = true;
    } catch (e, stackTrace) {
      _isInitialized = true;
      _apiUser = '';
      _apiSecret = '';
    }
  }

  bool get isConfigured => 
      _isInitialized && 
      _apiUser != null && 
      _apiUser!.isNotEmpty &&
      _apiSecret != null && 
      _apiSecret!.isNotEmpty;

  /// Moderate a single image
  Future<ModerationResult> moderateImage(String imagePath) async {
    // Initialize if not already done
    if (!_isInitialized) {
      await initialize();
    }

    if (!isConfigured) {
      return _basicValidation(imagePath);
    }

    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return ModerationResult.rejected('Image file not found');
      }

      // Basic validation first
      final basicCheck = await _basicValidation(imagePath);
      if (!basicCheck.isAcceptable) {
        return basicCheck;
      }

      final bytes = await imageFile.readAsBytes();
      
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      
      // Add fields - content moderation models
      request.fields['models'] = 'nudity-2.0,wad,offensive,gore,face-attributes';
      request.fields['api_user'] = _apiUser!;
      request.fields['api_secret'] = _apiSecret!;
      
      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'media',
          bytes,
          filename: 'image.jpg',
        ),
      );
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return ModerationResult.acceptable();
      }

      final data = jsonDecode(response.body);

      // Check for errors
      if (data['status'] == 'failure') {
        return ModerationResult.acceptable();
      }

      // Check nudity
      final nudity = data['nudity'];
      if (nudity != null) {
        final rawScore = (nudity['raw'] ?? 0.0) is int 
            ? (nudity['raw'] as int).toDouble() 
            : nudity['raw'] ?? 0.0;
        final partialScore = (nudity['partial'] ?? 0.0) is int
            ? (nudity['partial'] as int).toDouble()
            : nudity['partial'] ?? 0.0;
        final suggestiveScore = (nudity['suggestive'] ?? 0.0) is int
            ? (nudity['suggestive'] as int).toDouble()
            : nudity['suggestive'] ?? 0.0;
        
        // Check for explicit nudity
        if (rawScore > 0.3 || partialScore > 0.5) {
          return ModerationResult.rejected(
            'This image contains adult content and cannot be used.',
          );
        }
        
        // Check for suggestive content (lingerie, revealing clothing, etc.)
        if (suggestiveScore > 0.7) {
          return ModerationResult.rejected(
            'This image contains inappropriate content and cannot be used.',
          );
        }
      }

      // Check weapons/drugs/alcohol
      final weapon = (data['weapon'] ?? 0.0) is int
          ? (data['weapon'] as int).toDouble()
          : data['weapon'] ?? 0.0;
      
      if (weapon > 0.5) {
        return ModerationResult.rejected(
          'This image contains inappropriate content and cannot be used.',
        );
      }

      // Check offensive content
      final offensive = data['offensive'];
      if (offensive != null) {
        final offensiveProb = (offensive['prob'] ?? 0.0) is int
            ? (offensive['prob'] as int).toDouble()
            : offensive['prob'] ?? 0.0;
        
        if (offensiveProb > 0.5) {
          return ModerationResult.rejected(
            'This image contains offensive content and cannot be used.',
          );
        }
      }

      // Check gore
      final gore = data['gore'];
      if (gore != null) {
        final goreProb = (gore['prob'] ?? 0.0) is int
            ? (gore['prob'] as int).toDouble()
            : gore['prob'] ?? 0.0;
        
        if (goreProb > 0.5) {
          return ModerationResult.rejected(
            'This image contains violent content and cannot be used.',
          );
        }
      }

      // Check for faces (people shouldn't be in property photos)
      final faces = data['faces'];
      if (faces != null && faces is List && faces.isNotEmpty) {
        return ModerationResult.rejected(
          'Please upload photos without people visible. Property photos should show the space only.',
        );
      }

      return ModerationResult.acceptable();
    } catch (e, stackTrace) {
      return ModerationResult.acceptable();
    }
  }

  /// Moderate profile image (allows faces, only checks inappropriate content)
  Future<ModerationResult> moderateProfileImage(String imagePath) async {
    // Initialize if not already done
    if (!_isInitialized) {
      await initialize();
    }

    if (!isConfigured) {
      return _basicValidation(imagePath);
    }

    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return ModerationResult.rejected('Image file not found');
      }

      // Basic validation first
      final basicCheck = await _basicValidation(imagePath);
      if (!basicCheck.isAcceptable) {
        return basicCheck;
      }

      final bytes = await imageFile.readAsBytes();
      
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      
      // Add fields - content moderation models (no face detection needed)
      request.fields['models'] = 'nudity-2.0,wad,offensive,gore';
      request.fields['api_user'] = _apiUser!;
      request.fields['api_secret'] = _apiSecret!;
      
      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'media',
          bytes,
          filename: 'image.jpg',
        ),
      );
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔒 PROFILE MODERATION - Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('❌ PROFILE - API failed: ${response.body}');
        return ModerationResult.acceptable();
      }

      final data = jsonDecode(response.body);
      print('📊 PROFILE - Response data: $data');

      // Check for errors
      if (data['status'] == 'failure') {
        print('❌ PROFILE - API error: ${data['error']}');
        return ModerationResult.acceptable();
      }

      // Check nudity
      final nudity = data['nudity'];
      if (nudity != null) {
        final rawScore = (nudity['raw'] ?? 0.0) is int 
            ? (nudity['raw'] as int).toDouble() 
            : nudity['raw'] ?? 0.0;
        final partialScore = (nudity['partial'] ?? 0.0) is int
            ? (nudity['partial'] as int).toDouble()
            : nudity['partial'] ?? 0.0;
        final suggestiveScore = (nudity['suggestive'] ?? 0.0) is int
            ? (nudity['suggestive'] as int).toDouble()
            : nudity['suggestive'] ?? 0.0;
        
        print('🔒 PROFILE - Nudity scores: raw=$rawScore, partial=$partialScore, suggestive=$suggestiveScore');
        
        // Check for explicit nudity
        if (rawScore > 0.3 || partialScore > 0.5) {
          print('❌ PROFILE - REJECTED due to nudity');
          return ModerationResult.rejected(
            'This image contains adult content and cannot be used as a profile picture.',
          );
        }
        
        // Check for suggestive content (lingerie, revealing clothing, etc.)
        if (suggestiveScore > 0.7) {
          print('❌ PROFILE - REJECTED due to suggestive content');
          return ModerationResult.rejected(
            'This image contains inappropriate content and cannot be used as a profile picture.',
          );
        }
      }

      // Check weapons/drugs/alcohol
      final weapon = (data['weapon'] ?? 0.0) is int
          ? (data['weapon'] as int).toDouble()
          : data['weapon'] ?? 0.0;
      
      print('🔒 PROFILE - Weapon score: $weapon');
      
      if (weapon > 0.5) {
        print('❌ PROFILE - REJECTED due to weapons/drugs');
        return ModerationResult.rejected(
          'This image contains inappropriate content and cannot be used as a profile picture.',
        );
      }

      // Check offensive content
      final offensive = data['offensive'];
      if (offensive != null) {
        final offensiveProb = (offensive['prob'] ?? 0.0) is int
            ? (offensive['prob'] as int).toDouble()
            : offensive['prob'] ?? 0.0;
        
        print('🔒 PROFILE - Offensive score: $offensiveProb');
        
        if (offensiveProb > 0.5) {
          print('❌ PROFILE - REJECTED due to offensive content');
          return ModerationResult.rejected(
            'This image contains offensive content and cannot be used as a profile picture.',
          );
        }
      }

      // Check gore
      final gore = data['gore'];
      if (gore != null) {
        final goreProb = (gore['prob'] ?? 0.0) is int
            ? (gore['prob'] as int).toDouble()
            : gore['prob'] ?? 0.0;
        
        print('🔒 PROFILE - Gore score: $goreProb');
        
        if (goreProb > 0.5) {
          print('❌ PROFILE - REJECTED due to gore/violence');
          return ModerationResult.rejected(
            'This image contains violent content and cannot be used as a profile picture.',
          );
        }
      }

      print('✅ PROFILE - Image ACCEPTED');
      print('📊 PROFILE - Summary: Nudity(raw=$nudity, partial=$nudity), Weapon=$weapon, Offensive=${offensive?['prob']}, Gore=${gore?['prob']}');
      
      // No face check for profile images - faces are expected!
      return ModerationResult.acceptable();
    } catch (e, stackTrace) {
      print('❌ PROFILE - Exception: $e');
      print('Stack trace: $stackTrace');
      return ModerationResult.acceptable();
    }
  }

  /// Moderate multiple images
  Future<Map<String, ModerationResult>> moderateImages(List<String> imagePaths) async {
    final results = <String, ModerationResult>{};
    for (final path in imagePaths) {
      results[path] = await moderateImage(path);
    }
    return results;
  }

  /// Basic client-side validation
  Future<ModerationResult> _basicValidation(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      
      // Check file size
      final bytes = await imageFile.readAsBytes();
      final fileSizeMB = bytes.length / (1024 * 1024);
      
      if (bytes.length > 10 * 1024 * 1024) {
        return ModerationResult.rejected(
          'Image file is too large (${fileSizeMB.toStringAsFixed(1)} MB). Maximum size is 10 MB.',
        );
      }
      
      if (bytes.length < 1024) {
        return ModerationResult.rejected('Image file is too small or corrupted.');
      }

      return ModerationResult.acceptable();
    } catch (e) {
      return ModerationResult.rejected('Unable to read image file.');
    }
  }

  Future<void> testApiConnection() async {
    await initialize();
  }
}