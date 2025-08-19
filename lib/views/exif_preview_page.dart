import 'dart:io';
import 'package:drug_search/views/exif_info_page.dart';
import 'package:drug_search/views/exif_editor_page.dart';
import 'package:native_exif/native_exif.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ExifPreviewPage extends StatefulWidget {
  static const routeName = "/exifPreview";

  const ExifPreviewPage({super.key});

  @override
  State<ExifPreviewPage> createState() => _ExifPreviewPageState();
}

class _ExifPreviewPageState extends State<ExifPreviewPage> {
  String? imagePath;
  String? libraryType;
  String? originalFileName;
  Map<String, dynamic>? exifData;
  String orientation = "Normal";
  int orientationValue = 1; // Add orientation value as integer
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Get the arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      imagePath = arguments['imagePath'] as String?;
      libraryType = arguments['libraryType'] as String?;
      originalFileName = arguments['originalFileName'] as String?;
    }

    if (imagePath != null && libraryType != null) {
      _loadExifData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadExifData() async {
    if (imagePath == null || libraryType == null) return;

    try {
      final File imageFile = File(imagePath!);

      debugPrint('Reading EXIF data using library: $libraryType');
      Map<String, dynamic> exifDataMap = {};

      switch (libraryType) {
        case 'native_exif':
          debugPrint('Using Native EXIF library...');
          exifDataMap = await _readWithNativeExif(imageFile);
          break;
        default:
          debugPrint('Unknown library type: $libraryType');
          exifDataMap = {};
      }

      debugPrint('EXIF data loaded successfully');
      debugPrint('Total EXIF tags found: ${exifDataMap.length}');

      String detectedOrientation = _getOrientationText(exifDataMap);
      int detectedOrientationValue = _getOrientationValue(exifDataMap);

      debugPrint('=== ORIENTATION INFO ===');
      debugPrint('Orientation Text: $detectedOrientation');
      debugPrint('Orientation Value: $detectedOrientationValue');

      // Calculate rotation info for debugging
      double rotationAngle = 0.0;
      bool needsHorizontalMirror = false;
      bool needsVerticalMirror = false;

      switch (detectedOrientationValue) {
        case 1:
          rotationAngle = 0.0;
          break;
        case 2:
          rotationAngle = 0.0;
          needsHorizontalMirror = true;
          break;
        case 3:
          rotationAngle = 180.0;
          break;
        case 4:
          rotationAngle = 0.0;
          needsVerticalMirror = true;
          break;
        case 5:
          rotationAngle = -270.0;
          needsHorizontalMirror = true;
          break;
        case 6:
          rotationAngle = -90.0; // Use same value as _getRotationAngle()
          break;
        case 7:
          rotationAngle = -90.0;
          needsHorizontalMirror = true;
          break;
        case 8:
          rotationAngle = -270.0;
          break;
        default:
          rotationAngle = 0.0;
      }

      debugPrint('Rotation Angle: $rotationAngle°');
      debugPrint('Needs Horizontal Mirror: $needsHorizontalMirror');
      debugPrint('Needs Vertical Mirror: $needsVerticalMirror');

      setState(() {
        exifData = exifDataMap;
        orientation = detectedOrientation;
        orientationValue = detectedOrientationValue;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading EXIF data: $e');
    }
  }

  // Read EXIF data using native_exif package
  Future<Map<String, dynamic>> _readWithNativeExif(File imageFile) async {
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

  int _getOrientationValue(Map<String, dynamic>? exifData) {
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

  String _getOrientationText(Map<String, dynamic>? exifData) {
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

  // Calculate rotation angle based on EXIF orientation
  double _getRotationAngle() {
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
    debugPrint('Needs Horizontal Mirror: ${_needsHorizontalMirror()}');
    debugPrint('Needs Vertical Mirror: ${_needsVerticalMirror()}');

    return angle;
  }

  // Check if image needs horizontal mirroring
  bool _needsHorizontalMirror() {
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
  bool _needsVerticalMirror() {
    switch (orientationValue) {
      case 4:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Exif Editor'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Text('No image selected'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'exif_editor'.tr,
          style: GoogleFonts.mPlusRounded1c(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          // EXIF Info button
          if (exifData != null && exifData!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Get.toNamed(ExifInfoPage.routeName, arguments: {
                  'imagePath': imagePath,
                  'originalFileName': originalFileName,
                  'exifData': exifData,
                  'orientation': orientation,
                  'orientationValue': orientationValue,
                });
              },
              tooltip: 'View EXIF Info',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main Image Preview
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Transform.rotate(
                    angle: _getRotationAngle() *
                        3.14159 /
                        180.0, // Convert degrees to radians
                    child: Transform.scale(
                      scaleX: _needsHorizontalMirror() ? -1.0 : 1.0,
                      scaleY: _needsVerticalMirror() ? -1.0 : 1.0,
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // child: Image.file(
                  //   File(imagePath!),
                  //   fit: BoxFit.contain,
                  //   errorBuilder: (context, error, stackTrace) {
                  //     return const Center(
                  //       child: Icon(
                  //         Icons.error,
                  //         size: 50,
                  //         color: Colors.red,
                  //       ),
                  //     );
                  //   },
                  // ),
                ),
              ),
            ),

            // Thumbnail and Orientation Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Thumbnail
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(ExifEditorPage.routeName, arguments: {
                        'imagePath': imagePath,
                        'orientation': orientation,
                        'orientationValue': orientationValue,
                        'originalFileName': originalFileName,
                      });
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.file(
                              File(imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.error,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                            // Overlay to indicate it's clickable
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Thumbnail Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'thumbnail'.tr,
                        style: GoogleFonts.mPlusRounded1c(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${'orientation'.tr}: $orientation (Value: $orientationValue)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Rotation: ${_getRotationAngle()}°',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
