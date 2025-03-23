import 'dart:async';
import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_vpn/state.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/services/AppodealService.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:mandarinvpn/templates/TimeConnected.dart';
import 'package:provider/provider.dart';

class QuickConnect extends StatelessWidget {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: deviceHeight(context) * 0.016),
            alignment: Alignment.center,
            child: Consumer<UserModel>(
              builder: (context, model, child) {
                String vpnStatusText = getVPNStatus(context,
                    androidVpnStatus: model.connectionStatusAndroid,
                    iosVpnState: model.connectionStatus);
                return Padding(
                  padding: EdgeInsets.only(top: deviceHeight(context) * 0.035),
                  child: Text(
                    vpnStatusText,
                    style: StylesHelper.getRubicStyleWithParams(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(21, 47, 130, 1)),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Consumer<UserModel>(
              builder: (context, model, child) => GestureDetector(
                child: checkVPNStatus(
                    androidVpnStatus: model.connectionStatusAndroid,
                    iosVpnState: model.connectionStatus),
                onTap: () {
                  Platform.isAndroid
                      ? model.quickConnectAndroid()
                      : model.quickConnect();

                  bool connectionStatus =
                      model.connectionStatusAndroid == 'CONNECTED';
                  bool subscriptionStatus = model.subscriptionStatus;

                  if (connectionStatus) {
                    AppMetrica.reportEvent('stopClick');
                    if (statisticOn)
                      FirebaseAnalyticaService.reportEvent('stopClick');
                    if (!subscriptionStatus) {
                      AppodealService.instance.initInterstitial();
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget checkVPNStatus(
      {String androidVpnStatus, FlutterVpnState iosVpnState}) {
    if (Platform.isAndroid) {
      switch (androidVpnStatus) {
        case 'DISCONNECTED':
          return VPNQuickConnect();
        case 'CONNECTED':
          return VPNConnected();
        default:
          return VPNWaitConnection();
      }
    } else {
      switch (iosVpnState) {
        case FlutterVpnState.disconnected:
          return VPNQuickConnect();
        case FlutterVpnState.connected:
          return VPNConnected();
        default:
          return VPNWaitConnection();
      }
    }
  }

  String getVPNStatus(BuildContext context,
      {String androidVpnStatus, FlutterVpnState iosVpnState}) {
    if (Platform.isAndroid) {
      switch (androidVpnStatus) {
        case 'DISCONNECTED':
          return Locales.of(context).get('vpn_quick_connect') ?? ' ';
        case 'CONNECTED':
          return Locales.of(context).get('vpn_connected') ?? ' ';
        default:
          return Locales.of(context).get('vpn_connecting') ?? ' ';
      }
    } else {
      switch (iosVpnState) {
        case FlutterVpnState.disconnected:
          return 'Quick Connect';
        case FlutterVpnState.connected:
          return 'Connected';
        default:
          return 'Connecting';
      }
    }
  }
}

class VPNQuickConnect extends StatelessWidget {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  const VPNQuickConnect();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: deviceWidth(context) * .6,
      height: deviceHeight(context) * 0.065,
      child: Consumer<UserModel>(
        builder: (context, model, child) => Container(
          width: deviceWidth(context) * .6,
          height: deviceHeight(context) * 0.065,
          alignment: Alignment.center,
          decoration: StylesHelper.vpnButtonDecoration,
          child: LocaleText(
            'vpn_start',
            style: StylesHelper.getRubicStyleWithParams(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class VPNWaitConnection extends StatefulWidget {
  const VPNWaitConnection();
  @override
  _VPNWaitConnectionState createState() => _VPNWaitConnectionState();
}

class _VPNWaitConnectionState extends State<VPNWaitConnection> {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  @override
  void initState() {
    timer = Timer.periodic(
        Duration(milliseconds: 300), (timer) => changeActivePoint());
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Timer timer;
  int activePoint = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: deviceWidth(context) * .15,
      height: deviceHeight(context) * 0.065,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: VPNWaitConnectionPoint(
                pointNumber: 0,
                currentActivePoint: activePoint,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              alignment: Alignment.center,
              child: VPNWaitConnectionPoint(
                pointNumber: 1,
                currentActivePoint: activePoint,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: VPNWaitConnectionPoint(
                pointNumber: 2,
                currentActivePoint: activePoint,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              alignment: Alignment.center,
              child: VPNWaitConnectionPoint(
                pointNumber: 3,
                currentActivePoint: activePoint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeActivePoint() {
    if (activePoint == 3) {
      setState(() {
        activePoint = 0;
      });
      return;
    }
    setState(() {
      activePoint++;
    });
  }
}

class VPNWaitConnectionPoint extends StatelessWidget {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  final pointNumber;
  final currentActivePoint;
  const VPNWaitConnectionPoint({this.pointNumber, this.currentActivePoint});

  @override
  Widget build(BuildContext context) {
    if (currentActivePoint == pointNumber)
      return Container(
        width: deviceWidth(context) * .030,
        height: deviceHeight(context) * 0.015,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: <Color>[
              Color.fromRGBO(63, 177, 238, 1),
              Color.fromRGBO(21, 136, 198, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color.fromRGBO(108, 159, 185, 0.25),
              blurRadius: 20,
            ),
          ],
        ),
      );
    return Container(
      width: deviceWidth(context) * .030,
      height: deviceHeight(context) * 0.015,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: <Color>[
            Color.fromRGBO(63, 177, 238, 1).withOpacity(0.3),
            Color.fromRGBO(21, 136, 198, 1).withOpacity(0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class VPNConnected extends StatelessWidget {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  const VPNConnected();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<UserModel>(
        builder: (context, model, child) => Container(
          width: deviceWidth(context) * .6,
          height: deviceHeight(context) * 0.065,
          alignment: Alignment.center,
          decoration: StylesHelper.vpnButtonDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              LocaleText(
                'vpn_stop',
                style: StylesHelper.getRubicStyleWithParams(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: deviceWidth(context) * .03,
                ),
                child: TimeConnected(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
