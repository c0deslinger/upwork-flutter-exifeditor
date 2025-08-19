// import 'package:metadata/metadata.dart';
// import 'dart:io';
// import 'package:native_exif/native_exif.dart';
// import 'package:flutter/material.dart' hide MetaData;
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:exif/exif.dart' as exif_package;
// import 'package:exif_reader/exif_reader.dart' as exif_reader_package;
// import 'package:image/image.dart' as img;
// import 'package:simple_exif/simple_exif.dart';
// import '../controllers/native_exif_controller.dart';
// import '../controllers/universal_exif_controller.dart';

// // import 'package:metadata/metadata.dart' as metadata_package;

// class ExifEditorPage extends StatefulWidget {
//   static const routeName = "/exifEditor";

//   const ExifEditorPage({super.key});

//   @override
//   State<ExifEditorPage> createState() => _ExifEditorPageState();
// }

// class _ExifEditorPageState extends State<ExifEditorPage> {
//   String? imagePath;
//   String? libraryType;
//   Map<String, dynamic>? exifData;
//   String orientation = "Normal";
//   int orientationValue = 1; // Add orientation value as integer
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     // Get the arguments from navigation
//     final arguments = Get.arguments as Map<String, dynamic>?;
//     if (arguments != null) {
//       imagePath = arguments['imagePath'] as String?;
//       libraryType = arguments['libraryType'] as String?;
//     }

//     if (imagePath != null && libraryType != null) {
//       _loadExifData();
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadExifData() async {
//     if (imagePath == null || libraryType == null) return;

//     try {
//       final File imageFile = File(imagePath!);

//       debugPrint('Reading EXIF data using library: $libraryType');
//       Map<String, dynamic> exifDataMap = {};

//       switch (libraryType) {
//         case 'native_exif':
//           debugPrint('Using Native EXIF library...');
//           exifDataMap = await _readWithNativeExif(imageFile);
//           break;
//         case 'exif_reader':
//           debugPrint('Using EXIF Reader library...');
//           exifDataMap = await _readWithExifReader(imageFile);
//           break;
//         case 'exif':
//           debugPrint('Using EXIF Package library...');
//           exifDataMap = await _readWithExifPackage(imageFile);
//           break;
//         case 'metadata':
//           debugPrint('Using Flutter Metadata library...');
//           exifDataMap = await _readWithMetadataPackage(imageFile);
//           break;
//         case 'simple_exif':
//           debugPrint('Using Simple Exif library...');
//           exifDataMap = await _readWithSimpleExif(imageFile);
//           break;
//         case 'image_library':
//           debugPrint('Using Image library...');
//           exifDataMap = await _readWithImageLibrary(imageFile);
//           break;
//         case 'combined':
//           debugPrint('Using Combined approach...');
//           exifDataMap = await _readWithCombinedApproach(imageFile);
//           break;
//         case 'native_platform':
//           debugPrint('Using Native Platform approach...');
//           exifDataMap = await _readWithNativePlatform(imageFile);
//           break;
//         case 'native_platform_advanced':
//           debugPrint('Using Native Platform Advanced approach...');
//           exifDataMap = await _readWithNativePlatformAdvanced(imageFile);
//           break;
//         case 'universal':
//           debugPrint('Using Universal approach...');
//           exifDataMap = await _readWithUniversalApproach(imageFile);
//           break;
//         default:
//           debugPrint('Unknown library type: $libraryType');
//           exifDataMap = {};
//       }

//       debugPrint('EXIF data loaded successfully');
//       debugPrint('Total EXIF tags found: ${exifDataMap.length}');

//       String detectedOrientation = _getOrientationText(exifDataMap);
//       int detectedOrientationValue = _getOrientationValue(exifDataMap);

//       debugPrint('=== ORIENTATION INFO ===');
//       debugPrint('Orientation Text: $detectedOrientation');
//       debugPrint('Orientation Value: $detectedOrientationValue');

//       // Calculate rotation info for debugging
//       double rotationAngle = 0.0;
//       bool needsHorizontalMirror = false;
//       bool needsVerticalMirror = false;

//       switch (detectedOrientationValue) {
//         case 1:
//           rotationAngle = 0.0;
//           break;
//         case 2:
//           rotationAngle = 0.0;
//           needsHorizontalMirror = true;
//           break;
//         case 3:
//           rotationAngle = 180.0;
//           break;
//         case 4:
//           rotationAngle = 0.0;
//           needsVerticalMirror = true;
//           break;
//         case 5:
//           rotationAngle = 270.0;
//           needsHorizontalMirror = true;
//           break;
//         case 6:
//           rotationAngle = 90.0;
//           break;
//         case 7:
//           rotationAngle = 90.0;
//           needsHorizontalMirror = true;
//           break;
//         case 8:
//           rotationAngle = 270.0;
//           break;
//         default:
//           rotationAngle = 0.0;
//       }

//       debugPrint('Rotation Angle: $rotationAngle°');
//       debugPrint('Needs Horizontal Mirror: $needsHorizontalMirror');
//       debugPrint('Needs Vertical Mirror: $needsVerticalMirror');

//       setState(() {
//         exifData = exifDataMap;
//         orientation = detectedOrientation;
//         orientationValue = detectedOrientationValue;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       debugPrint('Error loading EXIF data: $e');
//     }
//   }

//   // Read EXIF data using native_exif package
//   Future<Map<String, dynamic>> _readWithNativeExif(File imageFile) async {
//     try {
//       final exifData = await Exif.fromPath(imageFile.path);
//       final attributes = await exifData.getAttributes();

//       debugPrint('=== Native EXIF Results ===');
//       debugPrint('Total attributes found: ${attributes?.length ?? 0}');

//       // Try to get orientation specifically
//       try {
//         final orientation = await exifData.getAttribute('Orientation');
//         debugPrint('Native EXIF Orientation: $orientation');
//       } catch (e) {
//         debugPrint('Could not get orientation from native_exif: $e');
//       }

//       attributes?.forEach((key, value) {
//         debugPrint('EXIF Tag: $key = $value (Type: ${value.runtimeType})');
//       });

//       return attributes ?? {};
//     } catch (e) {
//       debugPrint('Error reading with native_exif: $e');
//       return {};
//     }
//   }

//   // Read EXIF data using exif_reader package
//   Future<Map<String, dynamic>> _readWithExifReader(File imageFile) async {
//     try {
//       final exifData = await exif_reader_package.readExifFromFile(imageFile);

//       debugPrint('=== EXIF Reader Results ===');
//       debugPrint('Total EXIF tags found: ${exifData.length}');

//       // Log all EXIF data with better formatting
//       exifData.forEach((key, value) {
//         debugPrint('EXIF Tag: $key = $value (Type: ${value.runtimeType})');
//       });

//       // Also try to get specific orientation data
//       if (exifData.containsKey('Orientation')) {
//         debugPrint('Orientation found: ${exifData['Orientation']}');
//       }

//       // Try different orientation keys
//       final orientationKeys = [
//         'Orientation',
//         'Image Orientation',
//         'EXIF Orientation'
//       ];
//       for (String key in orientationKeys) {
//         if (exifData.containsKey(key)) {
//           debugPrint('Found orientation with key "$key": ${exifData[key]}');
//         }
//       }

//       return exifData;
//     } catch (e) {
//       debugPrint('Error reading with exif_reader: $e');
//       return {};
//     }
//   }

//   Future<Map<String, dynamic>> _readWithMetadataPackage(File imageFile) async {
//     try {
//       final bytes = await imageFile.readAsBytes();
//       // final image = img.decodeImage(bytes); // Unused variable

//       debugPrint('=== Metadata Package Results ===');

//       var result = MetaData.exifData(bytes);
//       if (result.error == null) {
//         var content = result.exifData; // exif data is available in contents
//         debugPrint('content: $content');
//         // Try to ensure the result is a Map<String, dynamic>
//         if (content is Map<String, dynamic>) {
//           return content;
//         } else if (content is Map) {
//           // If it's a Map but not typed, cast it
//           return Map<String, dynamic>.from(content);
//         } else {
//           debugPrint(
//               'Unexpected EXIF data type from metadata package: ${content.runtimeType}');
//           return {};
//         }
//       } else {
//         // Remove the extra ".jpg" in the error print and clarify the file path
//         debugPrint("File: '${imageFile.path}', Error: ${result.error}");
//         return {};
//       }
//     } catch (e) {
//       debugPrint('Error reading with metadata package: $e');
//       return {};
//     }
//   }

//   // Read EXIF data using exif package
//   Future<Map<String, dynamic>> _readWithExifPackage(File imageFile) async {
//     try {
//       final bytes = await imageFile.readAsBytes();
//       final exifDataMap = await exif_package.readExifFromBytes(bytes);

//       debugPrint('=== EXIF Package Results ===');
//       debugPrint('Total EXIF tags found: ${exifDataMap.length}');
//       final result = <String, dynamic>{};

//       for (String key in exifDataMap.keys) {
//         final tag = exifDataMap[key];
//         if (tag != null) {
//           result[key] = tag.printable;
//           debugPrint(
//               'EXIF Tag: $key = ${tag.printable} (Type: ${tag.runtimeType})');

//           // Check if this is an orientation tag
//           if (key.toLowerCase().contains('orientation')) {
//             debugPrint(
//                 '*** ORIENTATION TAG FOUND: $key = ${tag.printable} ***');
//           }
//         }
//       }

//       // Try to get orientation specifically
//       final orientationTag = exifDataMap['Image Orientation'];
//       if (orientationTag != null) {
//         debugPrint('EXIF Package Orientation: ${orientationTag.printable}');
//       }

//       return result;
//     } catch (e) {
//       debugPrint('Error reading with exif package: $e');
//       return {};
//     }
//   }

//   Future<Map<String, dynamic>> _readWithSimpleExif(File imageFile) async {
//     try {
//       debugPrint('=== Simple Exif Results ===');
//       final bytes = await imageFile.readAsBytes();
//       final reader = ExifReader(bytes);
//       final result = <String, dynamic>{};

//       debugPrint('Total EXIF tags found: ${reader.getCopiedAllTags().length}');

//       for (ExifTag i in reader.getCopiedAllTags()) {
//         debugPrint(
//             'EXIF Tag: ${i.id} = ${i.value} (Type: ${i.value.runtimeType})');
//         result[i.id.toString()] = i.value;

//         // Check if this is an orientation tag
//         if (i.id.toString().toLowerCase().contains('orientation')) {
//           debugPrint(
//               '*** SIMPLE EXIF ORIENTATION TAG FOUND: ${i.id} = ${i.value} ***');
//         }
//       }

//       for (int i in reader.getAllTagIDs()) {
//         debugPrint('EXIF Tag ID: $i');
//       }

//       return result;
//     } catch (e) {
//       debugPrint('Error reading with simple_exif: $e');
//       return {};
//     }
//   }

//   // Read EXIF data using image library
//   Future<Map<String, dynamic>> _readWithImageLibrary(File imageFile) async {
//     try {
//       debugPrint('=== Image Library Results ===');
//       final bytes = await imageFile.readAsBytes();
//       final image = img.decodeImage(bytes);

//       if (image == null) {
//         debugPrint('Could not decode image');
//         return {};
//       }

//       final result = <String, dynamic>{};

//       // Try to get EXIF data from image
//       debugPrint('EXIF data found in image');
//       debugPrint('EXIF data: ${image.exif}');

//       debugPrint('EXIF imageIfd data: ${image.exif.imageIfd.data}');
//       debugPrint('EXIF gpsIfd data: ${image.exif.gpsIfd.data}');
//       debugPrint('EXIF exifIfd data: ${image.exif.exifIfd.data}');
//       debugPrint('EXIF interopIfd data: ${image.exif.interopIfd.data}');
//       debugPrint('EXIF thumbnailIfd data: ${image.exif.thumbnailIfd.data}');

//       // Try to get orientation from EXIF using tag ID
//       try {
//         // Orientation tag ID is 274
//         final orientation = image.exif.getTag(274);
//         if (orientation != null) {
//           debugPrint('*** IMAGE LIBRARY ORIENTATION FOUND: $orientation ***');
//           result['Orientation'] = orientation;
//         }
//       } catch (e) {
//         debugPrint('Could not get orientation from image EXIF: $e');
//       }

//       // Try to get all EXIF tags by iterating through known tag IDs
//       try {
//         final knownTags = {
//           274: 'Orientation',
//           271: 'Make',
//           272: 'Model',
//           306: 'DateTime',
//           33432: 'Copyright',
//         };

//         for (var entry in knownTags.entries) {
//           try {
//             final value = image.exif.getTag(entry.key);
//             if (value != null) {
//               result[entry.value] = value;
//               debugPrint('EXIF Tag: ${entry.value} = $value');
//             }
//           } catch (e) {
//             // Tag not found, continue
//           }
//         }
//       } catch (e) {
//         debugPrint('Could not get tags from image EXIF: $e');
//       }

//       return result;
//     } catch (e) {
//       debugPrint('Error reading with image library: $e');
//       return {};
//     }
//   }

//   // Read EXIF data using combined approach (tries multiple libraries)
//   Future<Map<String, dynamic>> _readWithCombinedApproach(File imageFile) async {
//     try {
//       debugPrint('=== Combined Approach Results ===');
//       final result = <String, dynamic>{};

//       // Try native_exif first
//       try {
//         debugPrint('Trying native_exif...');
//         final nativeResult = await _readWithNativeExif(imageFile);
//         result.addAll(nativeResult);
//         debugPrint('Native EXIF added ${nativeResult.length} tags');
//       } catch (e) {
//         debugPrint('Native EXIF failed: $e');
//       }

//       // Try exif_reader
//       try {
//         debugPrint('Trying exif_reader...');
//         final readerResult = await _readWithExifReader(imageFile);
//         result.addAll(readerResult);
//         debugPrint('EXIF Reader added ${readerResult.length} tags');
//       } catch (e) {
//         debugPrint('EXIF Reader failed: $e');
//       }

//       // Try exif package
//       try {
//         debugPrint('Trying exif package...');
//         final exifResult = await _readWithExifPackage(imageFile);
//         result.addAll(exifResult);
//         debugPrint('EXIF Package added ${exifResult.length} tags');
//       } catch (e) {
//         debugPrint('EXIF Package failed: $e');
//       }

//       // Try image library
//       try {
//         debugPrint('Trying image library...');
//         final imageResult = await _readWithImageLibrary(imageFile);
//         result.addAll(imageResult);
//         debugPrint('Image Library added ${imageResult.length} tags');
//       } catch (e) {
//         debugPrint('Image Library failed: $e');
//       }

//       debugPrint('Combined approach total tags: ${result.length}');
//       return result;
//     } catch (e) {
//       debugPrint('Error reading with combined approach: $e');
//       return {};
//     }
//   }

//   // Read EXIF data using native platform implementation
//   Future<Map<String, dynamic>> _readWithNativePlatform(File imageFile) async {
//     try {
//       debugPrint('=== Native Platform Results ===');

//       final result = await NativeExifController.readExifData(imageFile.path);

//       if (NativeExifController.isSuccess(result)) {
//         debugPrint('Native platform EXIF read successful');
//         debugPrint(
//             'Total tags found: ${NativeExifController.getTotalTags(result)}');

//         // Get orientation specifically
//         final orientation =
//             NativeExifController.getTagValue(result, 'Orientation');
//         if (orientation != null) {
//           debugPrint('*** NATIVE PLATFORM ORIENTATION FOUND: $orientation ***');
//         }

//         // Get all tags
//         final allTags = NativeExifController.getAllTags(result);
//         allTags.forEach((key, value) {
//           debugPrint('EXIF Tag: $key = $value');
//         });

//         return allTags;
//       } else {
//         debugPrint('Native platform EXIF read failed: ${result['error']}');
//         return {};
//       }
//     } catch (e) {
//       debugPrint('Error reading with native platform: $e');
//       return {};
//     }
//   }

//   // Read EXIF data using advanced native platform implementation
//   Future<Map<String, dynamic>> _readWithNativePlatformAdvanced(
//       File imageFile) async {
//     try {
//       debugPrint('=== Native Platform Advanced Results ===');

//       final result =
//           await NativeExifController.readExifDataAdvanced(imageFile.path);

//       if (NativeExifController.isSuccess(result)) {
//         debugPrint('Native platform advanced EXIF read successful');
//         debugPrint(
//             'Total tags found: ${NativeExifController.getTotalTags(result)}');

//         // Get orientation specifically
//         final orientation =
//             NativeExifController.getTagValue(result, 'Orientation');
//         final orientationValue = result['OrientationValue'];
//         if (orientation != null) {
//           debugPrint(
//               '*** NATIVE PLATFORM ADVANCED ORIENTATION FOUND: $orientation ***');
//         }
//         if (orientationValue != null) {
//           debugPrint(
//               '*** NATIVE PLATFORM ADVANCED ORIENTATION VALUE: $orientationValue ***');
//         }

//         // Check for GPS data
//         final latitude = result['Latitude'];
//         final longitude = result['Longitude'];
//         if (latitude != null && longitude != null) {
//           debugPrint('*** GPS COORDINATES FOUND: $latitude, $longitude ***');
//         }

//         // Check for thumbnail info
//         final hasThumbnail = result['HasThumbnail'];
//         if (hasThumbnail == true) {
//           debugPrint('*** THUMBNAIL FOUND ***');
//         }

//         // Check for file info
//         final fileSize = result['FileSize'];
//         if (fileSize != null) {
//           debugPrint('*** FILE SIZE: $fileSize bytes ***');
//         }

//         // Get all tags
//         final allTags = NativeExifController.getAllTags(result);
//         allTags.forEach((key, value) {
//           debugPrint('Advanced EXIF Tag: $key = $value');
//         });

//         return allTags;
//       } else {
//         debugPrint(
//             'Native platform advanced EXIF read failed: ${result['error']}');
//         return {};
//       }
//     } catch (e) {
//       debugPrint('Error reading with native platform advanced: $e');
//       return {};
//     }
//   }

//   // Read EXIF data using universal approach (works on all platforms)
//   Future<Map<String, dynamic>> _readWithUniversalApproach(
//       File imageFile) async {
//     try {
//       debugPrint('=== Universal Approach Results ===');
//       debugPrint('Platform: ${UniversalExifController.getPlatformInfo()}');

//       final result = await UniversalExifController.readExifData(imageFile);

//       if (UniversalExifController.isSuccess(result)) {
//         debugPrint('Universal EXIF read successful');
//         debugPrint(
//             'Total tags found: ${UniversalExifController.getTotalTags(result)}');

//         // Get orientation specifically
//         final orientation =
//             UniversalExifController.getTagValue(result, 'Orientation');
//         if (orientation != null) {
//           debugPrint('*** UNIVERSAL ORIENTATION FOUND: $orientation ***');
//         }

//         // Get all tags
//         final allTags = UniversalExifController.getAllTags(result);
//         allTags.forEach((key, value) {
//           debugPrint('EXIF Tag: $key = $value');
//         });

//         return allTags;
//       } else {
//         debugPrint('Universal EXIF read failed: ${result['error']}');
//         return {};
//       }
//     } catch (e) {
//       debugPrint('Error reading with universal approach: $e');
//       return {};
//     }
//   }

//   int _getOrientationValue(Map<String, dynamic>? exifData) {
//     if (exifData == null || exifData.isEmpty) {
//       debugPrint('No EXIF data available for orientation value');
//       return 1; // Default to normal orientation
//     }

//     // Try different possible keys for orientation
//     dynamic orientationValue;

//     // Try different possible keys - order matters, try most common first
//     final possibleKeys = [
//       'Image Orientation',
//       'Orientation',
//       'EXIF Orientation',
//       'IFD0 Orientation',
//       'Image:Orientation',
//       'IFD0:Orientation',
//       'orientation',
//       'ORIENTATION',
//       'Orientation',
//     ];

//     for (String key in possibleKeys) {
//       if (exifData.containsKey(key)) {
//         orientationValue = exifData[key];
//         debugPrint('Found orientation tag with key: $key = $orientationValue');
//         break;
//       }
//     }

//     if (orientationValue == null) {
//       debugPrint('No orientation tag found in EXIF data');
//       return 1; // Default to normal orientation
//     }

//     // Convert to integer for comparison
//     int? orientationInt;
//     try {
//       // Try to parse as integer
//       if (orientationValue is int) {
//         orientationInt = orientationValue;
//       } else if (orientationValue is String) {
//         // Try to parse as integer first
//         orientationInt = int.tryParse(orientationValue);
//         debugPrint('Parsed orientation integer from string: $orientationInt');

//         // If that fails, try to extract number from string
//         if (orientationInt == null) {
//           final numberMatch = RegExp(r'\d+').firstMatch(orientationValue);
//           if (numberMatch != null) {
//             final group = numberMatch.group(0);
//             if (group != null) {
//               orientationInt = int.tryParse(group);
//               debugPrint(
//                   'Extracted orientation integer from string: $orientationInt');
//             }
//           }
//         }

//         // If still null, try to match common orientation strings
//         if (orientationInt == null) {
//           final lowerValue = orientationValue.toLowerCase();
//           if (lowerValue.contains('90') && lowerValue.contains('cw')) {
//             orientationInt = 6; // Rotate 90 CW
//           } else if (lowerValue.contains('180')) {
//             orientationInt = 3; // Rotate 180
//           } else if (lowerValue.contains('270') && lowerValue.contains('cw')) {
//             orientationInt = 8; // Rotate 270 CW
//           }
//           debugPrint('Matched orientation string to integer: $orientationInt');
//         }
//       } else {
//         orientationInt = int.tryParse(orientationValue.toString());
//         debugPrint('Parsed orientation integer from toString: $orientationInt');
//       }

//       debugPrint('Final parsed orientation integer: $orientationInt');
//     } catch (e) {
//       debugPrint('Error parsing orientation value: $e');
//       return 1; // Default to normal orientation
//     }

//     if (orientationInt == null) {
//       debugPrint('Could not parse orientation value: $orientationValue');
//       return 1; // Default to normal orientation
//     }

//     // Validate orientation value
//     if (orientationInt >= 1 && orientationInt <= 8) {
//       return orientationInt;
//     } else {
//       debugPrint('Invalid orientation value: $orientationInt, defaulting to 1');
//       return 1; // Default to normal orientation
//     }
//   }

//   String _getOrientationText(Map<String, dynamic>? exifData) {
//     if (exifData == null || exifData.isEmpty) {
//       debugPrint('No EXIF data available');
//       return "Normal";
//     }

//     // Debug: Print all available EXIF tags
//     debugPrint('Available EXIF tags: ${exifData.keys.toList()}');

//     // Try different possible keys for orientation
//     dynamic orientationValue;

//     // Try different possible keys - order matters, try most common first
//     final possibleKeys = [
//       'Image Orientation',
//       'Orientation',
//       'EXIF Orientation',
//       'IFD0 Orientation',
//       'Image:Orientation',
//       'IFD0:Orientation',
//       'orientation',
//       'ORIENTATION',
//       'Orientation',
//     ];

//     for (String key in possibleKeys) {
//       if (exifData.containsKey(key)) {
//         orientationValue = exifData[key];
//         debugPrint('Found orientation tag with key: $key = $orientationValue');
//         break;
//       }
//     }

//     if (orientationValue == null) {
//       debugPrint('No orientation tag found in EXIF data');
//       return "Normal";
//     }

//     // Convert to integer for comparison
//     int? orientationInt;
//     try {
//       // Try to parse as integer
//       if (orientationValue is int) {
//         orientationInt = orientationValue;
//       } else if (orientationValue is String) {
//         // Try to parse as integer first
//         orientationInt = int.tryParse(orientationValue);
//         debugPrint('Parsed orientation integer from string: $orientationInt');

//         // If that fails, try to extract number from string
//         if (orientationInt == null) {
//           final numberMatch = RegExp(r'\d+').firstMatch(orientationValue);
//           if (numberMatch != null) {
//             final group = numberMatch.group(0);
//             if (group != null) {
//               orientationInt = int.tryParse(group);
//               debugPrint(
//                   'Extracted orientation integer from string: $orientationInt');
//             }
//           }
//         }

//         // If still null, try to match common orientation strings
//         if (orientationInt == null) {
//           final lowerValue = orientationValue.toLowerCase();
//           if (lowerValue.contains('90') && lowerValue.contains('cw')) {
//             orientationInt = 6; // Rotate 90 CW
//           } else if (lowerValue.contains('180')) {
//             orientationInt = 3; // Rotate 180
//           } else if (lowerValue.contains('270') && lowerValue.contains('cw')) {
//             orientationInt = 8; // Rotate 270 CW
//           }
//           debugPrint('Matched orientation string to integer: $orientationInt');
//         }
//       } else {
//         orientationInt = int.tryParse(orientationValue.toString());
//         debugPrint('Parsed orientation integer from toString: $orientationInt');
//       }

//       debugPrint('Final parsed orientation integer: $orientationInt');
//     } catch (e) {
//       debugPrint('Error parsing orientation value: $e');
//       return "Normal";
//     }

//     if (orientationInt == null) {
//       debugPrint('Could not parse orientation value: $orientationValue');
//       return "Normal";
//     }

//     switch (orientationInt) {
//       case 1:
//         return "Normal";
//       case 2:
//         return "Mirror Horizontal";
//       case 3:
//         return "Rotate 180";
//       case 4:
//         return "Mirror Vertical";
//       case 5:
//         return "Mirror Horizontal and Rotate 270 CW";
//       case 6:
//         return "Rotate 90 CW";
//       case 7:
//         return "Mirror Horizontal and Rotate 90 CW";
//       case 8:
//         return "Rotate 270 CW";
//       default:
//         debugPrint('Unknown orientation value: $orientationInt');
//         return "Normal";
//     }
//   }

//   // Calculate rotation angle based on EXIF orientation
//   double _getRotationAngle() {
//     switch (orientationValue) {
//       case 1:
//         return 0.0; // Normal
//       case 2:
//         return 0.0; // Mirror Horizontal (no rotation, just mirror)
//       case 3:
//         return 180.0; // Rotate 180
//       case 4:
//         return 0.0; // Mirror Vertical (no rotation, just mirror)
//       case 5:
//         return 270.0; // Mirror Horizontal and Rotate 270 CW
//       case 6:
//         return 90.0; // Rotate 90 CW
//       case 7:
//         return 90.0; // Mirror Horizontal and Rotate 90 CW
//       case 8:
//         return 270.0; // Rotate 270 CW
//       default:
//         return 0.0; // Default to normal
//     }
//   }

//   // Check if image needs horizontal mirroring
//   bool _needsHorizontalMirror() {
//     switch (orientationValue) {
//       case 2:
//       case 5:
//       case 7:
//         return true;
//       default:
//         return false;
//     }
//   }

//   // Check if image needs vertical mirroring
//   bool _needsVerticalMirror() {
//     switch (orientationValue) {
//       case 4:
//         return true;
//       default:
//         return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (imagePath == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Exif Editor'),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Get.back(),
//           ),
//         ),
//         body: const Center(
//           child: Text('No image selected'),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'exif_editor'.tr,
//           style: GoogleFonts.mPlusRounded1c(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Get.back(),
//         ),
//         actions: [
//           Container(
//             margin: const EdgeInsets.only(right: 16),
//             child: Center(
//               child: Text(
//                 libraryType?.toUpperCase() ?? '',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.purple.shade600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Main Image Preview
//             Expanded(
//               flex: 3,
//               child: Container(
//                 width: double.infinity,
//                 margin: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Transform.scale(
//                     scaleX: _needsHorizontalMirror() ? -1.0 : 1.0,
//                     scaleY: _needsVerticalMirror() ? -1.0 : 1.0,
//                     child: Transform.rotate(
//                       angle: _getRotationAngle() *
//                           3.14159 /
//                           180.0, // Convert degrees to radians
//                       child: Image.file(
//                         File(imagePath!),
//                         fit: BoxFit.contain,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Center(
//                             child: Icon(
//                               Icons.error,
//                               size: 50,
//                               color: Colors.red,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   // child: Image.file(
//                   //   File(imagePath!),
//                   //   fit: BoxFit.contain,
//                   //   errorBuilder: (context, error, stackTrace) {
//                   //     return const Center(
//                   //       child: Icon(
//                   //         Icons.error,
//                   //         size: 50,
//                   //         color: Colors.red,
//                   //       ),
//                   //     );
//                   //   },
//                   // ),
//                 ),
//               ),
//             ),

//             // Thumbnail and Orientation Section
//             Container(
//               margin: const EdgeInsets.all(16),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: Row(
//                 children: [
//                   // Thumbnail
//                   Container(
//                     width: 56,
//                     height: 56,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.file(
//                         File(imagePath!),
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Center(
//                             child: Icon(
//                               Icons.error,
//                               size: 20,
//                               color: Colors.red,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   // Thumbnail Info
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'thumbnail'.tr,
//                         style: GoogleFonts.mPlusRounded1c(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${'orientation'.tr}: $orientation (Value: $orientationValue)',
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 12,
//                         ),
//                       ),
//                       Text(
//                         'Rotation: ${_getRotationAngle()}° | Mirror: ${_needsHorizontalMirror() ? "H" : ""}${_needsVerticalMirror() ? "V" : ""}',
//                         style: TextStyle(
//                           color: Colors.grey.shade500,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
