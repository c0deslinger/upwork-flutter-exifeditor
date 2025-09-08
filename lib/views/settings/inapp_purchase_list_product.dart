import 'package:drug_search/in_app_purchase/controller/in_app_purchase_controller.dart';
import 'package:drug_search/revenue_cat/views/page/upgrade_subs_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchasePage extends StatelessWidget {
  final InAppPurchaseController controller = Get.find();

  InAppPurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.queryProductError.value != null) {
        return Center(
          child: Text(controller.queryProductError.value!),
        );
      } else {
        return Column(
          children: [
            // _buildProductList(),
            buildUpgradeButton(),
            buildRestoreButton(onNothingToRestore: () {
              showNothingToRestoreError(context);
            })
          ],
        );
      }
    });
  }

  void showNothingToRestoreError(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("error".tr),
          content: Text("nothing_to_restore".tr),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildConnectionCheckTile() {
    return Obx(() {
      if (controller.loading.value) {
        return const Card(child: ListTile(title: Text('Trying to connect...')));
      }
      final Widget storeHeader = ListTile(
        leading: Icon(controller.isAvailable.value ? Icons.check : Icons.block,
            color: controller.isAvailable.value
                ? Colors.green
                : ThemeData.light().colorScheme.error),
        title: Text(
            'The store is ${controller.isAvailable.value ? 'available' : 'unavailable'}.'),
      );
      final List<Widget> children = <Widget>[storeHeader];

      if (!controller.isAvailable.value) {
        children.addAll(<Widget>[
          const Divider(),
          ListTile(
            title: Text('Not connected',
                style: TextStyle(color: ThemeData.light().colorScheme.error)),
            subtitle: const Text(
                'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
          ),
        ]);
      }
      return Card(child: Column(children: children));
    });
  }

  Widget _buildProductList() {
    return Obx(() {
      if (controller.loading.value) {
        return const CircularProgressIndicator();
      }
      if (!controller.isAvailable.value) {
        return const Card();
      }
      final List<Widget> productList = <Widget>[];
      debugPrint("notfoundids: ${controller.notFoundIds}");
      if (controller.notFoundIds.isNotEmpty) {
        productList.add(ListTile(
            title: Text('[${controller.notFoundIds.join(", ")}] not found',
                style: TextStyle(color: ThemeData.light().colorScheme.error)),
            subtitle: const Text(
                'This app needs special configuration to run. Please see example/README.md for instructions.')));
      }

      final Map<String, PurchaseDetails> purchases =
          Map<String, PurchaseDetails>.fromEntries(
              controller.purchases.map((PurchaseDetails purchase) {
        if (purchase.pendingCompletePurchase) {
          controller.inAppPurchase.completePurchase(purchase);
        }
        return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
      }));
      productList.addAll(controller.products.map(
        (ProductDetails productDetails) {
          final PurchaseDetails? previousPurchase =
              purchases[productDetails.id];

          debugPrint('previousPurchase: ${previousPurchase?.transactionDate}');

          // if (previousPurchase != null && Platform.isIOS) return Container();
          return subMenu(
              // productDetails.title,
              "tip".tr,
              icon: Image.asset("assets/images/icon_tip_jojo_star.png",
                  width: 24, height: 24), () {
            late PurchaseParam purchaseParam;

            // if (Platform.isAndroid) {
            //   final GooglePlayPurchaseDetails? oldSubscription =
            //       controller.getOldSubscription(productDetails, purchases);

            //   purchaseParam = GooglePlayPurchaseParam(
            //       productDetails: productDetails,
            //       changeSubscriptionParam: (oldSubscription != null)
            //           ? ChangeSubscriptionParam(
            //               oldPurchaseDetails: oldSubscription,
            //               // replacementMode:
            //               //     ReplacementMode.immediateWithTimeProration,
            //             )
            //           : null);
            // } else {
            purchaseParam = PurchaseParam(
              productDetails: productDetails,
            );
            // }

            // if (productDetails.id == controller.kConsumableId) {
            //   controller.inAppPurchase.buyConsumable(
            //       purchaseParam: purchaseParam,
            //       autoConsume: controller.kAutoConsume);
            // } else {
            controller.inAppPurchase
                .buyNonConsumable(purchaseParam: purchaseParam);
            // }
          });
        },
      ));

      return Column(children: productList);
    });
  }

  Widget buildConsumableBox() {
    return Obx(() {
      if (controller.loading.value) {
        return const Card(
            child: ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Fetching consumables...')));
      }
      if (!controller.isAvailable.value ||
          controller.notFoundIds.contains(controller.productId)) {
        return const Card();
      }
      const ListTile consumableHeader =
          ListTile(title: Text('Purchased consumables'));
      final List<Widget> tokens = controller.consumables.map((String id) {
        return GridTile(
          child: IconButton(
            icon: const Icon(
              Icons.stars,
              size: 42.0,
              color: Colors.orange,
            ),
            splashColor: Colors.yellowAccent,
            onPressed: () => controller.consume(id),
          ),
        );
      }).toList();
      return Card(
          child: Column(children: <Widget>[
        consumableHeader,
        const Divider(),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          padding: const EdgeInsets.all(16.0),
          children: tokens,
        )
      ]));
    });
  }

  Widget buildRestoreButton({required Function onNothingToRestore}) {
    return Obx(() {
      if (controller.loading.value) {
        return Container();
      }
      bool isHasPreviousPurchase = controller.purchases.isNotEmpty;

      return subMenu("restore_purchase".tr,
          icon: const Icon(Icons.attach_money_rounded, size: 24), () {
        controller.inAppPurchase.restorePurchases();
        if (!isHasPreviousPurchase) {
          onNothingToRestore();
        }
      });
    });
  }

  Widget buildUpgradeButton() {
    return subMenu("upgrade".tr, icon: const Icon(Icons.upgrade, size: 24), () {
      // Get.to(() => UpgradePage());
      Get.toNamed(UpgradeSubsPage.routeName);
      // Get.toNamed(UpgradePage.routeName);
    });
  }

// create sub menu
  Widget subMenu(String title, Function() onTap,
      {Widget? value, Widget? icon}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            icon ??
                const Icon(Icons.attach_money_rounded,
                    size: 24, color: Color.fromARGB(255, 74, 74, 74)),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
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
}
