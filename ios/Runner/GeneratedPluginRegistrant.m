//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<adapty_flutter/AdaptyFlutterPlugin.h>)
#import <adapty_flutter/AdaptyFlutterPlugin.h>
#else
@import adapty_flutter;
#endif

#if __has_include(<appmetrica_plugin/YMMFAppMetricaPlugin.h>)
#import <appmetrica_plugin/YMMFAppMetricaPlugin.h>
#else
@import appmetrica_plugin;
#endif

#if __has_include(<appmetrica_push_plugin/YMPFAppMetricaPushPlugin.h>)
#import <appmetrica_push_plugin/YMPFAppMetricaPushPlugin.h>
#else
@import appmetrica_push_plugin;
#endif

#if __has_include(<cloud_firestore/FLTFirebaseFirestorePlugin.h>)
#import <cloud_firestore/FLTFirebaseFirestorePlugin.h>
#else
@import cloud_firestore;
#endif

#if __has_include(<device_info/FLTDeviceInfoPlugin.h>)
#import <device_info/FLTDeviceInfoPlugin.h>
#else
@import device_info;
#endif

#if __has_include(<device_region/DeviceRegionPlugin.h>)
#import <device_region/DeviceRegionPlugin.h>
#else
@import device_region;
#endif

#if __has_include(<devicelocale/DevicelocalePlugin.h>)
#import <devicelocale/DevicelocalePlugin.h>
#else
@import devicelocale;
#endif

#if __has_include(<firebase_analytics/FLTFirebaseAnalyticsPlugin.h>)
#import <firebase_analytics/FLTFirebaseAnalyticsPlugin.h>
#else
@import firebase_analytics;
#endif

#if __has_include(<firebase_core/FLTFirebaseCorePlugin.h>)
#import <firebase_core/FLTFirebaseCorePlugin.h>
#else
@import firebase_core;
#endif

#if __has_include(<firebase_storage/FLTFirebaseStoragePlugin.h>)
#import <firebase_storage/FLTFirebaseStoragePlugin.h>
#else
@import firebase_storage;
#endif

#if __has_include(<flutter_email_sender/FlutterEmailSenderPlugin.h>)
#import <flutter_email_sender/FlutterEmailSenderPlugin.h>
#else
@import flutter_email_sender;
#endif

#if __has_include(<flutter_mailer/FlutterMailerPlugin.h>)
#import <flutter_mailer/FlutterMailerPlugin.h>
#else
@import flutter_mailer;
#endif

#if __has_include(<flutter_vpn/FlutterVpnPlugin.h>)
#import <flutter_vpn/FlutterVpnPlugin.h>
#else
@import flutter_vpn;
#endif

#if __has_include(<package_info/FLTPackageInfoPlugin.h>)
#import <package_info/FLTPackageInfoPlugin.h>
#else
@import package_info;
#endif

#if __has_include(<rate_my_app/RateMyAppPlugin.h>)
#import <rate_my_app/RateMyAppPlugin.h>
#else
@import rate_my_app;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<stack_appodeal_flutter/AppodealFlutterPlugin.h>)
#import <stack_appodeal_flutter/AppodealFlutterPlugin.h>
#else
@import stack_appodeal_flutter;
#endif

#if __has_include(<url_launcher/FLTURLLauncherPlugin.h>)
#import <url_launcher/FLTURLLauncherPlugin.h>
#else
@import url_launcher;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AdaptyFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"AdaptyFlutterPlugin"]];
  [YMMFAppMetricaPlugin registerWithRegistrar:[registry registrarForPlugin:@"YMMFAppMetricaPlugin"]];
  [YMPFAppMetricaPushPlugin registerWithRegistrar:[registry registrarForPlugin:@"YMPFAppMetricaPushPlugin"]];
  [FLTFirebaseFirestorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseFirestorePlugin"]];
  [FLTDeviceInfoPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTDeviceInfoPlugin"]];
  [DeviceRegionPlugin registerWithRegistrar:[registry registrarForPlugin:@"DeviceRegionPlugin"]];
  [DevicelocalePlugin registerWithRegistrar:[registry registrarForPlugin:@"DevicelocalePlugin"]];
  [FLTFirebaseAnalyticsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseAnalyticsPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [FLTFirebaseStoragePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseStoragePlugin"]];
  [FlutterEmailSenderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterEmailSenderPlugin"]];
  [FlutterMailerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterMailerPlugin"]];
  [FlutterVpnPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterVpnPlugin"]];
  [FLTPackageInfoPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPackageInfoPlugin"]];
  [RateMyAppPlugin registerWithRegistrar:[registry registrarForPlugin:@"RateMyAppPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [AppodealFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"AppodealFlutterPlugin"]];
  [FLTURLLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTURLLauncherPlugin"]];
}

@end
