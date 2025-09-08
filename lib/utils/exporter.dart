import 'dart:convert';
import 'dart:io';
import 'package:drug_search/controllers/global_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

class Exporter {
  // Add method to track deleted images
  static Future<void> addDeletedImage(String filename) async {
    final box = GetStorage();
    List<String> deletedImages =
        List<String>.from(box.read('deletedImages') ?? []);
    if (!deletedImages.contains(filename)) {
      deletedImages.add(filename);
      await box.write('deletedImages', deletedImages);
      debugPrint("Added to deleted images: $filename");
    }
  }

  static Future<List<String>> getDeletedImages() async {
    final box = GetStorage();
    return List<String>.from(box.read('deletedImages') ?? []);
  }

  static Future<void> clearDeletedImages() async {
    final box = GetStorage();
    await box.remove('deletedImages');
    debugPrint("Cleared deleted images list");
  }

  static Future<void> removeFromDeletedImages(String filename) async {
    final box = GetStorage();
    List<String> deletedImages =
        List<String>.from(box.read('deletedImages') ?? []);
    if (deletedImages.contains(filename)) {
      deletedImages.remove(filename);
      await box.write('deletedImages', deletedImages);
      debugPrint("Removed from deleted images: $filename");
    }
  }

  static Future<File?> zipFolder(String folder) async {
    try {
      debugPrint("Zipping folder: $folder");

      final Directory sourceDir = Directory(folder);
      if (!sourceDir.existsSync()) {
        debugPrint("Source directory does not exist: $folder");
        return null;
      }

      // Get target directory
      final tempDir = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getExternalStorageDirectory();

      if (tempDir == null) {
        debugPrint("Failed to get a valid directory for saving zip file");
        return null;
      }

      // Create a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipFilePath = path.join(tempDir.path, 'ImageRotator.zip');

      // Get list of deleted images to exclude
      final deletedImages = await getDeletedImages();
      debugPrint("Excluded deleted images: $deletedImages");

      // Get the list of jpg files
      List<File> jpgFiles = [];
      final entities = sourceDir.listSync(recursive: true);
      for (var entity in entities) {
        if (entity is File &&
            path.extension(entity.path).toLowerCase() == '.jpg' &&
            entity.existsSync() &&
            entity.lengthSync() > 0 &&
            !path.basename(entity.path).startsWith('custom_camera_')) {
          // Check if this file is in the deleted list
          final fileName = path.basename(entity.path);
          if (deletedImages.contains(fileName)) {
            debugPrint("Skipping deleted image: $fileName");
            continue;
          }

          jpgFiles.add(entity);
          debugPrint("Found valid JPG file: ${entity.path}");
        }
      }

      if (jpgFiles.isEmpty) {
        debugPrint("No valid JPG files found in folder");
        return null;
      }

      debugPrint("Starting zip creation with ${jpgFiles.length} files");

      // Use the ZipFileEncoder from archive_io.dart
      final zipFile = File(zipFilePath);
      if (zipFile.existsSync()) {
        await zipFile.delete();
      }

      debugPrint("Creating zip file at: $zipFilePath");

      // Create a simple file-based approach
      final encoder = ZipFileEncoder();
      encoder.create(zipFilePath);

      int successCount = 0;

      // Add files one by one with careful error handling
      for (var file in jpgFiles) {
        try {
          // Verify file exists and has content
          if (!file.existsSync()) {
            debugPrint("File doesn't exist anymore: ${file.path}");
            continue;
          }

          final fileSize = await file.length();
          if (fileSize <= 0) {
            debugPrint("File is empty: ${file.path}");
            continue;
          }

          // Read the file content in memory
          final bytes = await file.readAsBytes();
          if (bytes.isEmpty) {
            debugPrint("Failed to read file: ${file.path}");
            continue;
          }

          // Just get the file name without path
          final fileName = path.basename(file.path);
          if (fileName.startsWith("CAP_")) {
            continue;
          }

          debugPrint("Adding file to zip: $fileName");

          // Add the file to the zip using the archive API directly
          encoder.addArchiveFile(ArchiveFile(fileName, bytes.length, bytes));

          debugPrint("Successfully added file to zip: $fileName");
          successCount++;
        } catch (e) {
          debugPrint("Error processing file ${file.path}: $e");
          // Continue with next file
        }
      }

      // Close the zip file
      encoder.close();

      // Verify the zip file has content
      if (zipFile.existsSync()) {
        final zipInfo = await zipFile.stat();
        debugPrint("Zip file size: ${zipInfo.size} bytes");
        debugPrint("Successfully added $successCount files");

        if (zipInfo.size <= 22 || successCount == 0) {
          debugPrint("Warning: Zip file appears to be empty or corrupted");
          return null;
        }

        // Save the zip file path in storage
        await GetStorage().write("savedZip", zipFilePath);

        // Update global controller
        GlobalController globalController = Get.find();
        globalController.getSavedZip();

        debugPrint("Zip process completed successfully");
        return zipFile;
      } else {
        debugPrint("Zip file not created");
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint("Unexpected error during zip process: $e");
      debugPrint("Stack trace: $stackTrace");
      return null;
    }
  }
}

Future<String> createNewZipFromSelectedImages(
    List<String> selectedImages, String targetDir) async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final newZipPath = '$targetDir/ImageRotator.zip';

  debugPrint('Creating new zip at: $newZipPath');

  try {
    // Create a new archive in memory
    final archive = Archive();

    for (var imagePath in selectedImages) {
      try {
        debugPrint('Adding image to archive: $imagePath');
        final file = File(imagePath);

        if (!await file.exists()) {
          debugPrint('File does not exist: $imagePath');
          continue;
        }

        // Read file bytes
        final bytes = await file.readAsBytes();
        final fileSize = bytes.length;

        if (fileSize <= 0) {
          debugPrint('File is empty: $imagePath');
          continue;
        }

        // Use just the filename, not the full path
        final fileName = imagePath.split('/').last;

        // Add file to archive
        final archiveFile = ArchiveFile(fileName, fileSize, bytes);
        archive.addFile(archiveFile);

        debugPrint('Successfully added $fileName ($fileSize bytes) to archive');
      } catch (e) {
        debugPrint('Error adding file $imagePath: $e');
      }
    }

    // Encode the entire archive at once
    if (archive.isEmpty) {
      throw Exception('No files were added to the archive');
    }

    // Encode to zip format
    final zipData = ZipEncoder().encode(archive);
    if (zipData == null || zipData.isEmpty) {
      throw Exception('Failed to encode archive');
    }

    // Write zip data to file
    final outputFile = File(newZipPath);
    await outputFile.writeAsBytes(zipData);

    final finalSize = await outputFile.length();
    debugPrint('Created zip file, size: $finalSize bytes');

    if (finalSize <= 22) {
      throw Exception('Zip file is empty (size: $finalSize bytes)');
    }

    return newZipPath;
  } catch (e, stack) {
    debugPrint('Error creating zip: $e');
    debugPrint('Stack trace: $stack');

    // Fallback to a more basic approach if the first method fails
    try {
      final outputFile = File(newZipPath);
      final sink = outputFile.openWrite();

      // Create minimal valid zip file with one text file
      final archive = Archive();

      // Add a text file explaining the issue
      final errorMessage = 'Error creating zip: $e. Please try again.';
      final bytes = utf8.encode(errorMessage);
      archive.addFile(ArchiveFile('error.txt', bytes.length, bytes));

      // If we have any images, try adding at least one
      if (selectedImages.isNotEmpty) {
        try {
          final imagePath = selectedImages.first;
          final imageFile = File(imagePath);
          if (await imageFile.exists()) {
            final imageBytes = await imageFile.readAsBytes();
            final fileName = imagePath.split('/').last;
            archive
                .addFile(ArchiveFile(fileName, imageBytes.length, imageBytes));
          }
        } catch (imageError) {
          debugPrint('Fallback image error: $imageError');
        }
      }

      // Write zip data
      final zipData = ZipEncoder().encode(archive);
      sink.add(zipData!);

      await sink.close();

      final fallbackSize = await outputFile.length();
      debugPrint('Created fallback zip, size: $fallbackSize bytes');

      return newZipPath;
    } catch (fallbackError) {
      debugPrint('Fallback error: $fallbackError');

      // Last resort - create a text file instead of zip
      final txtPath = '$targetDir/error_$timestamp.txt';
      await File(txtPath).writeAsString('Failed to create zip: $e');
      return txtPath;
    }
  }
}

Future<void> extractZip(String zipFilePath, String targetDir) async {
  try {
    debugPrint('Begin to extract from $zipFilePath');

    // First, ensure the zip file exists
    final File zipFile = File(zipFilePath);
    bool isFileExist = await zipFile.exists();

    if (!isFileExist) {
      debugPrint('Error: Zip file does not exist at $zipFilePath');
      return;
    }

    debugPrint('Zip file exists: $isFileExist');

    // Create target directory if it doesn't exist
    final targetDirectory = Directory(targetDir);
    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    // Read the zip file
    List<int> bytes;
    try {
      bytes = await zipFile.readAsBytes();
    } catch (e) {
      debugPrint('Error reading zip file: $e');
      return;
    }

    // Decode the zip file
    Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
      debugPrint('Successfully decoded archive with ${archive.length} files');
    } catch (e) {
      debugPrint('Error decoding zip file: $e');
      return;
    }

    // Extract each file
    for (final file in archive) {
      debugPrint("Processing file ${file.name}");

      // Skip directory entry named "__MACOSX" (common in macOS-created zips)
      if (file.name.startsWith('__MACOSX/')) {
        continue;
      }

      // Create a sanitized filename that works across platforms
      final filename = '$targetDir/${file.name}'.replaceAll('\\', '/');

      if (file.isFile) {
        try {
          final fileData = file.content as List<int>;

          // Create parent directories if they don't exist
          final fileObj = File(filename);
          final parent = fileObj.parent;
          if (!await parent.exists()) {
            await parent.create(recursive: true);
          }

          // Write the file
          await fileObj.writeAsBytes(fileData);
          debugPrint("Successfully extracted $filename");
        } catch (e) {
          debugPrint("Error extracting file ${file.name}: $e");
        }
      } else {
        try {
          // Create directory
          await Directory(filename).create(recursive: true);
          debugPrint("Created directory $filename");
        } catch (e) {
          debugPrint("Error creating directory ${file.name}: $e");
        }
      }
    }

    debugPrint('Zip extraction completed');
  } catch (e, stackTrace) {
    debugPrint('Unexpected error during zip extraction: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}
