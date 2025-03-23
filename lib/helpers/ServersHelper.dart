import 'package:mandarinvpn/models/AndroidVPNServerModel.dart';

class ServersHelper {
  static AndroidVPNServerModel findServerConfig(
      List<AndroidVPNServerModel> configs, String value) {
    return configs.firstWhere((element) => element.displayName == value);
  }
}
