import 'package:device_apps/device_apps.dart';

class AboutAndroid {
  AboutAndroid._();
  static Future<bool> isInstalledApplication(String appName) async {
    try {
      var isApplicationInstalled = await DeviceApps.isAppInstalled(appName);
      return isApplicationInstalled;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
