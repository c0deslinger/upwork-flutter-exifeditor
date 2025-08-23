import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:drug_search/utils/album_saver.dart';

class ExifEditorPage extends StatefulWidget {
  static const routeName = "/exifEditor";

  const ExifEditorPage({super.key});

  @override
  State<ExifEditorPage> createState() => _ExifEditorPageState();
}

class _ExifEditorPageState extends State<ExifEditorPage> {
  String? imagePath;
  String? orientation;
  int? orientationValue;
  double currentRotation = 0.0;
  bool needsHorizontalMirror = false;
  bool needsVerticalMirror = false;
  String? originalFileName;

  @override
  void initState() {
    super.initState();
    // Get the arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      imagePath = arguments['imagePath'] as String?;
      orientation = arguments['orientation'] as String?;
      orientationValue = arguments['orientationValue'] as int?;
      originalFileName = arguments['originalFileName'] as String?;
    }

    // Calculate initial rotation and mirror settings
    _calculateInitialTransform();
  }

  void _calculateInitialTransform() {
    if (orientationValue == null) return;

    // Calculate initial rotation based on EXIF orientation
    switch (orientationValue) {
      case 1:
        currentRotation = 0.0;
        needsHorizontalMirror = false;
        needsVerticalMirror = false;
        break;
      case 2:
        currentRotation = 0.0;
        needsHorizontalMirror = true;
        needsVerticalMirror = false;
        break;
      case 3:
        currentRotation = 180.0;
        needsHorizontalMirror = false;
        needsVerticalMirror = false;
        break;
      case 4:
        currentRotation = 0.0;
        needsHorizontalMirror = false;
        needsVerticalMirror = true;
        break;
      case 5:
        currentRotation = -270.0;
        needsHorizontalMirror = true;
        needsVerticalMirror = false;
        break;
      case 6:
        currentRotation = -90.0;
        needsHorizontalMirror = false;
        needsVerticalMirror = false;
        break;
      case 7:
        currentRotation = -90.0;
        needsHorizontalMirror = true;
        needsVerticalMirror = false;
        break;
      case 8:
        currentRotation = -270.0;
        needsHorizontalMirror = false;
        needsVerticalMirror = false;
        break;
      default:
        currentRotation = 0.0;
        needsHorizontalMirror = false;
        needsVerticalMirror = false;
    }
  }

  void _rotateImage() {
    setState(() {
      // Rotate 90 degrees clockwise (positive in Flutter)
      currentRotation += 90.0;

      // Reset to 0 when reaching 360 degrees
      if (currentRotation >= 360) {
        currentRotation = 0;
      }
    });
  }

  // Calculate the new EXIF orientation value based on current rotation
  int _calculateNewOrientationValue() {
    // Start with the original orientation value
    int baseOrientation = orientationValue ?? 1;

    // Calculate how many 90-degree rotations have been applied
    int rotationCount = (currentRotation / 90).round();

    // Apply the rotations to the orientation value
    // EXIF orientation values: 1=normal, 3=180, 6=90CW, 8=270CW
    switch (baseOrientation) {
      case 1: // Normal
        switch (rotationCount % 4) {
          case 0:
            return 1; // 0°
          case 1:
            return 6; // 90° CW
          case 2:
            return 3; // 180°
          case 3:
            return 8; // 270° CW
        }
        break;
      case 3: // 180°
        switch (rotationCount % 4) {
          case 0:
            return 3; // 180°
          case 1:
            return 8; // 270° CW
          case 2:
            return 1; // 0°
          case 3:
            return 6; // 90° CW
        }
        break;
      case 6: // 90° CW
        switch (rotationCount % 4) {
          case 0:
            return 6; // 90° CW
          case 1:
            return 3; // 180°
          case 2:
            return 8; // 270° CW
          case 3:
            return 1; // 0°
        }
        break;
      case 8: // 270° CW
        switch (rotationCount % 4) {
          case 0:
            return 8; // 270° CW
          case 1:
            return 1; // 0°
          case 2:
            return 6; // 90° CW
          case 3:
            return 3; // 180°
        }
        break;
      default:
        return 1; // Default to normal
    }
    return 1;
  }

  Future<void> _saveImage(String originalFileName) async {
    debugPrint('Save button clicked! Starting save process...');

    // Show rename dialog first
    final TextEditingController nameController = TextEditingController(
      text: '$originalFileName',
    );

    final String? newFileName = await Get.dialog<String>(
      AlertDialog(
        title: Text(
          'Save Image',
          style: GoogleFonts.mPlusRounded1c(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a name for the image:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Image Name',
                hintText: 'Enter image name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixText: '.jpg',
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final fileName = nameController.text.trim();
              if (fileName.isNotEmpty) {
                Get.back(result: fileName);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.mPlusRounded1c(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    // If user cancelled the dialog, return
    if (newFileName == null) {
      return;
    }

    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Read the original image
      final File originalFile = File(imagePath!);
      if (!await originalFile.exists()) {
        Get.back(); // Close loading dialog
        Get.snackbar('Error', 'Original image file not found');
        return;
      }

      final Uint8List imageBytes = await originalFile.readAsBytes();
      debugPrint('Original image size: ${imageBytes.length} bytes');

      // Decode the image
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        Get.back(); // Close loading dialog
        Get.snackbar('Error', 'Failed to decode image');
        return;
      }

      debugPrint(
          'Original image dimensions: ${originalImage.width}x${originalImage.height}');

      // Calculate the new orientation value
      final int newOrientationValue = _calculateNewOrientationValue();
      debugPrint('New orientation value: $newOrientationValue');

      // Apply the rotation transformation to the image data
      img.Image rotatedImage = originalImage;
      if (currentRotation != 0) {
        debugPrint('Applying rotation: ${currentRotation.toInt()} degrees');
        rotatedImage =
            img.copyRotate(originalImage, angle: currentRotation.toInt());
        debugPrint(
            'Rotated image dimensions: ${rotatedImage.width}x${rotatedImage.height}');
      }

      // Encode the image
      final Uint8List encodedImage = img.encodeJpg(rotatedImage, quality: 95);
      debugPrint('Encoded image size: ${encodedImage.length} bytes');

      // Save the encoded image to a temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath =
          '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(encodedImage);
      debugPrint('Temporary file created: $tempPath');

      // Save image to gallery using AlbumSaver
      debugPrint('Saving to gallery using AlbumSaver...');

      try {
        if (Platform.isAndroid) {
          await AlbumSaver.saveImageToAlbum(tempFile, newFileName);
        } else {
          await AlbumSaver.saveImageToAlbumIos(tempFile, newFileName);
        }

        // Close loading dialog
        Get.back();

        // Show success message
        Get.snackbar(
          'Success',
          'Image saved to gallery successfully!\nSize: ${(encodedImage.length / 1024).toStringAsFixed(1)} KB',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );

        // Navigate back to previous page
        Get.back();
      } catch (e) {
        // Close loading dialog
        Get.back();
        throw Exception('Failed to save to gallery: $e');
      } finally {
        // Clean up temporary file
        if (await tempFile.exists()) {
          await tempFile.delete();
          debugPrint('Temporary file cleaned up');
        }
      }
    } catch (e) {
      debugPrint('Error saving image: $e');

      // Close loading dialog
      Get.back();

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to save image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('EXIF Editor'),
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

    final fileName = imagePath!.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EXIF Editor',
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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveImage(originalFileName ?? 'Unknown'),
            tooltip: 'Save Image',
          ),
        ],
      ),
      body: SafeArea(
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
                    'Editing: $fileName',
                    style: GoogleFonts.mPlusRounded1c(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Original Orientation: $orientation (Value: $orientationValue)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Main Image Display
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
                    angle: currentRotation *
                        3.14159 /
                        180.0, // Convert degrees to radians
                    child: Transform.scale(
                      scaleX: needsHorizontalMirror ? -1.0 : 1.0,
                      scaleY: needsVerticalMirror ? -1.0 : 1.0,
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
                ),
              ),
            ),

            // Control Panel
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                // border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // // Current rotation info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Rotation:',
                        style: GoogleFonts.mPlusRounded1c(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${currentRotation.toStringAsFixed(1)}°',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // // Original orientation info
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Original Orientation:',
                  //       style: GoogleFonts.mPlusRounded1c(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 14,
                  //       ),
                  //     ),
                  //     Text(
                  //       'Value: ${orientationValue ?? 1}',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         color: Colors.orange.shade700,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 8),

                  // // New orientation info
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'New Orientation:',
                  //       style: GoogleFonts.mPlusRounded1c(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 14,
                  //       ),
                  //     ),
                  //     Text(
                  //       'Value: ${_calculateNewOrientationValue()}',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         color: Colors.blue.shade700,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 16),

                  // Rotate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _rotateImage,
                      icon: const Icon(Icons.rotate_right),
                      label: Text(
                        'Rotate 90° Clockwise',
                        style: GoogleFonts.mPlusRounded1c(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  // Mirror info
                  if (needsHorizontalMirror || needsVerticalMirror)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mirror: ${needsHorizontalMirror ? "Horizontal" : ""}${needsHorizontalMirror && needsVerticalMirror ? " + " : ""}${needsVerticalMirror ? "Vertical" : ""}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
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
