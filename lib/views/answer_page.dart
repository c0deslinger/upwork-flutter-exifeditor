import 'package:drug_search/controllers/global_controller.dart';
import 'package:drug_search/admob/banner_ad.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'settings/setting_page.dart';

class AnswerPage extends StatefulWidget {
  static const routeName = "/answer";
  final String description;

  const AnswerPage({super.key, required this.description});

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  GlobalController globalController = Get.find();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      globalController.decreaseCurrentTicket();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('answer'.tr,
            style: GoogleFonts.mPlusRounded1c(
                fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              child: const Icon(
                CupertinoIcons.settings,
              ),
              onTap: () {
                Get.toNamed(SettingPage.routeName);
              },
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Markdown(data: widget.description),
          )),
          Container(
            color: const Color.fromARGB(255, 239, 204, 98),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'disclaimer'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.mPlusRounded1c(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
          const BannerAdmob(
            adunitAndroid: 'ca-app-pub-4385164164114125/5843497114',
            adunitIos: 'ca-app-pub-4385164164114125/9635989197',
          ),
        ],
      ),
    );
  }
}
