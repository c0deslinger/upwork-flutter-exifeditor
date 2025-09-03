import 'package:drug_search/admob/ads_controller.dart';
import 'package:drug_search/admob/interstitial_controller.dart';
import 'package:drug_search/controllers/file_controller.dart';
import 'package:drug_search/controllers/global_controller.dart';
import 'package:drug_search/admob/reward_ad_controller.dart';
import 'package:drug_search/controllers/ocr_controller.dart';
import 'package:drug_search/controllers/yahoo_jlp_controller.dart';
import 'package:drug_search/in_app_purchase/controller/in_app_purchase_controller.dart';
import 'package:drug_search/revenue_cat/controller/revenuecat_controller.dart';
import 'package:drug_search/revenue_cat/functions/revenue_cat_functions.dart';
import 'package:drug_search/routes/app_route.dart';
import 'package:drug_search/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'views/home_page.dart';
import 'locale/app_translation.dart';

void main() async {
  configureRevenueCatStore();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await GetStorage.init();
  await configureRevenueCatSdk();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalController globalController = Get.put(GlobalController());
    Get.put(FileController());
    Get.put(OcrController());
    Get.put(YahooJlpController());
    Get.put(AdsController());
    Get.put(RewardAdController());
    Get.put(RevenucatController(), permanent: true);
    Get.put(InAppPurchaseController());
    Get.put(InterstitialController());
    return GetBuilder<GlobalController>(
        init: globalController,
        builder: (appControllerVal) {
          return GetMaterialApp(
            title: 'Image Rotator',
            locale: appControllerVal.locale,
            theme: Get.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            translations: AppTranslation(),
            getPages: AppRoute.pages,
            home: const HomePage(),
          );
        });
  }
}
