import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/revenuecat_controller.dart';
import '../../model/styles.dart';
import '../component/dialog_unsubscribe.dart';
import '../component/native_dialog.dart';
import 'paywall_modal.dart';

class UpgradeSubsPage extends StatefulWidget {
  static const routeName = "/upgrade_subscription";
  const UpgradeSubsPage({super.key});

  @override
  State<UpgradeSubsPage> createState() => _UpgradeSubsPageState();
}

class _UpgradeSubsPageState extends State<UpgradeSubsPage> {
  RevenucatController revenucatController = Get.find();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      revenucatController.checkOffering();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("premium_plan".tr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        actions: [
          GetBuilder<RevenucatController>(builder: (iapController) {
            if (iapController.offerings?.current != null &&
                iapController.isPremiumUser) {
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                margin: const EdgeInsets.all(16),
                child: Text("enabled".tr),
              );
            } else {
              return Container();
            }
          })
        ],
      ),
      body: GetBuilder<RevenucatController>(builder: (iapController) {
        List<Package>? myProductList =
            iapController.offerings?.current?.availablePackages;

        if ((myProductList?.isNotEmpty ?? false) &&
            myProductList![0].packageType == PackageType.annual) {
          myProductList = myProductList.reversed.toList();
        }

        bool isHasOffering = iapController.offerings?.current != null;
        bool isPremiumUser = iapController.isPremiumUser;

        debugPrint("REVENUECAT | have offering: $isHasOffering");
        debugPrint("REVENUECAT | is premium user: $isPremiumUser");
        debugPrint("REVENUECAT | available product: ${myProductList?.length}");
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isHasOffering && !isPremiumUser && myProductList != null)
                Column(
                  children: [
                    for (var product in myProductList)
                      subscriptionOption(product, context, () {
                        iapController.purchase(product);
                      }),
                  ],
                ),
              listPremiumFeature(),
              const Divider(height: 1),
              if (iapController.appUserID.contains("RCAnonymousID:"))
                listRowMenu(
                  title: "restore_previous_purchase".tr,
                  isLoading: iapController.isLoading,
                  onClick: () async {
                    iapController.restorePurchase(
                      onError: (e) async {
                        debugPrint("error: ${e.message}");
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                ShowDialogToDismiss(
                                    title: "Error",
                                    content: e.message ?? "Unknown error",
                                    buttonText: 'OK'));
                      },
                    );
                  },
                ),
              listRowMenu(
                title: "how_to_unsubscribe".tr,
                onClick: () async {
                  await showModalBottomSheet(
                    useRootNavigator: true,
                    isDismissible: true,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setModalState) {
                        return const DialogUnsubscribe();
                      });
                    },
                  );
                },
              ),
              listNote(),
              const Divider(height: 1),
              listRowMenu(
                title: "terms_of_use".tr,
                onClick: () async {
                  launchUrl(Uri.parse('https://tombstone.space/termsofuse/'));
                },
              ),
              listRowMenu(
                title: "privacy_policy".tr,
                onClick: () async {
                  launchUrl(
                      Uri.parse('https://tombstone.space/privacypolicy/'));
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

Widget listPremiumFeature() {
  return Container(
    margin: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("features".tr, style: kTitleTextStyle),
        const SizedBox(height: 16),
        buildBulletText('premium_ad_removal'.tr),
      ],
    ),
  );
}

Widget listNote() {
  return Container(
    margin: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("note".tr, style: kTitleTextStyle),
        const SizedBox(height: 16),
        buildBulletText('note_1'.tr),
        const SizedBox(height: 8),
        buildBulletText('note_2'.trParams({
          "store":
              Platform.isIOS ? "Apple Store" : "Play Store (Google Account)"
        })),
        const SizedBox(height: 8),
        buildBulletText('note_3'.tr),
        const SizedBox(height: 8),
        buildBulletText('note_4'.trParams({
          "store":
              Platform.isIOS ? "Apple Store" : "Play Store (Google Account)"
        })),
      ],
    ),
  );
}

Widget listRowMenu(
    {required Function() onClick,
    required String title,
    Widget? icon,
    bool? isLoading}) {
  String rowTitle = title;
  String? rowSubtitle;
  if (title.contains("-")) {
    List<String> rowSplit = title.split("-");
    rowTitle = rowSplit[0];
    rowSubtitle = rowSplit[1];
  }
  return Column(
    children: [
      InkWell(
        onTap: () {
          if (!(isLoading ?? false)) {
            onClick();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              if (icon != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: icon,
                ),
              Expanded(child: Text(rowTitle)),
              const SizedBox(width: 8),
              if (isLoading ?? false)
                const SizedBox(
                    height: 10, width: 10, child: CircularProgressIndicator()),
              const SizedBox(width: 8),
              if (rowSubtitle != null)
                Text(rowSubtitle,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
      const Divider(height: 1),
    ],
  );
}

Widget subscriptionOption(
    Package package, BuildContext context, Function onClick) {
  String identifier = package.storeProduct.identifier;
  String title = identifier.replaceAll(":premiumbase", "").tr;
  String rowTitle = title;
  String? rowSubtitle;
  if (title.contains("-")) {
    List<String> rowSplit = title.split("-");
    rowTitle = rowSplit[0];
    rowSubtitle = rowSplit[1];
  }
  return GestureDetector(
    onTap: () {
      onClick();
    },
    child: Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
          padding: EdgeInsets.only(
              top: identifier.contains("12_1y") ? 20 : 12,
              bottom: 12,
              left: 16,
              right: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).appBarTheme.backgroundColor!,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(
                rowTitle,
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (rowSubtitle != null)
                Text(
                  rowSubtitle,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        if (identifier.contains("12_1y"))
          Positioned(
            left: 20,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "50_off".tr,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ),
      ],
    ),
  );
}
