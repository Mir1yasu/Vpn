import 'package:mandarinvpn/models/VPNSocksInfo.dart';

class VPNConfigPreferences {
  VPNConfigPreferences(
      {this.useTCP,
      this.connectRetryMax,
      this.socks,
      this.verb,
      this.useAuthUserPass,
      this.userStrongestEncryption});

  bool useTCP;
  int connectRetryMax;
  VPNSocksInfo socks;
  int verb;
  bool useAuthUserPass;
  bool userStrongestEncryption;
}
