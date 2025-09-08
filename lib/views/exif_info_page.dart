import 'dart:io';

import 'package:drug_search/admob/banner_ad.dart';
import 'package:drug_search/views/exif_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ExifInfoPage extends StatefulWidget {
  static const routeName = "/exifInfo";

  const ExifInfoPage({super.key});

  @override
  State<ExifInfoPage> createState() => _ExifInfoPageState();
}

class _ExifInfoPageState extends State<ExifInfoPage> {
  String? imagePath;
  Map<String, dynamic>? exifData;
  String? orientation;
  int? orientationValue;
  String? originalFileName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Get the arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      imagePath = arguments['imagePath'] as String?;
      exifData = arguments['exifData'] as Map<String, dynamic>?;
      orientation = arguments['orientation'] as String?;
      orientationValue = arguments['orientationValue'] as int?;
      originalFileName = arguments['originalFileName'] as String?;
    }

    setState(() {
      isLoading = false;
    });
  }

  // Format EXIF key for display
  String _formatExifKey(String key) {
    // Convert camelCase or snake_case to Title Case
    String formatted = key
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .replaceAllMapped(
          RegExp(r'_([a-z])'),
          (match) => ' ${match.group(1)?.toUpperCase()}',
        )
        .trim();

    // Capitalize first letter of each word
    String capitalized = formatted.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return capitalized
        .toLowerCase()
        .replaceAll(" ", "_")
        .replaceAll("__", "_")
        .tr;
  }

  // Format EXIF value for display
  String _formatExifValue(dynamic value) {
    if (value == null) return 'N/A';

    String stringValue = value.toString();

    // Handle special cases
    if (stringValue.contains('/')) {
      // Handle fraction values like "54823/32325"
      try {
        List<String> parts = stringValue.split('/');
        if (parts.length == 2) {
          double numerator = double.parse(parts[0]);
          double denominator = double.parse(parts[1]);
          if (denominator != 0) {
            double result = numerator / denominator;
            return '${result.toStringAsFixed(2)} (${stringValue})';
          }
        }
      } catch (e) {
        // If parsing fails, return original value
      }
    }

    // Handle decimal values
    if (stringValue.contains('.')) {
      try {
        double doubleValue = double.parse(stringValue);
        return doubleValue.toStringAsFixed(2);
      } catch (e) {
        // If parsing fails, return original value
      }
    }

    return stringValue;
  }

  // Get category for EXIF tag
  String _getExifCategory(String key) {
    final lowerKey = key.toLowerCase();

    if (lowerKey.contains('width') ||
        lowerKey.contains('length') ||
        lowerKey.contains('height') ||
        lowerKey.contains('size')) {
      return 'Image';
    }

    if (lowerKey.contains('make') ||
        lowerKey.contains('model') ||
        lowerKey.contains('software') ||
        lowerKey.contains('lens')) {
      return 'Camera';
    }

    if (lowerKey.contains('exposure') ||
        lowerKey.contains('aperture') ||
        lowerKey.contains('iso') ||
        lowerKey.contains('focal') ||
        lowerKey.contains('flash') ||
        lowerKey.contains('white')) {
      return 'Exposure';
    }

    if (lowerKey.contains('date') || lowerKey.contains('time')) {
      return 'Date/Time';
    }

    if (lowerKey.contains('orientation')) {
      return 'Image';
    }

    return 'Other';
  }

  // Calculate rotation angle based on EXIF orientation
  double _getRotationAngle() {
    if (orientationValue == null) return 0.0;

    switch (orientationValue) {
      case 1:
        return 0.0; // Normal
      case 2:
        return 0.0; // Mirror Horizontal (no rotation, just mirror)
      case 3:
        return 180.0; // Rotate 180
      case 4:
        return 0.0; // Mirror Vertical (no rotation, just mirror)
      case 5:
        return -270.0; // Mirror Horizontal and Rotate 270 CW
      case 6:
        return -90.0; // Rotate 90 CW
      case 7:
        return -90.0; // Mirror Horizontal and Rotate 90 CW
      case 8:
        return -270.0; // Rotate 270 CW
      default:
        return 0.0; // Default to normal
    }
  }

  // Check if image needs horizontal mirroring
  bool _needsHorizontalMirror() {
    if (orientationValue == null) return false;

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
    if (orientationValue == null) return false;

    switch (orientationValue) {
      case 4:
        return true;
      default:
        return false;
    }
  }

  // Group EXIF data by category
  Map<String, List<MapEntry<String, dynamic>>> _groupExifData() {
    if (exifData == null) return {};

    Map<String, List<MapEntry<String, dynamic>>> grouped = {};

    exifData!.entries.forEach((entry) {
      String category = _getExifCategory(entry.key);
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(entry);
    });

    // Add transform information if available
    if (orientationValue != null) {
      if (!grouped.containsKey('Transform')) {
        grouped['Transform'] = [];
      }

      grouped['Transform']!
          .add(MapEntry('Orientation Value', orientationValue.toString()));
      grouped['Transform']!
          .add(MapEntry('Orientation Text', orientation ?? 'Unknown'));
      grouped['Transform']!
          .add(MapEntry('Rotation Angle', '${_getRotationAngle()}°'));
      grouped['Transform']!.add(MapEntry(
          'Needs Horizontal Mirror', _needsHorizontalMirror().toString()));
      grouped['Transform']!.add(
          MapEntry('Needs Vertical Mirror', _needsVerticalMirror().toString()));
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || exifData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('exif_info'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Text('No EXIF data available'),
        ),
      );
    }

    final groupedData = _groupExifData();
    final fileName = originalFileName ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'exif_info'.tr,
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // Header with filename
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'exif_info'.tr}: $fileName',
                          style: GoogleFonts.mPlusRounded1c(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'exif_tags_found'
                              .trParams({'count': exifData!.length.toString()}),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Transform.rotate(
                    angle: (_getRotationAngle()) * 3.14159 / 180.0,
                    child: Transform.scale(
                      scaleX: _needsHorizontalMirror() ? -1.0 : 1.0,
                      scaleY: _needsVerticalMirror() ? -1.0 : 1.0,
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error,
                              size: 30,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  //thumbnail
                  GestureDetector(
                    onTap: () async {
                      Get.toNamed(ExifEditorPage.routeName, arguments: {
                        'imagePath': imagePath,
                        'orientation': orientation,
                        'orientationValue': orientationValue,
                        'originalFileName': originalFileName,
                      });
                    },
                    child: Container(
                        width: double.infinity,
                        margin:
                            const EdgeInsets.only(left: 16, right: 16, top: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(imagePath!),
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'thumbnail'.tr,
                                    style: GoogleFonts.mPlusRounded1c(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'orientation: $orientation'.tr,
                                    style: GoogleFonts.mPlusRounded1c(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'rotation: ${_getRotationAngle()}°'.tr,
                                    style: GoogleFonts.mPlusRounded1c(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),

                  const SizedBox(height: 16),

                  // Thumbnail and main content
                  Expanded(
                    child: Row(
                      children: [
                        // EXIF data sections
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: groupedData.entries.map((categoryEntry) {
                              String category = categoryEntry.key;
                              List<MapEntry<String, dynamic>> entries =
                                  categoryEntry.value;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category header
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        category.toLowerCase().tr,
                                        style: GoogleFonts.mPlusRounded1c(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // EXIF entries
                                    ...entries.map((entry) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Key
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                _formatExifKey(entry.key),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Value
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                _formatExifValue(entry.value),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const BannerAdmob(
              adunitAndroid: 'ca-app-pub-4385164164114125/5843497114',
              adunitIos: 'ca-app-pub-4385164164114125/9635989197',
            ),
          ],
        ),
      ),
    );
  }
}
