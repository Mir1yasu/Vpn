import 'package:flutter/material.dart';

class StylesHelper {
  static LinearGradient primaryGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color.fromRGBO(4, 135, 200, 1),
        Color.fromRGBO(101, 192, 245, 1),
      ]);

  static BoxDecoration vpnButtonDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(48),
    gradient: LinearGradient(
      colors: <Color>[
        Color.fromRGBO(63, 177, 238, 1),
        Color.fromRGBO(21, 136, 198, 1),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Color.fromRGBO(108, 159, 185, 0.25),
        blurRadius: 20,
      ),
    ],
  );

  static BoxShadow searchShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 8.0,
    spreadRadius: 0.0,
    offset: Offset(0.0, 2.0),
  );

  static BoxShadow subscriptionShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 16.0,
    spreadRadius: 0.0,
    offset: Offset(0.0, 10.0),
  );

  static BoxShadow settingsShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 4.0,
    spreadRadius: 0.0,
    offset: Offset(0.0, 2.0),
  );

  static TextStyle getRubicStyleWithParams(
      {double height = 1,
      Color color,
      double fontSize = 14,
      FontWeight fontWeight = FontWeight.w400}) {
    return TextStyle(
        color: color ?? Colors.blue[300],
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: 'Rubic',
        height: 1);
  }
}
