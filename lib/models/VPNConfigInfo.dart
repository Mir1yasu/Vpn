class VPNConfigInfo {
  VPNConfigInfo({this.getConfig, this.timestamp});

  String getConfig;
  int timestamp;

  DateTime configDate() => DateTime.fromMicrosecondsSinceEpoch(timestamp);
}
