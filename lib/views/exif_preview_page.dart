import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:drug_search/admob/banner_ad.dart';
import 'package:drug_search/admob/native_ad.dart';
import 'package:drug_search/exif_utils.dart';
import 'package:drug_search/views/exif_info_page.dart';
import 'package:drug_search/utils/album_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ExifPreviewPage extends StatefulWidget {
  static const routeName = "/exifPreview";

  const ExifPreviewPage({super.key});

  @override
  State<ExifPreviewPage> createState() => _ExifPreviewPageState();
}

class _ExifPreviewPageState extends State<ExifPreviewPage> {
  List<String> imagePaths = [];
  List<String> originalFileNames = [];
  String? libraryType;
  List<Map<String, dynamic>> exifDataList = [];
  List<String> orientations = [];
  List<int> orientationValues = [];
  List<double> currentRotations = [];
  bool isLoading = true;
  Set<int> selectedIndices = {};
  DateTime? loadingStartTime;
  bool isDialogShowing = false;
  bool hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Record loading start time
    loadingStartTime = DateTime.now();

    // Get the arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      imagePaths = List<String>.from(arguments['imagePaths'] ?? []);
      originalFileNames =
          List<String>.from(arguments['originalFileNames'] ?? []);
      libraryType = arguments['libraryType'] as String?;
    }

    if (imagePaths.isNotEmpty && libraryType != null) {
      _loadExifData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Show loading dialog after dependencies are available
    if (!hasInitialized &&
        imagePaths.isNotEmpty &&
        libraryType != null &&
        isLoading) {
      hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoadingDialog();
      });
    }
  }

  Future<void> _loadExifData() async {
    if (imagePaths.isEmpty || libraryType == null) return;

    try {
      exifDataList.clear();
      orientations.clear();
      orientationValues.clear();

      for (int i = 0; i < imagePaths.length; i++) {
        final File imageFile = File(imagePaths[i]);
        debugPrint(
            'Reading EXIF data for image ${i + 1}/${imagePaths.length} using library: $libraryType');

        Map<String, dynamic> exifDataMap =
            await ExifUtils.readWithNativeExif(imageFile);

        debugPrint('EXIF data loaded successfully for image ${i + 1}');
        debugPrint('Total EXIF tags found: ${exifDataMap.length}');

        String detectedOrientation = ExifUtils.getOrientationText(exifDataMap);
        int detectedOrientationValue =
            ExifUtils.getOrientationValue(exifDataMap);
        double rotationAngle =
            ExifUtils.getRotationAngle(detectedOrientationValue);

        debugPrint('=== ORIENTATION INFO for image ${i + 1} ===');
        debugPrint('Orientation Text: $detectedOrientation');
        debugPrint('Orientation Value: $detectedOrientationValue');
        debugPrint('Rotation Angle: $rotationAngle');

        exifDataList.add(exifDataMap);
        orientations.add(detectedOrientation);
        orientationValues.add(detectedOrientationValue);
        // currentRotations.add(0.0); // Initialize rotation to 0
        currentRotations
            .add(ExifUtils.getRotationAngle(detectedOrientationValue));
      }

      // Ensure minimum loading time of 5 seconds
      await _ensureMinimumLoadingTime();

      _hideLoadingDialog();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Ensure minimum loading time even on error
      await _ensureMinimumLoadingTime();

      _hideLoadingDialog();
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading EXIF data: $e');
    }
  }

  Future<void> _ensureMinimumLoadingTime() async {
    if (loadingStartTime != null) {
      final elapsed = DateTime.now().difference(loadingStartTime!);
      final minimumDuration = const Duration(seconds: 5);

      if (elapsed < minimumDuration) {
        final remainingTime = minimumDuration - elapsed;
        debugPrint(
            'Ensuring minimum loading time: ${remainingTime.inMilliseconds}ms remaining');
        await Future.delayed(remainingTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thumbnail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Text('No images selected'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedIndices.isNotEmpty
              ? 'selected_images'
                  .trParams({'count': selectedIndices.length.toString()})
              : 'thumbnail'.tr,
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
            icon: Icon(
              selectedIndices.length == imagePaths.length
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
            ),
            onPressed: () {
              setState(() {
                if (selectedIndices.length == imagePaths.length) {
                  // Deselect all
                  selectedIndices.clear();
                } else {
                  // Select all
                  selectedIndices = Set<int>.from(
                    List.generate(imagePaths.length, (index) => index),
                  );
                }
              });
            },
            tooltip: selectedIndices.length == imagePaths.length
                ? 'Deselect All'
                : 'Select All',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Grid of images
            Expanded(
              child: imagePaths.length < 1 || exifDataList.isEmpty
                  ? Container()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: imagePaths.length,
                      itemBuilder: (context, index) {
                        return _buildImageGridItem(index);
                      },
                    ),
            ),
            if (selectedIndices.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // // Current rotation info
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       'Current Rotation:',
                    //       style: GoogleFonts.mPlusRounded1c(
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 14,
                    //       ),
                    //     ),
                    //     Text(
                    //       '0.0°',
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         color: Colors.grey.shade700,
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
                        onPressed: _rotateSelectedImages,
                        icon: const Icon(Icons.rotate_right),
                        label: Text(
                          'rotate_clockwise'.tr,
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
                    const SizedBox(height: 12),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveSelectedImages,
                        icon: const Icon(Icons.save),
                        label: Text(
                          'save_images'.tr,
                          style: GoogleFonts.mPlusRounded1c(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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

  void _showLoadingDialog() {
    if (isDialogShowing) return;

    isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 179, 255, 228),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading indicator
                  Container(
                    padding: const EdgeInsets.all(20),
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   borderRadius: BorderRadius.circular(15),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.black.withOpacity(0.1),
                    //       blurRadius: 8,
                    //       offset: const Offset(0, 4),
                    //     ),
                    //   ],
                    // ),
                    child: Column(
                      children: [
                        // Spinning loading indicator
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 26, 53, 21)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Loading text
                        Text(
                          'loading_images'.tr,
                          style: GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          'processing_exif_data'.tr,
                          style: GoogleFonts.mPlusRounded1c(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Native Ad
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 300,
                      maxWidth: 300,
                    ),
                    child: const NativeAdAdmob(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    if (isDialogShowing) {
      isDialogShowing = false;
      Navigator.of(context).pop();
    }
  }

  Widget _buildImageGridItem(int index) {
    final imagePath = imagePaths[index];
    final fileName = originalFileNames[index];
    final exifData = exifDataList[index];
    final orientation = orientations[index];
    final orientationValue = orientationValues[index];
    final isSelected = selectedIndices.contains(index);

    return GestureDetector(
      onTap: () {
        Get.toNamed(ExifInfoPage.routeName, arguments: {
          'imagePath': imagePath,
          'exifData': exifData,
          'orientation': orientation,
          'orientationValue': orientationValue,
          'originalFileName': fileName,
        });
      },
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // Image Preview
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                        child: Transform.rotate(
                          // angle: (ExifUtils.getRotationAngle(orientationValue) +
                          //         currentRotations[index]) *
                          angle: (currentRotations[index]) * 3.14159 / 180.0,
                          child: Transform.scale(
                            scaleX: ExifUtils.needsHorizontalMirror(
                                    orientationValue)
                                ? -1.0
                                : 1.0,
                            scaleY:
                                ExifUtils.needsVerticalMirror(orientationValue)
                                    ? -1.0
                                    : 1.0,
                            child: GestureDetector(
                              onTap: () {},
                              child: Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
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
                        ),
                      ),
                    ),
                  ),

                  // Image Info (Compact)
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // File name
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                fileName,
                                style: GoogleFonts.mPlusRounded1c(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Orientation value
                        Text(
                          orientation,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Selection checkbox
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedIndices.remove(index);
                      } else {
                        selectedIndices.add(index);
                      }
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          )),
    );
  }

  void _rotateSelectedImages() {
    if (selectedIndices.isEmpty) return;
    _performBatchRotation();
  }

  void _performBatchRotation() {
    setState(() {
      for (int index in selectedIndices) {
        currentRotations[index] += 90.0;
        // Keep rotation between 0 and 360 degrees
        if (currentRotations[index] >= 360) {
          currentRotations[index] -= 360;
        }
      }
    });
  }

  Future<void> _saveSelectedImages() async {
    if (selectedIndices.isEmpty) return;

    // Show rename dialog with multiple text fields
    final List<TextEditingController> nameControllers = [];
    final List<String> originalFileExtensions = [];
    final List<String> selectedFileNames = [];

    for (int index in selectedIndices) {
      nameControllers.add(TextEditingController(
        text: originalFileNames[index].split('.').first,
      ));
      selectedFileNames.add(originalFileNames[index]);
      originalFileExtensions.add(originalFileNames[index].split('.').last);
    }

    final List<String>? newFileNames = await Get.dialog<List<String>>(
      AlertDialog(
        title: Center(
          child: Text(
            'save_rotated_images'.tr,
            style: GoogleFonts.mPlusRounded1c(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(selectedIndices.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameControllers[i],
                        decoration: InputDecoration(
                          labelText: 'image_name'
                              .trParams({'index': (i + 1).toString()}),
                          hintText:
                              'Enter image name (will be saved as: ${nameControllers[i].text}.${originalFileExtensions[i]})',
                          suffixText: '.${originalFileExtensions[i]}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final fileNames = nameControllers
                  .map((controller) => controller.text.trim())
                  .where((name) => name.isNotEmpty)
                  .toList();

              for (int i = 0; i < fileNames.length; i++) {
                fileNames[i] = '${fileNames[i]}.${originalFileExtensions[i]}';
                debugPrint('fileNames[i]: ${fileNames[i]}');
              }

              if (fileNames.length == selectedIndices.length) {
                Get.back(result: fileNames);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'save_all'.tr,
              style: GoogleFonts.mPlusRounded1c(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    // If user cancelled the dialog, return
    if (newFileNames == null) {
      return;
    }

    try {
      int successCount = 0;
      int totalCount = selectedIndices.length;

      // Process each selected image
      for (int i = 0; i < selectedIndices.length; i++) {
        final index = selectedIndices.elementAt(i);
        final imagePath = imagePaths[index];
        final fileName = newFileNames[i];

        try {
          // Read the original image
          final File originalFile = File(imagePath);
          if (!await originalFile.exists()) {
            continue;
          }

          final Uint8List imageBytes = await originalFile.readAsBytes();
          final img.Image? originalImage = img.decodeImage(imageBytes);
          if (originalImage == null) {
            continue;
          }

          // Apply rotation transformation
          debugPrint(
              'Rotating image $index by ${currentRotations[index]} degrees currentRotations[$index]: ${currentRotations[index]}');
          img.Image rotatedImage = originalImage;
          if (currentRotations[index] != 0) {
            rotatedImage = img.copyRotate(originalImage,
                angle: currentRotations[index].toInt());
          }

          // Encode the image
          final Uint8List encodedImage =
              img.encodeJpg(rotatedImage, quality: 95);

          // Save the encoded image to a temporary file
          final Directory tempDir = await getTemporaryDirectory();
          final String tempPath =
              '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
          final File tempFile = File(tempPath);
          await tempFile.writeAsBytes(encodedImage);

          // Save to gallery using AlbumSaver
          try {
            if (Platform.isAndroid) {
              await AlbumSaver.saveImageToAlbum(tempFile, fileName);
            } else {
              await AlbumSaver.saveImageToAlbumIos(tempFile, fileName);
            }
            successCount++;
          } catch (e) {
            print('Error saving image $index with AlbumSaver: $e');
          } finally {
            // Clean up temporary file
            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          }
        } catch (e) {
          print('Error saving image $index: $e');
        }
      }
      // // Show result
      if (successCount == totalCount) {
        Get.snackbar(
          'Success',
          'All $successCount image(s) saved to gallery successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Partial Success',
          '$successCount of $totalCount image(s) saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }

      // Clear selection after saving
      setState(() {
        selectedIndices.clear();
      });
    } catch (e) {
      print('Error in batch save: $e');
      Get.snackbar(
        'Error',
        'Failed to save images: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
