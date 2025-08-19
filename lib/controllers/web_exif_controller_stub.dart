// Stub implementation for web_exif_controller when running on mobile platforms
// This file is used as a conditional import to avoid dart:html and dart:js imports

class WebExifController {
  /// Read EXIF data using JavaScript EXIF.js library
  static Future<Map<String, dynamic>> readExifData(dynamic imageFile) async {
    return {
      'error': 'Web EXIF reading not available on mobile platform',
      'success': false,
    };
  }

  /// Get orientation value from EXIF data
  static String getOrientationText(Map<String, dynamic> exifData) {
    return "Web EXIF not implemented";
  }

  /// Get all EXIF tags as a formatted map
  static Map<String, dynamic> getAllTags(Map<String, dynamic> exifData) {
    return {};
  }

  /// Get specific EXIF tag value
  static String? getTagValue(Map<String, dynamic> exifData, String tagName) {
    return null;
  }

  /// Check if EXIF data was successfully read
  static bool isSuccess(Map<String, dynamic> exifData) {
    return false;
  }

  /// Get total number of EXIF tags found
  static int getTotalTags(Map<String, dynamic> exifData) {
    return 0;
  }
}
