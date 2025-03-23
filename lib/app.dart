import 'dart:convert';
import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/pages/Home/Onboarding.dart';
import 'package:mandarinvpn/pages/HomePage.dart';
import 'package:mandarinvpn/pages/Splashscreen.dart';
import 'package:mandarinvpn/pages/SubscriptionPage.dart';
import 'package:mandarinvpn/pages/TutorialPage.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:mandarinvpn/services/Geolocation.dart';

class MandarinVPN extends StatefulWidget {
  @override
  State<MandarinVPN> createState() => _MandarinVPNState();
}

class _MandarinVPNState extends State<MandarinVPN> {
  _getCountryCodesFromRemoteConfig() async {
        final remoteConfig = FirebaseRemoteConfig.instance;
        final codeCountriesKey = 'code_countries_disabled_analytics';
        remoteConfig.setDefaults({codeCountriesKey: jsonEncode(["ru", "uz", "ir"])});
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(milliseconds: 500),
        minimumFetchInterval: const Duration(hours: 1),
    ));


    await remoteConfig.fetchAndActivate();
    String jsonCountryCodes = remoteConfig.getString(codeCountriesKey);
    List<String> countryCodes = jsonCountryCodes.isNotEmpty ? List<String>.from(jsonDecode(jsonCountryCodes)) : [];
    return countryCodes;
  }

  _getLocalesFromRemoteConfig() async {
        final remoteConfig = FirebaseRemoteConfig.instance;
        final localesKey = 'locales_disabled_analytics';
        remoteConfig.setDefaults({localesKey: jsonEncode(["fa_IR"])});
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(milliseconds: 500),
        minimumFetchInterval: const Duration(hours: 1),
    ));


    await remoteConfig.fetchAndActivate();
    String jsonLocales = remoteConfig.getString(localesKey);
    List<String> locales = jsonLocales.isNotEmpty ? List<String>.from(jsonDecode(jsonLocales)) : [];
    return locales;
  }

  getRegion() async {
    GeolocationData geolocationData = await GeolocationAPI.getData();
    final String codeCountry = (geolocationData.countryCode ?? '').toLowerCase();
    // final data = await Referrer().getReferrer();
    // if ('ru_RU'.contains(codeCountry) && data.contains('gclid=')) {

    String params = "{\"data\":\"${geolocationData.toJson()}\"}";
    AppMetrica.reportEventWithJson('ip_json', params);

    List<String> countryCodes = await _getCountryCodesFromRemoteConfig();
    List<String> locales = await _getLocalesFromRemoteConfig();

    final deviceLocale = Platform.localeName;

    if (geolocationData.proxy ||
        geolocationData.hosting ||
        countryCodes.any((element) => element.contains(codeCountry)) ||
        locales.any((element) => element.contains(deviceLocale))) {
      AppMetrica.reportEvent('blockedForFirebase');
      statisticOn = false;
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    } else {
      AppMetrica.reportEvent('approvedInstallForFirebase');
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      FirebaseAnalyticaService.reportEvent('approvedInstallForFirebase');
    }
  }

  @override
  void initState() {
    super.initState();
    getRegion();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return LocaleBuilder(
      builder: (locale) {
        return MaterialApp(
          localizationsDelegates: Locales.delegates,
          supportedLocales: Locales.supportedLocales,
          locale: locale,
          initialRoute: '/',
          routes: {
            '/': (context) => Splashscreen(),
            '/home': (context) => HomePage(),
            '/subscription': (context) => SubscriptionPage(),
            '/tutorial': (context) => TutorialPage(),
            '/onboarding': (context) => Onboarding(),
          },
        );
      },
    );
  }
}
