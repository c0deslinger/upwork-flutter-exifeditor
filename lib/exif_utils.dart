import 'dart:io';

import 'package:flutter/material.dart';
import 'package:native_exif/native_exif.dart';

class ExifUtils {
  // Read EXIF data using native_exif package
  static Future<Map<String, dynamic>> readWithNativeExif(File imageFile) async {
    try {
      final exifData = await Exif.fromPath(imageFile.path);
      final attributes = await exifData.getAttributes();

      debugPrint('=== Native EXIF Results ===');
      debugPrint('Total attributes found: ${attributes?.length ?? 0}');

      // Try to get orientation specifically
      try {
        final orientation = await exifData.getAttribute('Orientation');
        debugPrint('Native EXIF Orientation: $orientation');
      } catch (e) {
        debugPrint('Could not get orientation from native_exif: $e');
      }

      attributes?.forEach((key, value) {
        debugPrint('EXIF Tag: $key = $value (Type: ${value.runtimeType})');
      });

      return attributes ?? {};
    } catch (e) {
      debugPrint('Error reading with native_exif: $e');
      return {};
    }
  }

  static String getOrientationText(Map<String, dynamic>? exifData) {
    if (exifData == null || exifData.isEmpty) {
      debugPrint('No EXIF data available');
      return "Normal";
    }

    // Debug: Print all available EXIF tags
    debugPrint('Available EXIF tags: ${exifData.keys.toList()}');

    // Try different possible keys for orientation
    dynamic orientationValue;

    // Try different possible keys - order matters, try most common first
    final possibleKeys = [
      'Image Orientation',
      'Orientation',
      'EXIF Orientation',
      'IFD0 Orientation',
      'Image:Orientation',
      'IFD0:Orientation',
      'orientation',
      'ORIENTATION',
      'Orientation',
    ];

    for (String key in possibleKeys) {
      if (exifData.containsKey(key)) {
        orientationValue = exifData[key];
        debugPrint('Found orientation tag with key: $key = $orientationValue');
        break;
      }
    }

    if (orientationValue == null) {
      debugPrint('No orientation tag found in EXIF data');
      return "Normal";
    }

    // Convert to integer for comparison
    int? orientationInt;
    try {
      // Try to parse as integer
      if (orientationValue is int) {
        orientationInt = orientationValue;
      } else if (orientationValue is String) {
        // Try to parse as integer first
        orientationInt = int.tryParse(orientationValue);
        debugPrint('Parsed orientation integer from string: $orientationInt');

        // If that fails, try to extract number from string
        if (orientationInt == null) {
          final numberMatch = RegExp(r'\d+').firstMatch(orientationValue);
          if (numberMatch != null) {
            final group = numberMatch.group(0);
            if (group != null) {
              orientationInt = int.tryParse(group);
              debugPrint(
                  'Extracted orientation integer from string: $orientationInt');
            }
          }
        }

        // If still null, try to match common orientation strings
        if (orientationInt == null) {
          final lowerValue = orientationValue.toLowerCase();
          if (lowerValue.contains('90') && lowerValue.contains('cw')) {
            orientationInt = 6; // Rotate 90 CW
          } else if (lowerValue.contains('180')) {
            orientationInt = 3; // Rotate 180
          } else if (lowerValue.contains('270') && lowerValue.contains('cw')) {
            orientationInt = 8; // Rotate 270 CW
          }
          debugPrint('Matched orientation string to integer: $orientationInt');
        }
      } else {
        orientationInt = int.tryParse(orientationValue.toString());
        debugPrint('Parsed orientation integer from toString: $orientationInt');
      }

      debugPrint('Final parsed orientation integer: $orientationInt');
    } catch (e) {
      debugPrint('Error parsing orientation value: $e');
      return "Normal";
    }

    if (orientationInt == null) {
      debugPrint('Could not parse orientation value: $orientationValue');
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
        debugPrint('Unknown orientation value: $orientationInt');
        return "Normal";
    }
  }

  static int getOrientationValue(Map<String, dynamic>? exifData) {
    if (exifData == null || exifData.isEmpty) {
      debugPrint('No EXIF data available for orientation value');
      return 1; // Default to normal orientation
    }

    // Try different possible keys for orientation
    dynamic orientationValue;

    // Try different possible keys - order matters, try most common first
    final possibleKeys = [
      'Image Orientation',
      'Orientation',
      'EXIF Orientation',
      'IFD0 Orientation',
      'Image:Orientation',
      'IFD0:Orientation',
      'orientation',
      'ORIENTATION',
      'Orientation',
    ];

    for (String key in possibleKeys) {
      if (exifData.containsKey(key)) {
        orientationValue = exifData[key];
        debugPrint('Found orientation tag with key: $key = $orientationValue');
        break;
      }
    }

    if (orientationValue == null) {
      debugPrint('No orientation tag found in EXIF data');
      return 1; // Default to normal orientation
    }

    // Convert to integer for comparison
    int? orientationInt;
    try {
      // Try to parse as integer
      if (orientationValue is int) {
        orientationInt = orientationValue;
      } else if (orientationValue is String) {
        // Try to parse as integer first
        orientationInt = int.tryParse(orientationValue);
        debugPrint('Parsed orientation integer from string: $orientationInt');

        // If that fails, try to extract number from string
        if (orientationInt == null) {
          final numberMatch = RegExp(r'\d+').firstMatch(orientationValue);
          if (numberMatch != null) {
            final group = numberMatch.group(0);
            if (group != null) {
              orientationInt = int.tryParse(group);
              debugPrint(
                  'Extracted orientation integer from string: $orientationInt');
            }
          }
        }

        // If still null, try to match common orientation strings
        if (orientationInt == null) {
          final lowerValue = orientationValue.toLowerCase();
          if (lowerValue.contains('90') && lowerValue.contains('cw')) {
            orientationInt = 6; // Rotate 90 CW
          } else if (lowerValue.contains('180')) {
            orientationInt = 3; // Rotate 180
          } else if (lowerValue.contains('270') && lowerValue.contains('cw')) {
            orientationInt = 8; // Rotate 270 CW
          }
          debugPrint('Matched orientation string to integer: $orientationInt');
        }
      } else {
        orientationInt = int.tryParse(orientationValue.toString());
        debugPrint('Parsed orientation integer from toString: $orientationInt');
      }

      debugPrint('Final parsed orientation integer: $orientationInt');
    } catch (e) {
      debugPrint('Error parsing orientation value: $e');
      return 1; // Default to normal orientation
    }

    if (orientationInt == null) {
      debugPrint('Could not parse orientation value: $orientationValue');
      return 1; // Default to normal orientation
    }

    // Validate orientation value
    if (orientationInt >= 1 && orientationInt <= 8) {
      return orientationInt;
    } else {
      debugPrint('Invalid orientation value: $orientationInt, defaulting to 1');
      return 1; // Default to normal orientation
    }
  }

  // Check if image needs horizontal mirroring
  static bool needsHorizontalMirror(int orientationValue) {
    switch (orientationValue) {
      case 2:
      case 5:
      case 7:
        return true;
      default:
        return false;
    }
  }

  // Check if image needs vertical mirroring
  static bool needsVerticalMirror(int orientationValue) {
    switch (orientationValue) {
      case 4:
        return true;
      default:
        return false;
    }
  }

  // Calculate rotation angle based on EXIF orientation
  static double getRotationAngle(int orientationValue) {
    double angle = 0.0;
    switch (orientationValue) {
      case 1:
        angle = 0.0; // Normal
        break;
      case 2:
        angle = 0.0; // Mirror Horizontal (no rotation, just mirror)
        break;
      case 3:
        angle = 180.0; // Rotate 180
        break;
      case 4:
        angle = 0.0; // Mirror Vertical (no rotation, just mirror)
        break;
      case 5:
        angle =
            -270.0; // Mirror Horizontal and Rotate 270 CW (negative for clockwise in Flutter)
        break;
      case 6:
        angle = -90.0; // Rotate 90 CW (negative for clockwise in Flutter)
        break;
      case 7:
        angle =
            -90.0; // Mirror Horizontal and Rotate 90 CW (negative for clockwise in Flutter)
        break;
      case 8:
        angle = -270.0; // Rotate 270 CW (negative for clockwise in Flutter)
        break;
      default:
        angle = 0.0; // Default to normal
    }

    debugPrint('=== TRANSFORM DEBUG ===');
    debugPrint('Orientation Value: $orientationValue');
    debugPrint('Rotation Angle: $angle°');
    debugPrint(
        'Needs Horizontal Mirror: ${ExifUtils.needsHorizontalMirror(orientationValue)}');
    debugPrint(
        'Needs Vertical Mirror: ${ExifUtils.needsVerticalMirror(orientationValue)}');

    return angle;
  }
}
