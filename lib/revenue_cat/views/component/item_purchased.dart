import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/revenuecat_controller.dart';

class ItemPurchased extends StatelessWidget {
  const ItemPurchased({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RevenucatController>(builder: (revenueCat) {
      return ListTile(
        title: Text(revenueCat.entitlement?.identifier ?? "-"),
        subtitle: Text(
            "${"expired_at".tr} ${revenueCat.entitlement?.expirationDate}"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue)),
          child: Text("subscribed".tr),
        ),
      );
    });
  }
}
