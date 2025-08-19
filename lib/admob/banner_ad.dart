import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdmob extends StatefulWidget {
  final String adunitAndroid;
  final String adunitIos;
  const BannerAdmob(
      {super.key, required this.adunitAndroid, required this.adunitIos});

  @override
  State<StatefulWidget> createState() {
    return _BannerAdmobState();
  }
}

class _BannerAdmobState extends State<BannerAdmob> {
  BannerAd? _bannerAd;
  bool _bannerReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadAd();
    });
  }

  String getAdunit() {
    if (kDebugMode) {
      String adunit = "ca-app-pub-3940256099942544/9214589741";
      debugPrint("adunit $adunit");
      return adunit;
    } else {
      String adunit =
          Platform.isAndroid ? widget.adunitAndroid : widget.adunitIos;
      debugPrint("adunit $adunit");
      return adunit;
    }
  }

  /// Loads and shows a banner ad.
  ///
  /// Dimensions of the ad are determined by the width of the screen.
  void _loadAd() async {
    if (_bannerAd != null) {
      debugPrint("Disposing existing banner ad");
      _bannerAd!.dispose();
    }

    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.sizeOf(context).width.truncate());

    if (size == null) {
      debugPrint("Unable to get width of anchored banner.");
      return;
    }
    debugPrint("Load banner ad");
    _bannerAd = BannerAd(
      adUnitId: getAdunit(),
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _bannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          setState(() {
            _bannerReady = false;
          });
          debugPrint("dispose banner cause fail: $err");
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    debugPrint("dispose banner");
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_bannerAd != null && _bannerReady)
        ? Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          )
        : Container();
  }
}
