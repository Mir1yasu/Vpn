import 'dart:async';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class AppodealService {
  AppodealService._privateConstructor();

  static final AppodealService instance = AppodealService._privateConstructor();

  Future<void> initialize() async {
    Appodeal.setTesting(kDebugMode);
    Appodeal.setUseSafeArea(true);
    Appodeal.setLogLevel(
      kDebugMode ? Appodeal.LogLevelDebug : Appodeal.LogLevelNone,
    );
    Appodeal.setAutoCache(AppodealAdType.Interstitial, false);
    //Appodeal.setCustomFilter("levels_played", "levelsPlayed");

    Appodeal.setInterstitialCallbacks(
      onInterstitialLoaded: (_) => Appodeal.show(AppodealAdType.Interstitial),
      onInterstitialFailedToLoad: () {
        print('Appodeal Interstitial failed to load');

        AppMetrica.reportEvent('interFailToLoad');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('interFailToLoad');
      },
      onInterstitialShown: () {
        print('Appodeal Interstitial shown');
        AppMetrica.reportEvent('interShow');
        if (statisticOn) FirebaseAnalyticaService.reportEvent('interShow');
      },
      onInterstitialShowFailed: () {
        print('Appodeal Interstitial show failed');
        AppMetrica.reportEvent('interFailToShow');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('interFailToShow');
      },
      onInterstitialClosed: () {
        print('Appodeal Interstitial closed');
        AppMetrica.reportEvent('interClose');
        if (statisticOn) FirebaseAnalyticaService.reportEvent('interClose');
      },
      onInterstitialExpired: () {
        print('Appodeal Intersitial expired');
        AppMetrica.reportEvent('interExpired');
        if (statisticOn) FirebaseAnalyticaService.reportEvent('interExpired');
      },
      onInterstitialClicked: () => onInterClick(),
    );

    Appodeal.setBannerCallbacks(onBannerClicked: () => onBannerClick());

    await Appodeal.initialize(
      appKey: '558cf165fdd0c5888b1d8f7b14abe09b377d893910f80d9f',
      adTypes: <AppodealAdType>[
        AppodealAdType.Banner,
        AppodealAdType.Interstitial,
      ],
      onInitializationFinished: (errors) {
        errors?.forEach((error) => print(error.desctiption));
        print("onInitializationFinished: errors - ${errors?.length ?? 0}");
      },
    );

    Appodeal.updateGDPRUserConsent(GDPRUserConsent.Personalized);
    Appodeal.updateCCPAUserConsent(CCPAUserConsent.OptIn);
  }

  Future<void> initInterstitial() async {
    Appodeal.cache(Appodeal.INTERSTITIAL);
  }

  Future<void> onInterClick() async {
    await AppMetrica.reportEvent('interClick');
    if (statisticOn) FirebaseAnalyticaService.reportEvent('interClick');
  }

  Future<void> onBannerClick() async {
    await AppMetrica.reportEvent('bannerClick');
    if (statisticOn) FirebaseAnalyticaService.reportEvent('bannerClick');
  }
}

class BannerWidget extends StatelessWidget {
  const BannerWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AppodealBanner(adSize: AppodealBannerSize.BANNER),
      width: MediaQuery.of(context).size.width,
      height: 72,
    );
  }
}
