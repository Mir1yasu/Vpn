import 'dart:async';
import 'dart:io';

import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:appmetrica_push_plugin/appmetrica_push_plugin.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mandarinvpn/helpers/PagesHelper.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/pages/HomePage.dart';
import 'package:mandarinvpn/pages/PrivacyPage.dart';
import 'package:mandarinvpn/services/AppodealService.dart';
import 'package:mandarinvpn/services/PreferencesService.dart';
import 'package:provider/provider.dart';

class Splashscreen extends StatelessWidget {
  Future<void> _splashTimer(BuildContext context) async {
    try {
      await Future.wait(<Future>[
        Locales(context.locales.locale).load(),
        PreferencesService.init(),
        Provider.of<UserModel>(
          context,
          listen: false,
        ).initApplicationVersion(),
        Provider.of<UserModel>(
          context,
          listen: false,
        ).getVPNServersFromFirebase(),
      ]);
      await AppodealService.instance.initialize();

      String language = PreferencesService.getString('language');
      if (context.locales.locale.countryCode != language) {
        try {
          Locales.change(context, language);
        } catch (e) {
          print(e);
        }
      }
      if (Provider.of<UserModel>(context, listen: false).splashDone) return;
      Provider.of<UserModel>(context, listen: false).splashDone = true;
    } catch (e) {
      print(e);
    }

    Provider.of<UserModel>(context, listen: false).whiteListed = true;
    Timer(Duration(seconds: 2), () async {
      bool subscribed =
          await Provider.of<UserModel>(context, listen: false).subStatusCheck();

      if (Provider.of<UserModel>(context, listen: false).firstStart) {
        PagesHelper.loadPageReplace(context, PrivacyPage());
        return;
      }

      PagesHelper.loadPageReplace(context, HomePage());
      if (!subscribed) {
        PagesHelper.loadPage(context, '/subscription',
            args: {'fromPage': 'splashScreen'});
      }
    });
  }

  Future<void> initSmartlook() async {
    try {
      // SetupOptions options =
      //     (new SetupOptionsBuilder('66a9571ae434e1d19ec9234e6f30426b3de7ecd5')
      //           ..Fps = 2
      //           ..StartNewSession = true)
      //         .build();

      // Smartlook.setupAndStartRecording(options);
    } catch (e) {
      print(e);
    }
  }

  Future<String> getDeviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        return await deviceInfo.iosInfo.then(
          (value) => value.identifierForVendor,
        );
      }
      return await deviceInfo.androidInfo.then((value) => value.androidId);
    } on PlatformException catch (e) {
      print(e.message);
      return "";
    }
  }

  Future<void> initAdaptyIO() async {
    try {
      Adapty().activate();
      await Adapty().identify(await getDeviceID());
      await Adapty().setLogLevel(AdaptyLogLevel.verbose);
    } on AdaptyError catch (e) {
      print(e.message);
    }
  }

  Future<void> initNotifications() async {
    await AppMetricaPush.activate();
    AppMetricaPush.tokenStream.listen((tokens) {
      print(tokens);
    });
  }

  Future<void> init(BuildContext context) async {
    await Future.wait(<Future>[
      initNotifications(),
      initAdaptyIO(),
      initSmartlook(),
      _splashTimer(context),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    init(context);
    return Material(
      color: Color(0xff3FB1EE),
      child: Consumer<UserModel>(
        builder: (context, model, child) => Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/rasters/cd.png',
                    width: 75,
                    height: 100,
                  ),
                  SizedBox(height: 10),
                  Home(),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Text(
                'Version: ${model.applicationVersion}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xff152F82)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    controller.addStatusListener(statusListener);
    controller.forward();
  }

  statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      controller.value = 0.0;
      controller.forward();
    }
  }

  @override
  void dispose() {
    controller.removeStatusListener(statusListener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 6,
      color: Color(0xff3FB1EE),
      child: Center(
        child: AnimatedBuilder(
            animation: controller.view,
            builder: (context, snapshot) {
              return ClipPath(
                clipper: MyClipper(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 6,
                  color: Colors.white.withOpacity(0.05),
                  child: CustomPaint(
                    painter: MyCustomPainter(controller.value),
                  ),
                ),
              );
            }),
      ),
    ));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    Path path = Path();
    path.moveTo(w / 2, 0);
    path.lineTo(w, h / 2);
    path.lineTo(w / 2, h);
    path.lineTo(0, h / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
  }
}

class MyCustomPainter extends CustomPainter {
  final double percentage;

  MyCustomPainter(this.percentage);
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Rect rect = Rect.fromLTWH(0, 0, size.width * percentage, size.height);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
