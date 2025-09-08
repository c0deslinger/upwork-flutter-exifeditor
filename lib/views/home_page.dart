import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:drug_search/admob/ads_controller.dart';
import 'package:drug_search/admob/banner_ad.dart';
import 'package:drug_search/admob/interstitial_controller.dart';
import 'package:drug_search/controllers/file_controller.dart';
import 'package:drug_search/controllers/global_controller.dart';
import 'package:drug_search/admob/reward_ad_controller.dart';
import 'package:drug_search/utils/exporter.dart';
import 'package:drug_search/views/image_selection_page.dart';

import 'package:drug_search/views/settings/setting_page.dart';
import 'package:drug_search/views/exif_preview_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home";
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final AppOpenAdsController appOpenAdController = Get.find();
  final InterstitialController interstitialController = Get.find();
  final GlobalController globalController = Get.find();
  final RewardAdController rewardAdController = Get.find();
  final TextEditingController inputController = TextEditingController();
  final FileController fileController = Get.find();
  String _authStatus = 'Unknown';
  final InAppReview inAppReview = InAppReview.instance;
  bool canPop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((_) => initPlugin());
  }

  @override
  void dispose() {
    super.dispose();
    globalController.setNotFirstTime();
  }

  Future<void> initPlugin() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    debugPrint("auth status: $_authStatus $status");
    if (status == TrackingStatus.notDetermined) {
      await showCustomTrackingDialog(context);
      await Future.delayed(const Duration(milliseconds: 200));
      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
      debugPrint("auth status: $_authStatus");
    }
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('tracking_dialog_title'.tr),
          content: Text("tracking_dialog_desc".tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('tracking_dialog_continue'.tr),
            ),
          ],
        ),
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("current route: ${Get.currentRoute}");
      if (!globalController.isBackFromSelectImages &&
          (Get.currentRoute == "/" || Get.currentRoute == HomePage.routeName)) {
        debugPrint('[App Open] show open ad');
        appOpenAdController.showAppOpenAd();
        globalController.addRequestReviewCounter();
      }
    }
  }

  Future<void> _pickImagesFromGallery() async {
    globalController.isBackFromSelectImages = true;
    await fileController.pickMultipleImagesFromGallery(
      onPicked: (List<XFile> images) {
        Future.delayed(const Duration(seconds: 3), () {
          globalController.isBackFromSelectImages = false;
        });
        if (images.isNotEmpty) {
          debugPrint(
              "begin to open exif preview page with images: ${images.length}");

          // Navigate to ExifPreviewPage with multiple images
          Get.toNamed(
            ExifPreviewPage.routeName,
            arguments: {
              'imagePaths': images.map((img) => img.path).toList(),
              'originalFileNames': images.map((img) => img.name).toList(),
              'libraryType': 'native_exif',
            },
          );
        } else {
          // Show feedback when no images are selected or permission denied
          Get.snackbar(
            'No Images Selected',
            'No images were selected. Please try again or check your photo permissions.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
        }
      },
    );
  }

  Future<void> _onWillPop() async {
    if (globalController.requestReviewCounter >= 10 &&
        globalController.isLastShowReviewMoreThanOneMonth()) {
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
        globalController.addOneMonthToLastShowReview();
      } else {
        exit(0);
      }
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    debugPrint("isDarkMode: $isDarkMode ${Get.isDarkMode}");
    globalController.checkIsFirstTimeOpen();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'apptitle'.tr,
          style: GoogleFonts.mPlusRounded1c(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: InkWell(
          child: const Icon(Icons.settings),
          onTap: () {
            Get.toNamed(SettingPage.routeName);
          },
        ),
        centerTitle: true,
        actions: [
          GetBuilder<GlobalController>(builder: (globalControllerRes) {
            final String? savedZip = globalControllerRes.savedZip;
            debugPrint('saved zip: $savedZip');
            return Builder(builder: (context) {
              debugPrint("saved path ${globalControllerRes.savedZip}");
              return InkWell(
                onTap: () async {
                  if (savedZip == null) {
                    // Clear deleted images list when no ZIP is available
                    await Exporter.clearDeletedImages();
                    showAlertDialog(
                        context: context,
                        title: 'image_not_found_title'.tr,
                        content: 'image_not_found_desc'.tr);
                  } else {
                    // dataCameraController.isCameraStillCapture.value = true;
                    interstitialController.showInterstitialAds(() async {
                      if (context.mounted) {
                        selectImageToShare();
                      }
                    });
                  }
                },
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: const Icon(
                      Icons.download,
                      color: Colors.white,
                    )),
              );
            });
          }),
        ],
      ),
      body: SafeArea(
        child: PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, dynamic) {
            if (didPop) {
              return;
            }
            _onWillPop();
          },
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // Welcome Section
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 80,
                              color:
                                  Theme.of(context).appBarTheme.backgroundColor,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'exif_editor'.tr,
                              style: GoogleFonts.mPlusRounded1c(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Theme.of(context)
                                    .appBarTheme
                                    .backgroundColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'select_image_to_edit_exif'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImagesFromGallery(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                icon: const Icon(Icons.add_photo_alternate,
                                    size: 24),
                                label: Text(
                                  'select_multiple_images'.tr,
                                  style: GoogleFonts.mPlusRounded1c(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
      ),
    );
  }

  void showAlertDialog({
    required BuildContext context,
    String title = 'Alert', // Default title added
    required String content,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm?.call(); // Optional callback if needed
              },
              child: Text(confirmText ?? 'OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> selectImageToShare() async {
    String tempPath = "";
    final box = context.findRenderObject() as RenderBox?;
    if (Platform.isIOS) {
      tempPath = globalController.savedPath ?? "";
    } else {
      Directory tempDir = await getTemporaryDirectory();
      tempPath = "${tempDir.path}/extracted";
      await extractZip(globalController.savedZip!, tempPath);
    }

    debugPrint("temp path $tempPath");

    // Navigasi ke halaman pemilihan gambar
    final List<String>? selectedImages = await Get.to(() => ImageSelectionPage(
          tempPath: tempPath,
          originalZipPath:
              Platform.isAndroid ? globalController.savedZip : null,
          isIOS: Platform.isIOS,
        ));

    if (selectedImages != null && selectedImages.isNotEmpty) {
      String newZipPath =
          await createNewZipFromSelectedImages(selectedImages, tempPath);

      // Bagikan file ZIP baru
      XFile file = XFile(newZipPath);
      int size = await file.length();
      debugPrint("size $size");
      await Share.shareXFiles([file],
          sharePositionOrigin: Rect.fromLTWH(
              0,
              0,
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height / 2));

      File newZipFile = File(newZipPath);
      if (newZipFile.existsSync()) {
        newZipFile.deleteSync();
        debugPrint("deleted $newZipPath");
      }

      // Setelah kembali dari halaman, hapus folder sementara
      if (Platform.isAndroid) {
        await _deleteTempDirectory(tempPath);
      }
    }
  }

  Future<void> _deleteTempDirectory(String tempPath) async {
    debugPrint("delete directory");
    final dir = Directory(tempPath);
    if (await dir.exists()) {
      dir.deleteSync(recursive: true);
    }
  }
}
