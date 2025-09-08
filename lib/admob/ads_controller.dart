import 'dart:io';

import 'package:drug_search/controllers/global_controller.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppOpenAdsController extends GetxController {
  final _appOpenUnitIdIos = 'ca-app-pub-4385164164114125/4826515645';
  final _appOpenUnitIdAndroid = 'ca-app-pub-4385164164114125/1772976891';
  final _appOpenUnitIdAndroidTest = 'ca-app-pub-3940256099942544/9257395921';

  AppOpenAd? _appOpenAd;

  int _showCounterAppOpen = 1;
  int _showCounterInterstitial = 0;
  final int _showAppOpenOnCount = 7;

  bool _isAppOpenAlreadyShowed = false;
  late SharedPreferences sharedPreferences;

  String _getOpenAdUnitId(bool isDebug) {
    String adsId = "";
    if (Platform.isAndroid) {
      adsId = isDebug ? _appOpenUnitIdAndroidTest : _appOpenUnitIdAndroid;
    } else {
      adsId = isDebug ? _appOpenUnitIdAndroidTest : _appOpenUnitIdIos;
    }
    debugPrint("open ad id: $adsId");
    return adsId;
  }

  void loadAppOpen({bool isFirst = true}) {
    GlobalController globalController = Get.find();
    try {
      AppOpenAd.load(
        adUnitId: _getOpenAdUnitId(kDebugMode),
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint("current app open $_showCounterAppOpen");
            if (_appOpenAd == null &&
                (_showCounterAppOpen == 1 ||
                    (_showCounterAppOpen % (_showAppOpenOnCount) == 0))) {
              debugPrint('current app $ad loaded.');
              _appOpenAd = ad;
              debugPrint("counter: $_showCounterAppOpen");
              if (_showCounterAppOpen != 1 &&
                  !globalController.isFirstTimeOpen) {
                debugPrint("show app open ad disitu");
                _appOpenAd?.show();
              }
              _appOpenAd = null;
            }
            _showCounterAppOpen++;
            saveCounter();
          },
          onAdFailedToLoad: (error) {
            debugPrint("app open not loaded");
          },
        ),
      );
    } catch (e) {
      debugPrint("error open ad: $e");
    }
  }

  void loadOpenAd({bool isFirst = false}) async {
    loadAppOpen(isFirst: isFirst);
  }

  void showAppOpenAd() async {
    debugPrint("show app open ad disini");
    if (_appOpenAd == null) {
      debugPrint('Tried to show ad before available.');
      loadOpenAd();
      return;
    }
    if (_isAppOpenAlreadyShowed) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isAppOpenAlreadyShowed = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isAppOpenAlreadyShowed = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isAppOpenAlreadyShowed = false;
        ad.dispose();
        _appOpenAd = null;
        loadOpenAd();
      },
    );
    _appOpenAd!.show();
  }

  @override
  void onInit() async {
    sharedPreferences = await SharedPreferences.getInstance();
    getLastCounter();
    loadOpenAd(isFirst: true);
    super.onInit();
  }

  void getLastCounter() {
    _showCounterAppOpen = sharedPreferences.getInt("showCounterAppOpen") ?? 0;
    _showCounterInterstitial =
        sharedPreferences.getInt("showCounterInterstitial") ?? 0;
  }

  void saveCounter() {
    sharedPreferences.setInt("showCounterAppOpen", _showCounterAppOpen);
    sharedPreferences.setInt(
        "showCounterInterstitial", _showCounterInterstitial);
  }
}
