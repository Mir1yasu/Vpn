import 'package:mandarinvpn/models/VPNConfigPreferences.dart';

class VPNSettingsInfo {
  VPNSettingsInfo(
      {this.filterAds,
      this.doubleConfigs,
      this.firstCountry,
      this.secondCountry});

  bool filterAds;
  bool doubleConfigs;
  int firstCountry;
  int secondCountry;
  VPNConfigPreferences configPreferences;
}
