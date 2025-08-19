import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../controller/revenuecat_controller.dart';
import '../../model/styles.dart';

class Paywall extends StatefulWidget {
  final Offering offering;

  const Paywall({super.key, required this.offering});

  @override
  PaywallState createState() => PaywallState();
}

class PaywallState extends State<Paywall> {
  RevenucatController revenucatController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Wrap(
          children: <Widget>[
            Container(
              height: 70.0,
              width: double.infinity,
              decoration: const BoxDecoration(
                  // color: kColorBar,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25.0))),
              child: Center(
                  child: Text('✨ ${"fx_premium".tr}', style: kTitleTextStyle)),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: widget.offering.availablePackages.length,
                itemBuilder: (BuildContext context, int index) {
                  var myProductList = widget.offering.availablePackages;
                  return Card(
                    color: const Color.fromARGB(255, 92, 92, 92),
                    child: ListTile(
                        minVerticalPadding: 14,
                        onTap: () async {
                          try {
                            revenucatController.purchase(myProductList[index]);
                          } catch (e) {
                            debugPrint(e.toString());
                          }

                          setState(() {});
                          Navigator.pop(context);
                        },
                        title: Text(
                          myProductList[index].storeProduct.title,
                          style: kTitleTextStyle.copyWith(
                              color: Colors.white, fontSize: 12),
                        ),
                        subtitle: Text(
                          myProductList[index].storeProduct.description,
                          style: kDescriptionTextStyle.copyWith(
                              color: Colors.white,
                              fontSize: kFontSizeSuperSmall),
                        ),
                        trailing: Text(
                            myProductList[index].storeProduct.priceString,
                            style:
                                kTitleTextStyle.copyWith(color: Colors.white))),
                  );
                },
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 16, bottom: 32, left: 16.0, right: 16.0),
              child: SizedBox(
                width: double.infinity,
                // child: Text(
                //   footerText,
                //   style: kDescriptionTextStyle,
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("features".tr, style: kTitleTextStyle),
                    const SizedBox(height: 16),
                    buildBulletText('premium_ad_removal'.tr),
                    const SizedBox(height: 8),
                    buildBulletText(
                        'premium_input_immediately_after_startup'.tr),
                    const SizedBox(height: 8),
                    buildBulletText('premium_memorize_allowed_loss_amount'.tr),
                    const SizedBox(height: 8),
                    buildBulletText('premium_memorize_currency_pair'.tr),
                    const SizedBox(height: 8),
                    buildBulletText('premium_fix_1_lot'.tr),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildBulletText(String text) {
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Icon(
      Icons.fiber_manual_record,
      size: 10,
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(
        text,
      ),
    )
  ]);
}
