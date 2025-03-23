import 'dart:io';

import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/services.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/UserModel.dart';

import 'FirebaseAnalytics.dart';

class SubscriptionService {
  static const channel = MethodChannel('com.gsvpn');

  SubscriptionService._privateConstructor();

  static final SubscriptionService instance =
      SubscriptionService._privateConstructor();
  bool _subscriptionStatus;

  get subscriptionStatus async {
    if (_subscriptionStatus == null) await initSubscriptions();
    return _subscriptionStatus ?? false;
  }

  Future<void> initSubscriptions() async {
    if (Platform.isAndroid) {
      _subscriptionStatus = await getSubscriptionStatus();
    } else {
      _subscriptionStatus = await channel.invokeMethod('initPurchases');
    }
  }

  Future<bool> getSubscriptionStatus() async {
    try {
      AdaptyProfile adaptyPurchaserInfo = await Adapty().getProfile();

      if (adaptyPurchaserInfo.subscriptions == null) return false;
      if (adaptyPurchaserInfo.subscriptions.isEmpty) return false;

      for (var i = 0; i < adaptyPurchaserInfo.subscriptions.length; i++) {
        if (adaptyPurchaserInfo.subscriptions.values.elementAt(i).isActive) {
          sendEventToServices(adaptyPurchaserInfo.subscriptions.values
              .elementAt(i)
              .vendorProductId);
          return true;
        }
      }

      return false;
    } catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<List<AdaptyPaywallProduct>> getProducts(Subscription product) async {
    try {
      final AdaptyPaywall paywall = await Adapty()
          .getPaywall(placementId: getIOSSubscribtionPackage(product));
      final List<AdaptyPaywallProduct> getPaywallsResult =
          await Adapty().getPaywallProducts(paywall: paywall);
      return getPaywallsResult;
    } catch (e) {
      print('log ${e.message}');
      return null;
    }
  }

  String getIOSSubscribtionPackage(Subscription product) {
    switch (product) {
      case Subscription.weekly:
        return 'com.vpn.mandarin.weekly';
      case Subscription.monthly:
        return 'com.vpn.mandarin.monthly';
        break;
      case Subscription.annual:
        return 'com.vpn.mandarin.annual';
      default:
        return '';
    }
  }

  String getPuckageByProduct(Subscription product) {
    switch (product) {
      case Subscription.weekly:
        return "Weekly";
      case Subscription.monthly:
        return "Monthly";
      case Subscription.annual:
        return "Annual";
      default:
        return null;
    }
  }

  Future<AdaptyPaywallProduct> getAndroidSubscriptionPackage(
      Subscription product) async {
    List<AdaptyPaywallProduct> paywalls = await getProducts(product);
    return paywalls.first;
  }

  Future<bool> buyProduct(Subscription product) async {
    if (Platform.isIOS) {
      _subscriptionStatus = await channel.invokeMethod(
          'purchaseProduct', getIOSSubscribtionPackage(product));
      return _subscriptionStatus;
    } else {
      try {
        await Adapty().makePurchase(
            product: await getAndroidSubscriptionPackage(product));
        _subscriptionStatus = await getSubscriptionStatus();
      } catch (e) {
        print('log AdaptyError $e');
        _subscriptionStatus = false;
      }
    }

    return _subscriptionStatus;
  }

  Future<bool> restoreProducts() async {
    try {
      if (Platform.isIOS) {
        _subscriptionStatus = await channel.invokeMethod('restoreProducts');
      } else {
        await Adapty().restorePurchases();
        _subscriptionStatus = await getSubscriptionStatus();
      }
    } on PlatformException catch (e) {
      print(e.message);
      _subscriptionStatus = false;
    } on AdaptyError catch (e) {
      print(e.message);
      _subscriptionStatus = false;
    }

    return _subscriptionStatus;
  }

  void sendEventToServices(String product) {
    switch (product) {
      case "com.vpn.mandarin.weekly":
        AppMetrica.reportEvent('activeWeekSubscription');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('activeWeekSubscription');
        break;
      case "com.vpn.mandarin.monthly":
        AppMetrica.reportEvent('activeMonthSubscription');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('activeMonthSubscription');
        break;
      case "com.vpn.mandarin.annual":
        AppMetrica.reportEvent('activeYearSubscription');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('activeYearSubscription');
        break;
    }
  }
}
