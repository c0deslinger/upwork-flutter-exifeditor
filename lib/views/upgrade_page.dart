// import 'package:drug_search/revenue_cat/controller/revenuecat_controller.dart';
// import 'package:drug_search/revenue_cat/views/page/upgrade_subs_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

// class UpgradePage extends StatefulWidget {
//   static const routeName = "/upgrade";
//   @override
//   _UpgradePageState createState() => _UpgradePageState();
// }

// class _UpgradePageState extends State<UpgradePage> {
//   RevenucatController revenucatController = Get.find();
//   Package? selectedProduct;
//   String selectedPlan = "monthly"; // Default selected plan

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 500), () {
//       revenucatController.checkOffering();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'premium_plan'.tr,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: GetBuilder<RevenucatController>(builder: (iapController) {
//         List<Package>? myProductList =
//             iapController.offerings?.current?.availablePackages;

//         if ((myProductList?.isNotEmpty ?? false) &&
//             myProductList![0].packageType == PackageType.annual) {
//           debugPrint("reverse ");
//           myProductList = myProductList.reversed.toList();
//         }

//         bool isHasOffering = iapController.offerings?.current != null;
//         bool isPremiumUser = iapController.isPremiumUser;

//         debugPrint("valss ${myProductList![0].packageType.toString()}");

//         // debugPrint("myProductList " + myProductList!.length.toString());
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.block), // Icon for "No Ads"
//                   SizedBox(width: 8),
//                   Text(
//                     "no_ads".tr,
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 200),
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       if (isHasOffering &&
//                           !isPremiumUser &&
//                           myProductList != null)
//                         Column(
//                           children: [
//                             for (var product in myProductList)
//                               subscriptionOption(product)
//                           ],
//                         ),
//                       const SizedBox(height: 24),
//                       ElevatedButton(
//                         onPressed: () {
//                           if (selectedProduct != null) {
//                             iapController.purchase(selectedProduct!);
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           backgroundColor:
//                               Theme.of(context).appBarTheme.backgroundColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             "continue".tr,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   String getSubscriptionTitle(String identifier) {
//     identifier = identifier.split(':').first;
//     return '$identifier'.tr;
//   }

//   Widget subscriptionOption(Package package) {
//     String identifier = package.storeProduct.identifier;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedPlan = identifier;
//           selectedProduct = package;
//         });
//       },
//       child: Stack(
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 10),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: Theme.of(context).appBarTheme.backgroundColor!,
//               ),
//               borderRadius: BorderRadius.circular(10),
//               color: selectedPlan == identifier
//                   ? Theme.of(context)
//                       .appBarTheme
//                       .backgroundColor!
//                       .withValues(alpha: 0.3)
//                   : Colors.transparent,
//             ),
//             child: Row(
//               children: [
//                 Text(
//                   getSubscriptionTitle(identifier),
//                   style: GoogleFonts.mPlusRounded1c(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Spacer(),
//               ],
//             ),
//           ),
//           if (identifier.contains("12_1y") && selectedPlan == identifier)
//             Positioned(
//               right: 20,
//               top: 0,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).appBarTheme.backgroundColor,
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: const Text(
//                   "50% Off",
//                   style: TextStyle(fontSize: 12, color: Colors.black),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
