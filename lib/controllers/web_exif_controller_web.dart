// Web-specific EXIF controller - only use this for web platform
// This file should only be imported when targeting web

import 'dart:html' as html;
import 'dart:js' as js;

class WebExifController {
  /// Read EXIF data using JavaScript EXIF.js library
  static Future<Map<String, dynamic>> readExifData(html.File imageFile) async {
    try {
      // Call the JavaScript function
      final result = await js.context.callMethod('readExifData', [imageFile]);

      // Convert JavaScript object to Dart Map
      final Map<String, dynamic> exifData = Map<String, dynamic>.from(result);

      return exifData;
    } catch (e) {
      print('Error reading EXIF data from web: $e');
      return {
        'error': e.toString(),
        'success': false,
      };
    }
  }

  /// Get orientation value from EXIF data
  static String getOrientationText(Map<String, dynamic> exifData) {
    if (exifData['success'] != true) {
      return "Error reading EXIF";
    }

    final orientation = exifData['Orientation'];
    if (orientation == null) {
      return "Normal";
    }

    // Convert to integer
    int? orientationInt;
    try {
      if (orientation is String) {
        orientationInt = int.tryParse(orientation);
      } else if (orientation is int) {
        orientationInt = orientation;
      }
    } catch (e) {
      print('Error parsing orientation: $e');
      return "Normal";
    }

    if (orientationInt == null) {
      return "Normal";
    }

    switch (orientationInt) {
      case 1:
        return "Normal";
      case 2:
        return "Mirror Horizontal";
      case 3:
        return "Rotate 180";
      case 4:
        return "Mirror Vertical";
      case 5:
        return "Mirror Horizontal and Rotate 270 CW";
      case 6:
        return "Rotate 90 CW";
      case 7:
        return "Mirror Horizontal and Rotate 90 CW";
      case 8:
        return "Rotate 270 CW";
      default:
        return "Normal";
    }
  }

  /// Get all EXIF tags as a formatted map
  static Map<String, dynamic> getAllTags(Map<String, dynamic> exifData) {
    if (exifData['success'] != true) {
      return {};
    }

    final allTags = exifData['allTags'] as Map<String, dynamic>?;
    return allTags ?? {};
  }

  /// Get specific EXIF tag value
  static String? getTagValue(Map<String, dynamic> exifData, String tagName) {
    if (exifData['success'] != true) {
      return null;
    }

    return exifData[tagName] as String?;
  }

  /// Check if EXIF data was successfully read
  static bool isSuccess(Map<String, dynamic> exifData) {
    return exifData['success'] == true;
  }

  /// Get total number of EXIF tags found
  static int getTotalTags(Map<String, dynamic> exifData) {
    if (exifData['success'] != true) {
      return 0;
    }

    return exifData['totalTags'] as int? ?? 0;
  }
}
