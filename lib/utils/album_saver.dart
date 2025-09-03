import 'dart:io';

import 'package:drug_search/controllers/global_controller.dart';
import 'package:drug_search/utils/exporter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_save/image_save.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';

class AlbumSaver {
  /// Saves an image to the album on iOS devices.
  ///
  /// [image] is the image file to be saved.
  /// [rename] is the new name for the image file.
  ///
  /// Returns the path of the saved image or null if an error occurred.
  static Future<String?> saveImageToAlbumIos(File image, String rename) async {
    // String toastMessage = "image_saved_gallery".tr;
    String? path;
    try {
      final String newPath = '${image.parent.path}/$rename.jpg';

      // Rename image
      final File renamedImage = image.renameSync(newPath);

      // Save image to album
      await ImageSave.saveImage(renamedImage.readAsBytesSync(), "$rename.jpg",
          albumName: "ImageRotator");

      // Remove from deleted images list if it was previously deleted
      await Exporter.removeFromDeletedImages("$rename.jpg");

      Exporter.zipFolder(renamedImage.parent.path);
      path = renamedImage.parent.path;
      GlobalController globalController = Get.find();
      globalController.setSavedPath(path: path);
    } catch (e) {}

    return path;
  }

  /// Saves an image to the album on Android devices.
  ///
  /// [imageFile] is the image file to be saved.
  /// [imageName] is the new name for the image file.
  static Future<void> saveImageToAlbum(File imageFile, String imageName) async {
    try {
      String relativePath = "Pictures/ImageRotator";
      final result = await SaverGallery.saveFile(
          filePath: imageFile.path,
          skipIfExists: false,
          fileName: imageName,
          androidRelativePath: relativePath);

      debugPrint("error ${result.errorMessage}");

      SaveResult saveResult = result;
      String toastMessage = "image_saved_gallery".tr;
      if (!saveResult.isSuccess) {
        toastMessage = "Error: ${saveResult.errorMessage!}";
      }

      // Remove from deleted images list if it was previously deleted
      await Exporter.removeFromDeletedImages(imageName);

      Directory? exDir = await getExternalStorageDirectory();

      if (exDir?.path != null) {
        String savedDir = _truncatePath(exDir!.path) + relativePath;
        debugPrint("saved $savedDir");
        Exporter.zipFolder(savedDir);
        // await GetStorage().write("savedDir", savedDir);
        // GlobalController globalController = Get.find();
        // globalController.getSavedPath();
      }

      Exporter.zipFolder(imageFile.path);

      // Fluttertoast.showToast(msg: toastMessage, gravity: ToastGravity.CENTER);
    } catch (e) {}
  }

  /// Truncates the path to remove the "Android" directory and its subdirectories.
  ///
  /// [path] is the original path.
  ///
  /// Returns the truncated path.
  static String _truncatePath(String path) {
    // Cari indeks pertama kemunculan direktori "Android"
    int androidIndex = path.indexOf('/Android/');
    // Jika tidak ditemukan, kembalikan string asli
    if (androidIndex == -1) {
      return path;
    }
    // Potong string hingga indeks "Android" pertama kali muncul
    String truncatedPath = path.substring(0, androidIndex);
    // Tambahkan kembali tanda / pada akhir path jika diperlukan
    if (!truncatedPath.endsWith('/')) {
      truncatedPath += '/';
    }
    return truncatedPath;
  }
}
