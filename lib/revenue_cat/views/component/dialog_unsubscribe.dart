import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/styles.dart';
import '../page/paywall_modal.dart';

class DialogUnsubscribe extends StatelessWidget {
  const DialogUnsubscribe({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("how_to_unsubscribe_title".tr, style: kTitleTextStyle),
                  const SizedBox(height: 16),
                  buildBulletText('how_to_unsubscribe_1'.trParams({
                    "store": Platform.isIOS
                        ? "Apple Store"
                        : "Play Store (Google Account)"
                  })),
                  const SizedBox(height: 8),
                  buildBulletText('how_to_unsubscribe_2'.tr),
                  const SizedBox(height: 8),
                  buildBulletText('how_to_unsubscribe_3'.tr),
                  const SizedBox(height: 8),
                  buildBulletText('how_to_unsubscribe_4'.tr),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
