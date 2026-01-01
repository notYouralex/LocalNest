/// Cloudinary configuration for image uploads
class CloudinaryConfig {
  // Cloudinary account settings
  static const String cloudName = 'dnrdzyqyf';
  static const String uploadPreset = 'localnest_listings';
  
  // Upload URL
  static String get uploadUrl => 
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  
  // Image transformation settings
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 80;
}
