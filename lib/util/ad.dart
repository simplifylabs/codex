import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Ad {
  static InterstitialAd? loaded;
  static DateTime last = DateTime.now();
  static int timeout = 60;
  static bool isFirstLaunch = false;

  static get adUnitId {
    if (kReleaseMode) return "ca-app-pub-4630812895372038/9358897923";
    return Random().nextBool()
        ? "ca-app-pub-3940256099942544/8691691433"
        : "ca-app-pub-3940256099942544/1033173712";
  }

  static get isReady {
    bool ready =
        DateTime.now().difference(last).inSeconds > timeout && isLoaded;
    if (!isLoaded) load();
    return ready;
  }

  static get isLoaded {
    return loaded != null;
  }

  static load() {
    // InterstitialAd.load(
    //     adUnitId: Ad.adUnitId,
    //     request: const AdRequest(),
    //     adLoadCallback: InterstitialAdLoadCallback(
    //       onAdLoaded: (InterstitialAd ad) {
    //         loaded = ad;
    //       },
    //       onAdFailedToLoad: (LoadAdError error) {
    //         if (kDebugMode) {
    //           print('InterstitialAd failed to load: $error');
    //         }
    //       },
    //     ));
  }

  static show() async {
    if (!isReady) return;

    await loaded?.show();
    last = DateTime.now();

    loaded = null;
    load();
  }

  static init() {
    last =
        isFirstLaunch ? DateTime.now() : DateTime.fromMicrosecondsSinceEpoch(0);
    load();
  }
}
