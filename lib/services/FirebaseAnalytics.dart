import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticaService {
  FirebaseAnalyticaService._();
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static void reportEvent(String name) {
    analytics.logEvent(name: name);
  }
}
