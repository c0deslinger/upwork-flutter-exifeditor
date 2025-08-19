import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardAdController extends GetxController {
  RewardedAd? rewardedAd;

  final _rewardAdUnitIdIos = 'ca-app-pub-4385164164114125/7896710154';
  // final _rewardAdUnitIdIos = 'ca-app-pub-3940256099942544/1712485313';
  final _rewardAdUnitIdIosTest = 'ca-app-pub-3940256099942544/1712485313';

  final _rewardAdUnitIdAndroid = 'ca-app-pub-4385164164114125/9621055057';
  final _rewardAdUnitIdAndroidTest = 'ca-app-pub-3940256099942544/1712485313';

  String _getOpenAdUnitId(bool isDebug) {
    String adsId = "";
    if (Platform.isAndroid) {
      adsId = isDebug ? _rewardAdUnitIdAndroidTest : _rewardAdUnitIdAndroid;
    } else {
      adsId = isDebug ? _rewardAdUnitIdIosTest : _rewardAdUnitIdIos;
    }
    debugPrint("open ad id: $adsId");
    return adsId;
  }

  @override
  void onInit() {
    loadAd();
    super.onInit();
  }

  Future<void> loadAd({Function? onAdLoaded, Function? onError}) async {
    RewardedAd.load(
        adUnitId: _getOpenAdUnitId(false),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            rewardedAd = ad;
            rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                rewardedAd?.dispose();
                if (onError != null) {
                  onError();
                }
              },
              onAdDismissedFullScreenContent: (ad) {
                // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              },
            );
            if (onAdLoaded != null) {
              onAdLoaded();
            }
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            if (onError != null) {
              onError();
            }
            debugPrint('RewardedAd failed to load bos: $error');
          },
        ));
  }

  Future<void> showAd(
      {required Function(AdWithoutView? ad, RewardItem? rewardItem)
          onUserEarnedReward,
      required Function onError}) async {
    try {
      debugPrint("start show reward ad");
      loadAd(onAdLoaded: () {
        rewardedAd?.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
            debugPrint('User earned reward: $rewardItem');
            onUserEarnedReward(ad, rewardItem);
          },
        );
      }, onError: () {
        onError();
      });
    } catch (e) {
      debugPrint("show ad error here: $e");
      onError();
      // onUserEarnedReward(null, rewardItem);
    }
  }
}
