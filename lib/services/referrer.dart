import 'package:flutter/services.dart';

class Referrer {
  static const platform = MethodChannel('id.mandarin.vpn/referrerClient');

  Future<String> getReferrer() async {
    try {
      final result = await platform.invokeMethod<String>('referrerClient');
      return result;
    } catch (e) {}
    return null;
  }
}
