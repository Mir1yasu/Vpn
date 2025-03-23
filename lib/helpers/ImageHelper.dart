import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageHelper {
  static Map<String, AssetImage> raster = new Map<String, AssetImage>();
  static Map<String, Widget> vector = new Map<String, Widget>();

  static final List<String> listOfRasterImages = [
    'screen1',
    'screen2',
    'screen3',
    'onboardImage_first',
    'onboardImage_second',
    'onboardImage_third',
    'onboardImage_fourth',
    'crown_icon',
    'proxySchemaRU',
    'proxySchemaEN',
  ];

  static final List<String> listOfVectorImages = [
    'loading',
    'vpn_logo',
    'settings_icon',
    'close_icon',
    'checkmark',
    'freelocation_icon',
    'cross',
    'circleRed',
    'circleGreen',
    'checkSymbol',
    'vpnQuickStart',
    'locationSymbol',
    'loadSymbol',
    'help_outline',
    'vpnConnected',
    'warningSymbol',
    'vpnError',
    'more',
    'back',
    'stepPoint1',
    'stepPoint2',
    'stepPoint3',
    'telegram_icon',
  ];

  static final String pathToVectorAssets = "assets/images/vectors/";
  static final String pathToVectorAssetsMAP =
      "assets/images/vectors/coutry_map/";
  static final String pathToRasterAssets = "assets/images/rasters/";

  static Future<void> init() async {
    raster = new Map<String, AssetImage>();
    vector = new Map<String, Widget>();

    for (var i = 0; i < listOfRasterImages.length; i++) {
      raster.putIfAbsent(
          listOfRasterImages[i],
          () =>
              AssetImage(pathToRasterAssets + listOfRasterImages[i] + '.png'));
    }

    for (var i = 0; i < listOfVectorImages.length; i++) {
      vector.putIfAbsent(
          listOfVectorImages[i],
          () => SvgPicture.asset(
              pathToVectorAssets + listOfVectorImages[i] + '.svg'));
    }
  }

  static flag(String flagName) {
    return Image.asset(pathToRasterAssets + "flags/$flagName.png");
  }

  static flags(String flagName) {
    return SvgPicture.asset(pathToVectorAssetsMAP + "$flagName.svg");
  }
}
