import 'dart:convert';

class JsonHelper {
  static Map<dynamic, dynamic> getMapFromJson(String value) {
    if (value == null || value.isEmpty) return null;
    Map<dynamic, dynamic> map = new Map<dynamic, dynamic>();
    map = jsonDecode(value);
    return map;
  }

  static String getJsonFromMap(Map<dynamic, dynamic> value) {
    String json = jsonEncode(value);
    return json;
  }
}
