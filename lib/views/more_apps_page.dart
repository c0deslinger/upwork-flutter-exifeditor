import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreAppsPage extends StatelessWidget {
  static const routeName = "/moreApps";

  final List<AppInfo> apps = [
    AppInfo(
      titleKey: "app_prename_title",
      descriptionKey: "app_prename_description",
      imageUrl: 'assets/images/app_prename.png',
      iosLink:
          'https://apps.apple.com/us/app/prename-photo-rename-photo/id6449829851',
      androidLink:
          'https://play.google.com/store/apps/details?id=space.tombstone.prenamephoto',
    ),
    AppInfo(
      titleKey: "app_multiple_url_title",
      descriptionKey: "app_multiple_url_desc",
      imageUrl: 'assets/images/app_multipleurl.png',
      iosLink:
          'https://apps.apple.com/us/app/multiple-urls-opener-quick/id6476015302',
      androidLink:
          'https://play.google.com/store/apps/details?id=com.koji.multitabbrowser',
    ),
    AppInfo(
      titleKey: "app_tunetrack_title",
      descriptionKey: "app_tunetrack_description",
      imageUrl: 'assets/images/app_tunetrack.png',
      iosLink:
          'https://apps.apple.com/us/app/tunetracks-play-for-youtube/id6470999776',
      androidLink:
          'https://play.google.com/store/apps/details?id=space.tombstone.tunetracks',
    ),
    AppInfo(
      titleKey: "app_blindbox_title",
      descriptionKey: "app_blindbox_desc",
      imageUrl: 'assets/images/app_blindbox.png',
      iosLink:
          'https://apps.apple.com/us/app/blindbox-photo-word-masking/id6740090900',
      androidLink:
          'https://play.google.com/store/apps/details?id=space.tombstone.blindbox',
    ),

    AppInfo(
      titleKey: "app_cheapest_store_title",
      descriptionKey: "app_cheapest_store_desc",
      imageUrl: 'assets/images/app_cheapest_store.png',
      iosLink:
          'https://apps.apple.com/us/app/cheapest-store-x-shopping-list/id6741428184',
      androidLink:
          'https://play.google.com/store/apps/details?id=space.tombstone.cheapeststorememo',
    ),
    // AppInfo(
    //   titleKey: "app_airecipe_title",
    //   descriptionKey: "app_airecipe_description",
    //   imageUrl: 'assets/images/app_airecipe.png',
    //   iosLink: 'https://apps.apple.com/us/app/ai-recipe-creator/id6708237488',
    //   androidLink:
    //       'https://play.google.com/store/apps/details?id=space.tombstone.airecipecreator',
    // ),
    AppInfo(
      titleKey: "more_apps",
      imageUrl: 'assets/images/manager.png',
      iosLink: 'https://apps.apple.com/us/developer/koji-watanabe/id1332653587',
      androidLink: 'https://play.google.com/store/apps/developer?id=tombstone',
    ),
  ];

  MoreAppsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("more_apps".tr,
            style: GoogleFonts.mPlusRounded1c(
                fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];

          return ListTile(
              leading: Image.asset(app.imageUrl, width: 50, height: 50),
              title: Text(app.titleKey.tr,
                  style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14)), // Mengambil title dari localization
              subtitle: app.descriptionKey == null
                  ? null
                  : Text(app.descriptionKey!.tr,
                      style: GoogleFonts.notoSans(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                String url;

                if (index == apps.length - 1) {
                  // Jika More Apps, cek language
                  if (Platform.isAndroid) {
                    url =
                        'https://play.google.com/store/apps/developer?id=tombstone&hl=${Get.locale?.languageCode ?? 'en'}';
                  } else if (Platform.isIOS) {
                    url =
                        'https://apps.apple.com/${Get.locale?.languageCode == 'ja' ? 'jp' : 'us'}/developer/koji-watanabe/id1332653587';
                  } else {
                    throw Exception('Unsupported platform');
                  }
                } else {
                  // Gunakan link berdasarkan platform
                  if (Platform.isAndroid) {
                    url = app.androidLink;
                  } else if (Platform.isIOS) {
                    url = app.iosLink;
                  } else {
                    throw Exception('Unsupported platform');
                  }
                }

                if (!await launchUrl(Uri.parse(url))) {
                  throw Exception('Could not launch $url');
                }
              });
        },
      ),
    );
  }
}

class AppInfo {
  final String titleKey;
  final String? descriptionKey;
  final String imageUrl;
  final String iosLink;
  final String androidLink;

  AppInfo({
    required this.titleKey,
    this.descriptionKey,
    required this.imageUrl,
    required this.iosLink,
    required this.androidLink,
  });
}
