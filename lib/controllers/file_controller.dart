import 'package:drug_search/controllers/global_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class FileController extends GetxController {
  var imageCamera = ''.obs;
  var imageGallery = ''.obs;

  final ImagePicker _picker = ImagePicker();
  final GlobalController globalController = Get.find();

  Future<void> pickImageFromGallery(
      {required Function(XFile?) onPicked}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      // User cancelled picking image
      onPicked(null);
      return;
    }
    debugPrint('image.path: ${image.path}');
    debugPrint('image.name: ${image.path}');
    onPicked(image);
  }

  Future<void> pickMultipleImagesFromGallery(
      {required Function(List<XFile>) onPicked}) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) {
      // User cancelled picking images
      onPicked([]);
      return;
    }
    debugPrint('Selected ${images.length} images');
    for (var image in images) {
      debugPrint('image.path: ${image.path}');
      debugPrint('image.path base: ${path.basename(image.path)}');
      debugPrint('image.name: ${image.name}');
    }
    onPicked(images);
  }

  // Future<void> pickWithPhotoManager(
  //     {required Function(List<XFile>) onPicked}) async {
  //   try {
  //     // Request permission
  //     final PermissionState ps = await PhotoManager.requestPermissionExtend();
  //     debugPrint('ps: ${ps.isAuth}');

  //     if (!ps.isAuth) {
  //       // Permission denied - try using image_picker as fallback
  //       debugPrint('Photo permission denied, trying image_picker fallback');
  //       // await _pickWithImagePickerFallback(onPicked: onPicked);
  //       return;
  //     }

  //     // Get all image assets
  //     List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
  //       type: RequestType.image,
  //     );

  //     if (albums.isEmpty) {
  //       debugPrint('No albums found, trying image_picker fallback');
  //       await _pickWithImagePickerFallback(onPicked: onPicked);
  //       return;
  //     }

  //     List<AssetEntity> photos =
  //         await albums[0].getAssetListRange(start: 0, end: 1);

  //     if (photos.isEmpty) {
  //       debugPrint('No photos found in album, trying image_picker fallback');
  //       await _pickWithImagePickerFallback(onPicked: onPicked);
  //       return;
  //     }

  //     List<XFile> images = [];
  //     for (var photo in photos) {
  //       debugPrint('photo.title: ${photo.title}');
  //       debugPrint('photo.relativePath: ${photo.relativePath}');

  //       // Get the file path properly
  //       final file = await photo.file;
  //       if (file != null) {
  //         images.add(XFile(file.path));
  //       }
  //     }

  //     onPicked(images);
  //   } catch (e) {
  //     debugPrint('Error in pickWithPhotoManager: $e');
  //     // Try fallback method
  //     await _pickWithImagePickerFallback(onPicked: onPicked);
  //   }
  // }

  // Future<void> _pickWithImagePickerFallback(
  //     {required Function(List<XFile>) onPicked}) async {
  //   try {
  //     debugPrint('Using image_picker fallback');
  //     final List<XFile> images = await _picker.pickMultiImage();
  //     if (images.isEmpty) {
  //       debugPrint('No images selected with image_picker');
  //       onPicked([]);
  //       return;
  //     }
  //     debugPrint('Selected ${images.length} images with image_picker');
  //     onPicked(images);
  //   } catch (e) {
  //     debugPrint('Error in image_picker fallback: $e');
  //     onPicked([]);
  //   }
  // }

  Future<void> pickImageFromCamera(
      {required Function(String) onCaptured}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) {
      // User cancelled taking photo
      onCaptured('');
      return;
    }

    // final String compressedImagePath = await _compressImage(File(image.path));
    // imageCamera.value = compressedImagePath;
    onCaptured(image.path);
  }

  // /// Compress the image to ensure it is under 1 MB and has max dimensions of 1280x720.
  // /// Returns the path of the compressed image file.
  // Future<String> _compressImage(File file) async {
  //   const int maxDimension = 1280;
  //   const int maxSizeInBytes = 1024 * 1024; // 1 MB

  //   String targetPath = await _getTemporaryFilePath(file.path);
  //   // Check file extension
  //   String extension = path.extension(file.path).toLowerCase();
  //   CompressFormat format;
  //   if (extension == '.jpg' || extension == '.jpeg') {
  //     format = CompressFormat.jpeg;
  //   } else if (extension == '.png') {
  //     format = CompressFormat.png;
  //   } else {
  //     throw UnsupportedError('Only JPG and PNG images are supported');
  //   }

  //   XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
  //     file.absolute.path,
  //     targetPath,
  //     quality: 85,
  //     minWidth: maxDimension,
  //     minHeight: maxDimension,
  //     format: format,
  //   );

  //   if (compressedFile == null) {
  //     // Compression failed, return original file path
  //     return file.path;
  //   }

  //   // If compression didn't make the image <= 1MB, try reducing quality further
  //   int compressedFileLength = await compressedFile.length();
  //   int quality = 85;
  //   while (compressedFile != null &&
  //       compressedFileLength > maxSizeInBytes &&
  //       quality > 0) {
  //     quality -= 5;
  //     final String tempPath = await _getTemporaryFilePath(file.path);
  //     compressedFile = await FlutterImageCompress.compressAndGetFile(
  //       compressedFile.path,
  //       tempPath,
  //       quality: quality,
  //       minWidth: maxDimension,
  //       minHeight: maxDimension,
  //     );
  //     if (compressedFile == null) break; // if compression fails, break
  //   }

  //   return compressedFile?.path ?? file.path;
  // }

  // /// Generates a unique temporary file path for the compressed image.
  // ///
  // /// [originalFilePath] is the path of the original file.
  // Future<String> _getTemporaryFilePath(String originalFilePath) async {
  //   final Directory tempDir = await getTemporaryDirectory();
  //   final String fileName = path.basenameWithoutExtension(originalFilePath);
  //   final String extension = path.extension(originalFilePath);
  //   final String newFileName = '${fileName}_compressed$extension';
  //   return path.join(tempDir.path, newFileName);
  // }
}
