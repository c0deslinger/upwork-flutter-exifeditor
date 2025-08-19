import 'package:flutter/services.dart';

class NativeExifController {
  static const MethodChannel _channel = MethodChannel('exif_reader_channel');

  /// Read EXIF data using native platform implementation
  static Future<Map<String, dynamic>> readExifData(String imagePath) async {
    try {
      final dynamic rawResult = await _channel.invokeMethod('readExifData', {
        'imagePath': imagePath,
      });

      // Convert the result to the correct type
      Map<String, dynamic> result;
      if (rawResult is Map) {
        result = Map<String, dynamic>.from(rawResult);
      } else {
        result = {
          'error': 'Invalid result type from native platform',
          'success': false,
        };
      }

      return result;
    } on PlatformException catch (e) {
      print('Error reading EXIF data: ${e.message}');
      return {
        'error': e.message,
        'success': false,
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'error': e.toString(),
        'success': false,
      };
    }
  }

  /// Read EXIF data using advanced Android ExifInterface features
  static Future<Map<String, dynamic>> readExifDataAdvanced(
      String imagePath) async {
    try {
      final dynamic rawResult =
          await _channel.invokeMethod('readExifDataAdvanced', {
        'imagePath': imagePath,
      });

      // Convert the result to the correct type
      Map<String, dynamic> result;
      if (rawResult is Map) {
        result = Map<String, dynamic>.from(rawResult);
      } else {
        result = {
          'error': 'Invalid result type from native platform',
          'success': false,
        };
      }

      return result;
    } on PlatformException catch (e) {
      print('Error reading advanced EXIF data: ${e.message}');
      return {
        'error': e.message,
        'success': false,
      };
    } catch (e) {
      print('Unexpected error in advanced EXIF reading: $e');
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

    final allTags = exifData['allTags'];
    if (allTags is Map) {
      return Map<String, dynamic>.from(allTags);
    }
    return {};
  }

  /// Get specific EXIF tag value
  static String? getTagValue(Map<String, dynamic> exifData, String tagName) {
    if (exifData['success'] != true) {
      return null;
    }

    final value = exifData[tagName];
    if (value is String) {
      return value;
    } else if (value != null) {
      return value.toString();
    }
    return null;
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

    final totalTags = exifData['totalTags'];
    if (totalTags is int) {
      return totalTags;
    } else if (totalTags is String) {
      return int.tryParse(totalTags) ?? 0;
    }
    return 0;
  }
}
