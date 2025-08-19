import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:drug_search/admob/ads_controller.dart';
import 'package:drug_search/controllers/file_controller.dart';
import 'package:drug_search/controllers/global_controller.dart';
import 'package:drug_search/admob/reward_ad_controller.dart';

import 'package:drug_search/views/settings/setting_page.dart';
import 'package:drug_search/views/exif_preview_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home";
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final AdsController adsController = Get.find();
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
    // bool isFirstTimeOpen = await globalController.checkIsFirstTimeOpen();
    // if (state == AppLifecycleState.resumed && !isFirstTimeOpen) {
    //   adsController.showAppOpenAd();
    // } else {
    //   globalController.setNotFirstTime();
    // }
  }

  Future<void> _pickImageFromGallery() async {
    await fileController.pickImageFromGallery(
      onPicked: (XFile? image) {
        if (image != null) {
          // Navigate directly to ExifEditorPage with native_exif library
          Get.toNamed(
            ExifPreviewPage.routeName,
            arguments: {
              'imagePath': image.path,
              'originalFileName': image.name,
              'libraryType': 'native_exif',
            },
          );
        }
      },
    );
  }

  Future<void> _onWillPop() async {
    if (globalController.requestRewardAdCounter >= 2 &&
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
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              child: const Icon(CupertinoIcons.settings),
              onTap: () {
                Get.toNamed(SettingPage.routeName);
              },
            ),
          ),
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
                        color: Theme.of(context).appBarTheme.backgroundColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'exif_editor'.tr,
                        style: GoogleFonts.mPlusRounded1c(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Theme.of(context).appBarTheme.backgroundColor,
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
                          onPressed: () => _pickImageFromGallery(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).appBarTheme.backgroundColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.add_photo_alternate, size: 24),
                          label: Text(
                            'add_image_from_gallery'.tr,
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
      ),
    );
  }
}
