import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/constant.dart';

class RevenucatController extends GetxController {
  bool entitlementIsActive = false;
  String appUserID = '';
  bool isLoading = false;
  bool isPremiumUser = false;
  Offerings? offerings;
  EntitlementInfo? entitlement;
  CustomerInfo? customerInfo;

  Future<void> initPlatformState() async {
    appUserID = await Purchases.appUserID;

    Purchases.addCustomerInfoUpdateListener((s) async {
      appUserID = await Purchases.appUserID;
      customerInfo = await Purchases.getCustomerInfo();
      debugPrint("REVENUECAT | $customerInfo");
      entitlement = customerInfo!.entitlements.all[entitlementID];
      entitlementIsActive = entitlement?.isActive ?? false;
      debugPrint("REVENUECAT | entitlementIsActive $entitlementIsActive");
      isPremiumUser = entitlement?.isActive ?? false;
      update();
      debugPrint("REVENUECAT | premium $isPremiumUser");
    });

    checkUserSubcription();
  }

  @override
  void onInit() {
    super.onInit();
    initPlatformState();
    // login(newAppUserID: newAppUserID)
  }

  Future<bool> checkUserSubcription() async {
    log("check user subscription");
//check user subscription
    isLoading = true;
    update();
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    isLoading = false;
    if (customerInfo.entitlements.all[entitlementID] != null &&
        customerInfo.entitlements.all[entitlementID]?.isActive == true) {
      isPremiumUser = true;
    }
    update();
    return isPremiumUser;
  }

  void checkOffering() async {
    isLoading = true;
    update();
    try {
      offerings = await Purchases.getOfferings();
      debugPrint("REVENUECAT | offerings $offerings");
    } on PlatformException catch (e) {
      Get.snackbar("Error Check Offering", e.message ?? "Unknown error");
      debugPrint(
          "REVENUECAT | offering error: ${e.message ?? "Unknown error"}");
    }
    isLoading = false;
    update();
  }

  void purchase(Package packageToPurchase) async {
    try {
      PurchaseResult purchaseResult =
          await Purchases.purchasePackage(packageToPurchase);
      customerInfo = purchaseResult.customerInfo;
      checkUserSubcription();
    } on PlatformException catch (e) {
      Get.snackbar("Error Purchase", e.message ?? "Unknown error");
      debugPrint("Error purchase: ${e.message ?? "-"}");
    }
  }

  /*
      How to login and identify your users with the Purchases SDK.
      Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids
    */
  void login(
      {Function(PlatformException)? onError,
      required String newAppUserID}) async {
    log("check login");
    isLoading = true;
    update();
    try {
      await Purchases.logIn(newAppUserID);
      appUserID = await Purchases.appUserID;
    } on PlatformException catch (e) {
      Get.snackbar("Error Login", e.message ?? "Unknown error");
      debugPrint("REVENUECAT | Error login: ${e.message ?? "Unknown error"}");
      if (onError != null) {
        onError(e);
      }
    }
    isLoading = false;
    update();
  }

  void logout({Function(PlatformException)? onError}) async {
    log("check logout");
    isLoading = true;
    update();
    try {
      await Purchases.logOut();
      appUserID = await Purchases.appUserID;
    } on PlatformException catch (e) {
      Get.snackbar("Error Logout", e.message ?? "Unknown error");
      debugPrint("REVENUECAT | Error logout: ${e.message ?? "Unknown error"}");
      if (onError != null) {
        onError(e);
      }
    }
    isLoading = false;
    update();
  }

  void restorePurchase({Function(PlatformException)? onError}) async {
    log("check restore purchase");
    isLoading = true;
    update();
    try {
      await Purchases.restorePurchases();
      appUserID = await Purchases.appUserID;
      debugPrint("REVENUECAT | Restore purchase with ID: $appUserID");

      Get.snackbar("Restore Purchase", "Purchase restored with id $appUserID");
    } on PlatformException catch (e) {
      Get.snackbar("Error Restore Purchase", e.message ?? "Unknown error");
      debugPrint(
          "REVENUECAT | Error restore purchase: ${e.message ?? "Unknown error"}");
      if (onError != null) {
        onError(e);
      }
    } catch (e) {
      Get.snackbar("Error Restore Purchase", e.toString());
      debugPrint("REVENUECAT | Error restore purchase: ${e.toString()}");
    }
    isLoading = false;
    update();
  }
}
