import 'dart:io';
import 'dart:ui';
import 'package:drug_search/admob/banner_ad.dart';
import 'package:drug_search/controllers/global_controller.dart';
import 'package:drug_search/utils/exporter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/rendering.dart';
import 'package:get_storage/get_storage.dart';

class ImageSelectionPage extends StatefulWidget {
  final String tempPath;
  final String? originalZipPath;
  final bool isIOS;

  const ImageSelectionPage(
      {required this.tempPath,
      this.originalZipPath,
      this.isIOS = false,
      Key? key})
      : super(key: key);

  @override
  ImageSelectionPageState createState() => ImageSelectionPageState();
}

class ImageSelectionPageState extends State<ImageSelectionPage> {
  final Set<int> selectedIndexes = <int>{};
  final key = GlobalKey();
  final Set<MyRenderObject> _trackTaped = <MyRenderObject>{};
  final ScrollController _scrollController = ScrollController();

  // Ubah dari direct initialization ke late declaration
  late GlobalController globalController;

  List<String> imagePaths = [];
  List<String> selectedImages = [];
  bool _isUpdatingZip = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers di sini untuk memastikan binding sudah selesai
    // dataCameraController = Get.find();
    globalController = Get.find();

    _loadImages();

    // Future.delayed(const Duration(milliseconds: 500), () {
    //   dataCameraController.isCameraStillCapture.value = false;
    // });
  }

  void _loadImages() {
    try {
      final dir = Directory(widget.tempPath);
      // First check if the directory exists
      if (!dir.existsSync()) {
        // Create the directory if it doesn't exist
        dir.createSync(recursive: true);
        setState(() {
          imagePaths = [];
        });
        return;
      }

      // Now safely get the list of files
      final files = dir.listSync(recursive: false, followLinks: false);

      setState(() {
        imagePaths = files
            .where((file) {
              final path = file.path;
              return file is File &&
                  !path.contains(" (") &&
                  !path.contains("custom_camera_") &&
                  !isPathContainMinusMorethanThree(path) &&
                  (path.endsWith('.jpg') || path.endsWith('.png'));
            })
            .map((file) => file.path)
            .toList();

        // Sort imagePaths based on the last modified time in descending order
        imagePaths.sort((a, b) {
          File fileA = File(a);
          File fileB = File(b);

          if (!fileA.existsSync() || !fileB.existsSync()) {
            return 0;
          }

          final aModified = fileA.statSync().modified;
          final bModified = fileB.statSync().modified;
          return bModified.compareTo(aModified);
        });
      });
    } catch (e) {
      debugPrint("Error loading images: $e");
      setState(() {
        imagePaths = [];
      });
    }
  }

  bool isPathContainMinusMorethanThree(String path) {
    if (Platform.isIOS) return false;
    int count = 0;
    for (int i = 0; i < path.length; i++) {
      if (path[i] == "-") {
        count++;
      }
    }
    return count > 3;
  }

  void _toggleSelectAll() {
    setState(() {
      if (selectedIndexes.length == imagePaths.length) {
        _clearSelection();
      } else {
        for (int i = 0; i < imagePaths.length; i++) {
          _selectIndex(i);
        }
      }
    });
  }

  _detectTapedItem(PointerEvent event) {
    if (key.currentContext == null) return;

    final RenderBox box =
        key.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is MyRenderObject && !_trackTaped.contains(target)) {
          _trackTaped.add(target);
          if (selectedIndexes.contains(target.index)) {
            _removeIndex(target.index);
          } else {
            _selectIndex(target.index);
          }
        }
      }
    }
  }

  _selectIndex(int index) {
    setState(() {
      selectedIndexes.add(index);
      selectedImages.add(imagePaths[index]);
      debugPrint("Selected images: ${selectedImages.join(', ')}");
    });
  }

  _removeIndex(int index) {
    setState(() {
      selectedIndexes.remove(index);
      selectedImages.remove(imagePaths[index]);
      debugPrint("Selected images after removal: ${selectedImages.join(', ')}");
    });
  }

  void _clearSelection() {
    _trackTaped.clear();
    setState(() {
      selectedIndexes.clear();
      selectedImages.clear();
      debugPrint("All selections cleared");
    });
  }

  void _clearTrackTaped(PointerUpEvent event) {
    _trackTaped.clear();
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final count = selectedIndexes.length;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('delete_confirmation_title'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('delete_confirmation_desc'.tr),
              if (!widget.isIOS && widget.originalZipPath != null) ...[
                const SizedBox(height: 8),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('delete_confirmation_cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('delete_confirmation_delete'.tr),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSelectedImages();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedImages() async {
    setState(() {
      _isUpdatingZip = true;
    });

    try {
      // Hapus file dari sistem
      final List<String> toDelete =
          selectedIndexes.map((i) => imagePaths[i]).toList();
      for (final path in toDelete) {
        try {
          final file = File(path);
          if (file.existsSync()) {
            file.deleteSync();
          }
          // Track deleted image filename for future ZIP creation
          final fileName = path.split('/').last;
          await Exporter.addDeletedImage(fileName);
          debugPrint("Tracked deleted image: $fileName");
        } catch (e) {
          debugPrint("Gagal menghapus file $path: $e");
        }
      }

      // Update original ZIP file if we're on Android
      if (!widget.isIOS && widget.originalZipPath != null) {
        await _updateOriginalZipFile(toDelete);
      }

      // Hapus dari list dan reset selection
      setState(() {
        imagePaths.removeWhere((path) => toDelete.contains(path));
        selectedIndexes.clear();
        selectedImages.clear();
      });
      debugPrint("Gambar terpilih berhasil dihapus");
    } finally {
      setState(() {
        _isUpdatingZip = false;
      });
    }
  }

  Future<void> _updateOriginalZipFile(List<String> deletedPaths) async {
    try {
      debugPrint("Updating original ZIP file...");

      // Get remaining images (those not deleted)
      final List<String> remainingImages =
          imagePaths.where((path) => !deletedPaths.contains(path)).toList();

      if (remainingImages.isEmpty) {
        debugPrint("No remaining images, deleting ZIP file");
        // If no images left, delete the ZIP file
        final zipFile = File(widget.originalZipPath!);
        if (zipFile.existsSync()) {
          zipFile.deleteSync();
        }
        // Clear saved ZIP from storage
        GetStorage().remove("savedZip");
        // Clear deleted images list since we have no images left
        await Exporter.clearDeletedImages();
        globalController.getSavedZip();
        return;
      }

      // Create new ZIP with remaining images
      final newZipPath = await createNewZipFromSelectedImages(
          remainingImages, widget.tempPath);

      // Replace the original ZIP file
      final newZipFile = File(newZipPath);
      final originalZipFile = File(widget.originalZipPath!);

      if (newZipFile.existsSync()) {
        // Copy the new ZIP to replace the original
        final newZipBytes = await newZipFile.readAsBytes();
        await originalZipFile.writeAsBytes(newZipBytes);

        // Delete the temporary new ZIP
        newZipFile.deleteSync();

        // Update the global controller to refresh the saved ZIP info
        globalController.getSavedZip();

        debugPrint("Original ZIP file updated successfully");
      }
    } catch (e) {
      debugPrint("Error updating original ZIP file: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("select_images".tr),
        actions: [
          IconButton(
            icon: Icon(
              selectedIndexes.length == imagePaths.length
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
            ),
            onPressed: _toggleSelectAll,
            tooltip: selectedImages.length == imagePaths.length
                ? "Unselect All"
                : "Select All",
          ),
          if (selectedIndexes.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                debugPrint(
                    "Final selected images: ${selectedImages.join('\n')}");
                Navigator.pop(context, selectedImages);
              },
              tooltip: "Share",
            ),
            IconButton(
              icon: _isUpdatingZip
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete),
              onPressed: _isUpdatingZip
                  ? null
                  : () async {
                      await _showDeleteConfirmationDialog();
                    },
              tooltip: _isUpdatingZip ? "Updating..." : "Delete",
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: imagePaths.isEmpty
                ? Center(
                    child: Text("no_images_found".tr),
                  )
                : Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    interactive: true,
                    child: Listener(
                      onPointerDown: _detectTapedItem,
                      onPointerMove: _detectTapedItem,
                      onPointerUp: _clearTrackTaped,
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
                        onNotification:
                            (OverscrollIndicatorNotification notification) {
                          notification.disallowIndicator();
                          return true;
                        },
                        child: ScrollConfiguration(
                          behavior: NoScrollBehavior(),
                          child: GridView.builder(
                            key: key,
                            controller: _scrollController,
                            itemCount: imagePaths.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 5.0,
                              mainAxisSpacing: 5.0,
                            ),
                            itemBuilder: (context, index) {
                              final imagePath = imagePaths[index];
                              return RenderObjectWidget(
                                index: index,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.file(
                                        File(imagePath),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(Icons.broken_image,
                                                color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    if (selectedIndexes.contains(index))
                                      const Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.green),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          // BannerAdmob(
          //     adunitAndroid: ConfigReader.getBannerAdunitAndroid(),
          //     adunitIos: ConfigReader.getBannerAdunitIos()),
        ],
      ),
    );
  }
}

class NoScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices {
    return {}; // Disable all touch gestures for scrolling
  }
}

class RenderObjectWidget extends SingleChildRenderObjectWidget {
  final int index;

  const RenderObjectWidget(
      {required Widget child, required this.index, Key? key})
      : super(child: child, key: key);

  @override
  MyRenderObject createRenderObject(BuildContext context) {
    return MyRenderObject(index);
  }

  @override
  void updateRenderObject(BuildContext context, MyRenderObject renderObject) {
    renderObject.index = index;
  }
}

class MyRenderObject extends RenderProxyBox {
  int index;
  MyRenderObject(this.index);
}
