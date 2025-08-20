import 'package:drug_search/revenue_cat/views/page/upgrade_subs_page.dart';
import 'package:drug_search/views/home_page.dart';
import 'package:drug_search/views/more_apps_page.dart';
import 'package:drug_search/views/settings/setting_page.dart';
import 'package:drug_search/views/exif_preview_page.dart';
import 'package:drug_search/views/exif_info_page.dart';
import 'package:drug_search/views/exif_editor_page.dart';
import 'package:drug_search/views/exif_library_selector_page.dart';
import 'package:get/get.dart';

class AppRoute {
  static final pages = [
    GetPage(
      name: SettingPage.routeName,
      page: () => const SettingPage(),
    ),
    GetPage(name: HomePage.routeName, page: () => const HomePage()),
    GetPage(name: MoreAppsPage.routeName, page: () => MoreAppsPage()),
    GetPage(name: SettingPage.routeName, page: () => const SettingPage()),
    GetPage(
        name: ExifPreviewPage.routeName, page: () => const ExifPreviewPage()),
    GetPage(name: ExifInfoPage.routeName, page: () => const ExifInfoPage()),
    GetPage(name: ExifEditorPage.routeName, page: () => const ExifEditorPage()),
    // GetPage(
    //     name: ExifLibrarySelectorPage.routeName,
    //     page: () => ExifLibrarySelectorPage(imagePath: Get.arguments)),
    GetPage(
        name: UpgradeSubsPage.routeName, page: () => const UpgradeSubsPage()),
    // GetPage(name: UpgradePage.routeName, page: () => UpgradePage()),
  ];
}
