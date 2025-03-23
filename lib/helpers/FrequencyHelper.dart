import 'package:mandarinvpn/helpers/JsonHelper.dart';
import 'package:mandarinvpn/services/PreferencesService.dart';

class FrequencyHelper {
  static void addServerToFrequent(String id) async {
    String frequentsFromPrefs = PreferencesService.getString("frequentServers");
    Map<dynamic, dynamic> frequentServers =
        JsonHelper.getMapFromJson(frequentsFromPrefs);
    if (frequentServers == null) {
      frequentServers = new Map<dynamic, dynamic>();
    }
    if (frequentServers.length != 0 && frequentServers.containsKey(id)) {
      frequentServers[id] += 1;
    } else {
      frequentServers.putIfAbsent(id, () => 1);
    }

    frequentsFromPrefs = JsonHelper.getJsonFromMap(frequentServers);
    PreferencesService.setString("frequentServers", frequentsFromPrefs);
  }

  static Future<String> getFrequentServerName() async {
    String frequentsFromPrefs = PreferencesService.getString("frequentServers");
    Map<dynamic, dynamic> frequentServers =
        JsonHelper.getMapFromJson(frequentsFromPrefs);
    if (frequentServers == null || frequentServers.length == 0) {
      return '-1';
    }

    String idOfMostFrequent = '';
    int mostCountedServer = 0;
    frequentServers.forEach((key, value) {
      if (value > mostCountedServer) {
        idOfMostFrequent = key;
        mostCountedServer = value;
      }
    });
    return idOfMostFrequent;
  }
}
