import 'dart:io';

import 'package:drug_search/admob/banner_ad.dart';
import 'package:drug_search/controllers/global_controller.dart';
import 'package:drug_search/views/more_apps_page.dart';
import 'package:drug_search/views/settings/inapp_purchase_list_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatefulWidget {
  static const routeName = "/setting";
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('about'.tr),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "about_desc".tr,
                ),
                const SizedBox(height: 10),
                Text(
                  'disclaimer_title'.tr,
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'disclaimer_sub'.tr,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    GlobalController globalController = Get.find();
    return Scaffold(
      // backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        title: Text("setting".tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    subMenu(
                        "error_report".tr,
                        const Icon(
                          CupertinoIcons.info,
                          // color: iconColor,
                          size: 24,
                        ), () async {
                      final Uri url =
                          Uri.parse('https://tombstone.space/contact/');
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                    }),
                    GetBuilder<GlobalController>(builder: (globalController) {
                      return subMenu(
                        "dark_mode".tr,
                        const Icon(CupertinoIcons.lightbulb_fill, size: 24),
                        () {
                          globalController.toggleDarkMode();
                        },
                        value: Switch(
                          value: globalController.isDarkMode,
                          onChanged: (value) {
                            globalController.toggleDarkMode();
                          },
                        ),
                      );
                    }),
                    GetBuilder<GlobalController>(builder: (globalController) {
                      String currentLocale =
                          globalController.locale.languageCode;
                      debugPrint("language $currentLocale");
                      String language =
                          currentLocale.contains("ja") ? "Japanese" : "English";
                      return subMenu(
                          "language".tr,
                          SvgPicture.asset(
                            'assets/ic_translate.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).indicatorColor,
                                BlendMode.srcIn),
                          ), () {
                        // show language dialog
                        showLanguageDialog();
                      },
                          value: Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Text(language.toLowerCase().tr,
                                style: Theme.of(context).textTheme.bodySmall),
                          ));
                    }),
                    subMenu(
                        "share_app_title".tr,
                        const Icon(
                          Icons.share,
                          // color: iconColor,
                          size: 24,
                        ), () {
                      if (Platform.isAndroid) {
                        Share.share(
                            'https://play.google.com/store/apps/details?id=space.tombstone.imagerotator');
                      } else if (Platform.isIOS) {
                        Share.share(
                            'https://apps.apple.com/us/app/ai-recipe-creator/id6708237488');
                      }
                    }),
                    subMenu(
                        "more_apps".tr,
                        const Icon(
                          Icons.apps,
                          // color: iconColor,
                          size: 24,
                        ), () async {
                      Get.toNamed(MoreAppsPage.routeName);
                    }, value: Container()),
                    InAppPurchasePage(),
                  ],
                ),
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

  // create sub menu
  Widget subMenu(String title, Widget icon, Function() onTap, {Widget? value}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium)),
            if (value != null)
              Row(
                children: [
                  value,
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  void showSelectionDialog() {
    GlobalController globalController = Get.find();
    Get.defaultDialog(
      title: "camera_resolution".tr,
      middleText: "camera_resolution_desc".tr,
      content: Column(
        children: [
          ListTile(
            title: Text("medium".tr),
            onTap: () {
              globalController.setResolution(resolution: "Medium");
              Get.back();
            },
          ),
          ListTile(
            title: Text("high".tr),
            onTap: () {
              globalController.setResolution(resolution: "High");
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void showLanguageDialog() {
    GlobalController globalController = Get.find();
    Get.defaultDialog(
      title: "select_language".tr,
      content: Column(
        children: [
          ListTile(
            title: Text("english".tr),
            onTap: () {
              // set english language
              globalController.changeLanguage(changeToLangeuage: "en");
              Get.back();
            },
          ),
          ListTile(
            title: Text("japanese".tr),
            onTap: () {
              // set japanese language
              globalController.changeLanguage(changeToLangeuage: "ja");
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void showFontSizeDialog(String title, int currentSize, Function(int) onSave) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            height: 200,
            child: ListView(
              children: List.generate(20, (index) {
                int size = 12 + (index * 2);
                return ListTile(
                  title: Text("$size"),
                  onTap: () {
                    onSave(size);
                    Navigator.pop(context);
                  },
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
