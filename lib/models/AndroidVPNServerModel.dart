class AndroidVPNServerModel {
  AndroidVPNServerModel({
    this.displayName,
    this.serverConfigPath,
    this.realIp,
    this.certificate,
    this.password,
    this.login,
    this.isFree,
  });

  String displayName;
  String serverConfigPath;
  String realIp;
  String certificate;
  String password;
  String login;
  bool isFree;
}
