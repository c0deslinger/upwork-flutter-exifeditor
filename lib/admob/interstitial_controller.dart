import 'dart:io';

import 'package:drug_search/revenue_cat/controller/revenuecat_controller.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterstitialController extends GetxController {
  final _interstitialUnitIdIos = 'ca-app-pub-4385164164114125/8322907521';
  final _interstitialUnitIdIosTest = 'ca-app-pub-3940256099942544/4411468910';

  final _interstitialUnitIdAndroid = 'ca-app-pub-4385164164114125/3981990227';
  final _interstitialUnitIdAndroidTest =
      'ca-app-pub-3940256099942544/1033173712';

  InterstitialAd? _interstitialAd;
  // Ubah dari direct initialization ke late declaration
  late RevenucatController revenucatController;

  // int _showCounterAppOpen = 1;
  int _showCounterInterstitial = 0;
  // final int _showAppOpenOnCount = 7;
  final int _showInterstitialOnCount = 0;

  final bool _isAppOpenAlreadyShowed = false;
  late SharedPreferences sharedPreferences;

  String getInterstitialUnitId(bool isDebug) {
    String adsId = "";
    if (Platform.isAndroid) {
      adsId =
          isDebug ? _interstitialUnitIdAndroidTest : _interstitialUnitIdAndroid;
    } else {
      adsId = isDebug ? _interstitialUnitIdIosTest : _interstitialUnitIdIos;
    }
    debugPrint("interstitial id: $adsId");
    return adsId;
  }

  Future<void> loadInterstitial() async {
    if (await revenucatController.checkUserSubcription()) {
      debugPrint("user is subscribed, skip load banner");
      return;
    }
    try {
      InterstitialAd.load(
          adUnitId: getInterstitialUnitId(kDebugMode),
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            // Called when an ad is successfully received.
            onAdLoaded: (ad) {
              debugPrint('$ad loaded.');
              // Keep a reference to the ad so you can show it later.
              _interstitialAd = ad;
              update();
              ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  debugPrint('$ad onAdDismissedFullScreenContent.');
                  ad.dispose();
                  _interstitialAd = null;
                  loadInterstitial();
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
                  ad.dispose();
                  _interstitialAd = null;
                  loadInterstitial();
                },
                onAdShowedFullScreenContent: (ad) {
                  debugPrint('$ad onAdShowedFullScreenContent');
                },
              );
            },
            // Called when an ad request failed.
            onAdFailedToLoad: (LoadAdError error) {
              debugPrint('InterstitialAd failed to load: $error');
            },
          ));
    } catch (e) {
      debugPrint("error load interstitial $e");
    }
  }

  Future<void> showInterstitialAds(Function onAdLoaded) async {
    if (revenucatController.isPremiumUser) {
      onAdLoaded();
      return;
    }
    if (_interstitialAd == null) {
      debugPrint('Tried to show ad before available.');
      loadInterstitial();
      onAdLoaded();
      return;
    }
    if (_showCounterInterstitial < _showInterstitialOnCount) {
      debugPrint("counter interstitial: $_showCounterInterstitial");
      _showCounterInterstitial++;
      saveCounter();
      return;
    }
    _showCounterInterstitial = 1;
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) => debugPrint('ad showed $ad'),

        //when ad went closes
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitial();
          onAdLoaded();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          debugPrint('failed to show the ad $ad');
          onAdLoaded();
        });
    await _interstitialAd?.show();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize controller di sini untuk menghindari circular dependency
    revenucatController = Get.find();
  }

  void getLastCounter() {
    // _showCounterAppOpen = sharedPreferences.getInt("showCounterAppOpen") ?? 0;
    _showCounterInterstitial =
        sharedPreferences.getInt("showCounterInterstitial") ?? 0;
  }

  void saveCounter() {
    // sharedPreferences.setInt("showCounterAppOpen", _showCounterAppOpen);
    sharedPreferences.setInt(
        "showCounterInterstitial", _showCounterInterstitial);
  }
}
