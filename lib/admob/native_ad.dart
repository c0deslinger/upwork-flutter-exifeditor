import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdAdmob extends StatefulWidget {
  const NativeAdAdmob({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NativeAdAdmobState();
  }
}

class _NativeAdAdmobState extends State<NativeAdAdmob> {
  late NativeAd _nativeAd;
  bool _nativeAdReady = false;

  final String _adUnitIdTest = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-4385164164114125/3217333773'
      : 'ca-app-pub-4385164164114125/9459895221';

  String getAdunitId() {
    if (kDebugMode) {
      return _adUnitIdTest;
    } else {
      return _adUnitId;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadAd();
    });
  }

  /// Loads and shows a banner ad.
  ///
  /// Dimensions of the ad are determined by the width of the screen.
  void _loadAd() async {
    _nativeAd = NativeAd(
        adUnitId: getAdunitId(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('$NativeAd loaded.');
            setState(() {
              _nativeAdReady = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            debugPrint('$NativeAd failed to load: $error');
            ad.dispose();
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium,
          cornerRadius: 10.0,
        ))
      ..load();
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("dispose native");
    _nativeAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _nativeAdReady
        ? ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 320, // minimum recommended width
              minHeight: 320, // minimum recommended height
              maxWidth: 400,
              maxHeight: 400,
            ),
            child: AdWidget(ad: _nativeAd))
        : Container();
  }
}
