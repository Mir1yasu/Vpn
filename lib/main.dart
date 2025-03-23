
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mandarinvpn/app.dart';
import 'package:mandarinvpn/helpers/ImageHelper.dart';
import 'package:mandarinvpn/helpers/LocalesHelper.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';

bool statisticOn = true;

Future<void> main() async {
  const googlePlayId = 'com.mandarin.vpn';
  const appStoreId = 'com.mandarin.vpn';

  final rateMyApp = RateMyApp(
    // Show rate popup on first day of install
    minDays: 3,
    remindDays: 3,
    // Show rate popup after 10 launches of app after minDays is passed
    minLaunches: 5,
    remindLaunches: 5,
    googlePlayIdentifier: googlePlayId,
    appStoreIdentifier: appStoreId,
  );

  AppMetrica.runZoneGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Future.wait(<Future>[
        Firebase.initializeApp(),
        AppMetrica.activate(const AppMetricaConfig(
          'a14468e0-ecc3-4108-8a02-424e45171c22',
          logs: true,
        )),
        Locales.init(LocalesHelper.locales),
        ImageHelper.init(),
        rateMyApp.init(),
      ]);

      runApp(
        ChangeNotifierProvider(
          create: (context) => UserModel()..rateMyApp = rateMyApp,
          child: MaterialApp(
            showPerformanceOverlay: false,
            home: MandarinVPN(),
          ),
        ),
      );
    },
  );
}
