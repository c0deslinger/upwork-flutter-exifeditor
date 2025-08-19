import 'dart:io';
import 'package:flutter/foundation.dart';
import 'native_exif_controller.dart';

// No web imports for mobile platforms

class UniversalExifController {
  /// Read EXIF data using the best available method for the current platform
  static Future<Map<String, dynamic>> readExifData(dynamic imageFile) async {
    if (kIsWeb) {
      // Web platform - use stub implementation for mobile
      return {
        'error': 'Web EXIF reading not available on mobile platform',
        'success': false,
      };
    } else {
      // Mobile platforms (Android/iOS)
      if (imageFile is File) {
        return await NativeExifController.readExifData(imageFile.path);
      } else if (imageFile is String) {
        return await NativeExifController.readExifData(imageFile);
      } else {
        return {
          'error': 'Invalid file type for mobile platform',
          'success': false,
        };
      }
    }
  }

  /// Get orientation value from EXIF data
  static String getOrientationText(Map<String, dynamic> exifData) {
    if (kIsWeb) {
      // For web, return a default message since we're not implementing web EXIF
      return "Web EXIF not implemented";
    } else {
      return NativeExifController.getOrientationText(exifData);
    }
  }

  /// Get all EXIF tags as a formatted map
  static Map<String, dynamic> getAllTags(Map<String, dynamic> exifData) {
    if (kIsWeb) {
      return {};
    } else {
      return NativeExifController.getAllTags(exifData);
    }
  }

  /// Get specific EXIF tag value
  static String? getTagValue(Map<String, dynamic> exifData, String tagName) {
    if (kIsWeb) {
      return null;
    } else {
      return NativeExifController.getTagValue(exifData, tagName);
    }
  }

  /// Check if EXIF data was successfully read
  static bool isSuccess(Map<String, dynamic> exifData) {
    if (kIsWeb) {
      return false;
    } else {
      return NativeExifController.isSuccess(exifData);
    }
  }

  /// Get total number of EXIF tags found
  static int getTotalTags(Map<String, dynamic> exifData) {
    if (kIsWeb) {
      return 0;
    } else {
      return NativeExifController.getTotalTags(exifData);
    }
  }

  /// Get platform information
  static String getPlatformInfo() {
    if (kIsWeb) {
      return 'Web Platform (EXIF not implemented)';
    } else if (Platform.isAndroid) {
      return 'Android Platform';
    } else if (Platform.isIOS) {
      return 'iOS Platform';
    } else {
      return 'Unknown Platform';
    }
  }
}
