import 'dart:convert';

import 'package:http/http.dart' as http;

class GeolocationAPI {
  static Future<GeolocationData> getData({String query = ''}) async {
    try {
      String request =
          'http://ip-api.com/json/$query?fields=continent,country,countryCode,regionName,district,lat,lon,timezone,offset,isp,org,as,mobile,proxy,hosting,query';
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        print(response.body);
        final parsed = jsonDecode(response.body);
        return GeolocationData.fromJson(parsed);
      }
      return GeolocationData();
    } catch (e) {
      print(e);
      return GeolocationData();
    }
  }
}

class GeolocationData {
  final String continent,
      country,
      countryCode,
      regionName,
      district,
      timezone,
      isp,
      org,
      as,
      ip;
  final double lat, lon;
  final int offset;
  final bool mobile, proxy, hosting;

  GeolocationData({
    this.country,
    this.countryCode,
    this.timezone,
    this.continent,
    this.regionName,
    this.district,
    this.offset,
    this.isp,
    this.org,
    this.as,
    this.mobile,
    this.proxy,
    this.hosting,
    this.ip,
    this.lat,
    this.lon,
  });

  factory GeolocationData.fromJson(Map<String, dynamic> json) {
    return GeolocationData(
        country: json['country'],
        countryCode: json['countryCode'],
        timezone: json['timezone'],
        continent: json['continent'],
        regionName: json['regionName'],
        district: json['district'],
        offset: json['offset'],
        isp: json['isp'],
        org: json['org'],
        as: json['as'],
        mobile: json['mobile'],
        proxy: json['proxy'],
        hosting: json['hosting'],
        ip: json['query'],
        lat: json['lat'],
        lon: json['lon']);
  }

  Map<String, dynamic> toJson() {
    return {
      "country": this.country,
      "countryCode": this.countryCode,
      "timezone": this.timezone,
      "continent": this.continent,
      "regionName": this.regionName,
      "district": this.district,
      "offset": this.offset,
      "isp": this.isp,
      "org": this.org,
      "as": this.as,
      "mobile": this.mobile,
      "proxy": this.proxy,
      "hosting": this.hosting,
      "ip": this.ip,
      "lat": this.lat,
      "lon": this.lon
    };
  }
}
