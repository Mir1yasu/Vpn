import 'dart:async';
import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:flutter_vpn/state.dart';
import 'package:mandarinvpn/helpers/DialogHelper.dart';
import 'package:mandarinvpn/helpers/FrequencyHelper.dart';
import 'package:mandarinvpn/helpers/PagesHelper.dart';
import 'package:mandarinvpn/helpers/ServersHelper.dart';
import 'package:mandarinvpn/helpers/TimeHelper.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/AndroidVPNServerModel.dart';
import 'package:mandarinvpn/pages/HomePage.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:mandarinvpn/services/PreferencesService.dart';
import 'package:mandarinvpn/services/SubscriptionService.dart';
import 'package:mandarinvpn/templates/CustomExpansionPanel.dart';
import 'package:mandarinvpn/vpn/core/models/vpnConfig.dart';
import 'package:mandarinvpn/vpn/core/utils/mandarinvpn_engine.dart';
import 'package:package_info/package_info.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:vibration/vibration.dart';

enum Subscription {
  weekly,
  monthly,
  annual,
}

class UserModel extends ChangeNotifier {
  static const channel = MethodChannel('com.gsvpn');

  String _androidVpnStatus;

  BuildContext context;

  AndroidVPNServerModel currentAndroidVPNIP;

  ScrollController homePageScrollController = new ScrollController();

  List<AndroidVPNServerModel> vpnServers = [];

  RateMyApp rateMyApp;

  FlutterVpnState _status;

  List<String> _countryNames = [];

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  Timer _timer;

  String _appVersion;

  get applicationVersion => _appVersion ?? '';

  String _preferableServer;

  int _timerStarted;

  bool _subscriptionStatus;
  bool _firstStart = false;
  bool splashDone = false;
  bool blockerState = false;
  bool whiteListed = true;

  StreamController<String> _prefServerUpdateStreamController;
  Stream<String> prefServerUpdateStream;

  Future<void> initApplicationVersion() async {
    _appVersion = (await PackageInfo.fromPlatform()).version;
    notifyListeners();
  }

  Future<void> getVPNServersFromFirebase() async {
    if (vpnServers.isNotEmpty) return;

    await FirebaseFirestore.instance.disableNetwork();
    await FirebaseFirestore.instance.enableNetwork();
    var firebaseData = await FirebaseFirestore.instance
        .collection('vpn')
        .doc('countries')
        .get();

    List<Map<String, dynamic>> countries =
        firebaseData['countries'].cast<Map<String, dynamic>>();
    vpnServers = convertFirebseDataToVPNModel(countries);
    //notifyListeners();
  }

  List<String> getAllCountryNames() {
    if (_countryNames.length == 0) {
      _countryNames = vpnServers.map((e) => e.displayName).toList();
    }
    return _countryNames;
  }

  List<AndroidVPNServerModel> convertFirebseDataToVPNModel(
    List<Map<String, dynamic>> data,
  ) {
    List<AndroidVPNServerModel> value = [];

    for (var i = 0; i < data.length; i++) {
      value.add(
        AndroidVPNServerModel(
          serverConfigPath: data[i]['serverConfigPath'],
          displayName: data[i]['name'],
          login: data[i]['login'],
          password: data[i]['password'],
          isFree: data[i]['isFree'],
        ),
      );
    }

    return value;
  }

  Future<bool> subStatusCheck() async {
    _prefServerUpdateStreamController = StreamController<String>()
      ..add(preferableServer);
    prefServerUpdateStream =
        _prefServerUpdateStreamController.stream.asBroadcastStream();

    _status = await FlutterVpn.currentState;

    Stream<String> vpnStageSnapshot = MandarinVpnEngine.vpnStageSnapshot();

    vpnStageSnapshot.listen((stage) {
      _androidVpnStatus = stage.toUpperCase();

      if (_androidVpnStatus == 'DISCONNECTED') {
        AppMetrica.reportEvent('connectionDisconnect');
        AppMetrica.reportEvent('disconnectedConnectVpn$preferableServer');
        if (statisticOn) {
          FirebaseAnalyticaService.reportEvent('connectionDisconnect');
          FirebaseAnalyticaService.reportEvent(
              'disconnectedConnectVpn$preferableServer');
        }
      } else if (_androidVpnStatus == 'DENIED') {
        AppMetrica.reportEvent('connectionDenied');
        AppMetrica.reportEvent('deniedConnectVpn$preferableServer');
        if (statisticOn) {
          FirebaseAnalyticaService.reportEvent('connectionDenied');
          FirebaseAnalyticaService.reportEvent(
              'deniedConnectVpn$preferableServer');
        }
      } else if (_androidVpnStatus == 'CONNECTED') {
        AppMetrica.reportEvent('connectionConnected');
        AppMetrica.reportEvent('connectedVpn$preferableServer');
        if (statisticOn) {
          FirebaseAnalyticaService.reportEvent('connectionConnected');
          FirebaseAnalyticaService.reportEvent('connectedVpn$preferableServer');
        }
      }

      notifyListeners();
    });

    vpnStageSnapshot.listen((stage) {   
      if (stage.toUpperCase() == 'CONNECTED' || stage.toUpperCase() == 'DISCONNECTED') {
        Vibration.vibrate(duration: 250);
      }
    });

    _androidVpnStatus = 'DISCONNECTED';
    _firstStart = PreferencesService.getBool('isFirstStart') ?? true;

    subscriptionStatus = await _subStatusSubscriptionCheck();

    notifyListeners();

    return subscriptionStatus;
  }

  Future<bool> _subStatusSubscriptionCheck() async {
    return await SubscriptionService.instance.subscriptionStatus;
  }

  bool get firstStart {
    return _firstStart;
  }

  String get getAndroidStatus => _androidVpnStatus;

  bool get subscriptionStatus {
    return _subscriptionStatus;
  }

  set subscriptionStatus(bool value) {
    PreferencesService.setBool('isSubscriptionActive', value);
    _subscriptionStatus = value;
  }

  Future<void> subscribe(Subscription product) async {
    if (context == null) {
      return;
    }
    
    DialogHelper.showLoadingDialog(context, _keyLoader);
    try {
      subscriptionStatus =
          await SubscriptionService.instance.buyProduct(product);

      Timer(
        Duration(milliseconds: 200),
        () async {
          if (subscriptionStatus) {
            setEventByProductName(product);
            await PreferencesService.setBool("isSubscriptionActive", true);
            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
            DialogHelper.showDialog(
              context,
              () => const DoneSubscriptionDialog(
                callback: PagesHelper.loadPageReplace,
              ),
            );
          } else {
            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          }
        },
      );
    } catch (e) {
      print(e);
      subscriptionStatus = false;
      Navigator.of(context, rootNavigator: true).pop();
    } finally {
      notifyListeners();
    }
  }

  void updateState() {
    notifyListeners();
  }

  void setEventByProductName(Subscription product) {
    switch (product) {
      case Subscription.weekly:
        AppMetrica.reportEvent('startTrialWeekBuy');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('startTrialWeekBuy');
        break;
      case Subscription.monthly:
        AppMetrica.reportEvent('startTrialMonthBuy');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('startTrialMonthBuy');
        break;
      case Subscription.annual:
        AppMetrica.reportEvent('startTrialYearBuy');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('startTrialYearBuy');
        break;
    }
  }

  String getSubscriptionPrice(Subscription product) {
    switch (product) {
      case Subscription.weekly:
        return '3.99 \$';
        break;
      case Subscription.monthly:
        return '7.99 \$';
        break;
      case Subscription.annual:
        return '59.99 \$';
        break;
    }
    return '59.99 \$';
  }

  void restore() async {
    subscriptionStatus = await SubscriptionService.instance.restoreProducts();
    if (subscriptionStatus) {
      await PreferencesService.setBool("isSubscriptionActive", true);
      PagesHelper.loadPageReplace(context, HomePage());
    } else {
      DialogHelper.showDialog(context, () => const ErrorDialog());
    }
  }

  get preferableServer {
    if (_preferableServer == null) _prefServerCheck();
    return _preferableServer;
  }

  set preferableServer(String value) {
    _preferableServer = value;
    PreferencesService.setString("prefServer", value);
    notifyListeners();
  }

  void onCountrySelect(String country) {
    _prefServerUpdateStreamController.add(country);
    //notifyListeners();
  }

  _prefServerCheck() async {
    String prefServer = PreferencesService.getString("prefServer");

    if (prefServer == null || _preferableServer == '-1' || prefServer == '')
      preferableServer = 'Canada';
    else
      preferableServer = prefServer;

    //notifyListeners();

    return _preferableServer;
  }

  Future<void> connect(String country) async {
    AppMetrica.reportEvent('passed "$country" to connect');
    final vpnServerByDisplayName = vpnServers.firstWhere((data) => country == data.displayName, orElse: () => null,);
    if (!subscriptionStatus && vpnServerByDisplayName != null &&
        !vpnServerByDisplayName.isFree) {
      await disconnect();
      PagesHelper.loadPage(context, '/subscription',
          args: {'fromPage': 'tapConnect'});
      return;
    } else if (_status == FlutterVpnState.connected ||
        _androidVpnStatus == 'CONNECTED') {
      AppMetrica.reportEvent('stopClick');
      if (statisticOn) FirebaseAnalyticaService.reportEvent('stopClick');

      await disconnect();
    } else if (_status == FlutterVpnState.error ||
        _androidVpnStatus == 'INVALID') {
      await disconnect();
    } else if (_status == FlutterVpnState.connecting ||
        _androidVpnStatus == 'CONNECTING') {
      return;
    }

    if (Platform.isAndroid && !(await FlutterVpn.prepared)) {
      return await FlutterVpn.prepare()
          .then((result) async => result ? await connect(country) : null);
    }

    await PreferencesService.setInt('timeStarted', 0);
    if (_timerStarted != null) {
      _timer?.cancel();
      startTimer();
    }

    AppMetrica.reportEvent('startClick');
    if (statisticOn) FirebaseAnalyticaService.reportEvent('startClick');

    PreferencesService.setString('currentServerName', country);
    FrequencyHelper.addServerToFrequent(country);
    if (Platform.isAndroid) {
      AndroidVPNServerModel androidVPNModel =
          ServersHelper.findServerConfig(vpnServers, country);
      currentAndroidVPNIP = androidVPNModel;
      try {
        Reference ref = FirebaseStorage.instance
            .ref('/' + androidVPNModel.serverConfigPath);

        Uint8List data = await ref.getData();

        String openVpnContent = String.fromCharCodes(data);

        await MandarinVpnEngine.startVpn(
          VpnConfig(
            name: country,
            config: openVpnContent,
            username: androidVPNModel.login,
            password: androidVPNModel.password,
          ),
        );
      } catch (e) {
        print(e);
        return;
      }
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    if (Platform.isAndroid) {
      if (_androidVpnStatus != 'DISCONNECTED') {
        if (_timer != null) _timer.cancel();
        _timerStarted = null;
        await MandarinVpnEngine.stopVpn();
        await PreferencesService.setInt('timeStarted', 0);
        await PreferencesService.setString('currentServerName', '-1');
        notifyListeners();
      }
    }
    if (Platform.isIOS) {
      if (_status == FlutterVpnState.connected ||
          _status == FlutterVpnState.connecting) {
        await FlutterVpn.disconnect();
        await PreferencesService.setInt('timeStarted', 0);
        await PreferencesService.setString('currentServerName', '-1');
        notifyListeners();
        if (_timer != null) _timer.cancel();
        _timerStarted = null;
      } else if (_status != FlutterVpnState.connected) return;
    }
    return;
  }

  void quickConnect() async {
    switch (_status) {
      case FlutterVpnState.error:
      case FlutterVpnState.disconnected:
        String prefServerName = await _prefServerCheck();
        if (prefServerName == 'Canada') {
          String serverToConnect = 'Canada';
          connect(serverToConnect);
        } else {
          connect(prefServerName);
        }
        break;
      case FlutterVpnState.connected:
        disconnect();
        break;
      default:
        break;
    }
  }

  void quickConnectAndroid() async {
    switch (_androidVpnStatus) {
      case 'INVALID':
      case 'DISCONNECTED':
        String prefServerName = await _prefServerCheck();
        if (prefServerName == 'Canada') {
          String serverToConnect = 'Canada';
          connect(serverToConnect);
        } else {
          connect(prefServerName);
        }
        break;
      case 'CONNECTED':
        disconnect();
        break;
      default:
        break;
    }
  }

  FlutterVpnState get connectionStatus {
    return _status;
  }

  String get connectionStatusAndroid {
    return _androidVpnStatus;
  }

  // List<VPNServerModel> get servers {
  //   if (_servers == null) getServersFromApi();
  //   return _servers;
  // }

  // set servers(List<VPNServerModel> value) {
  //   _servers = value;
  //   _filteredServers = _servers;
  // }

  void startCheck() async {
    if (Platform.isAndroid) {
      String stage = await MandarinVpnEngine.stage();
      if (stage == 'CONNECTED') {
        _androidVpnStatus = stage;
        if (_timerStarted == null) {
          startTimer();
        }
        notifyListeners();
      }
    } else if (Platform.isIOS) {
      var state = await FlutterVpn.currentState;
      if (state == FlutterVpnState.connected) {
        _status = state;
        if (_timerStarted == null) {
          startTimer();
        }
        notifyListeners();
      }
    }
  }

  void loadCurrentServerFromPrefs() async {
    String currentServerName =
        PreferencesService.getString('currentServerName');
    if (currentServerName == null || currentServerName == '-1') return;
  }

  get allCountries {
    List<CustomExpansionPanel> list = [];
    vpnServers.forEach((server) {
      list.add(CustomExpansionPanel(
        key: UniqueKey(),
        countryName: server.displayName,
      ));
    });
    return list;
  }

  void startTimer() async {
    int timeFromPrefs = PreferencesService.getInt('timeStarted');
    if (timeFromPrefs == null || timeFromPrefs == 0)
      _timerStarted = new DateTime.now().millisecondsSinceEpoch;
    else
      _timerStarted = timeFromPrefs;

    await PreferencesService.setInt('timeStarted', _timerStarted);
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      notifyListeners();
      if (_status != FlutterVpnState.connected ||
          _androidVpnStatus == 'CONNECTED') {
        return;
      }
    });
  }

  String get timeFromStart {
    if (_status == FlutterVpnState.connected ||
        _androidVpnStatus == 'CONNECTED') {
      if (_timerStarted == null) {
        startTimer();
        return '00:00:00';
      }
      double duration =
          (new DateTime.now().millisecondsSinceEpoch - _timerStarted) / 1000;
      return TimeHelper.getStringDuration(duration);
    } else {
      return '00:00:00';
    }
  }

  // void checkBlockerState() async {
  //   if (!subscriptionStatus) {
  //     PagesHelper.loadPage(context, '/subscription');
  //     return;
  //   }

  //   try {
  //     if (Platform.isIOS)
  //       blockerState = await channel.invokeMethod('blockerState');
  //     else {
  //       blockerState ?? blockerState
  //           ? blockerState = false
  //           : blockerState = true;
  //     }
  //   } on PlatformException {
  //     blockerState = false;
  //   }
  //   notifyListeners();
  // }
}

class ServerHelper {
  String login;
  String passsword;

  ServerHelper({this.login, this.passsword});

  factory ServerHelper.fromJson(Map<String, dynamic> json) {
    return ServerHelper(login: json['login'], passsword: json['password']);
  }
}
