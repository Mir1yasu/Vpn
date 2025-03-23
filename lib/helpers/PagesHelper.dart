import 'package:flutter/material.dart';

class PagesHelper {
  static void loadPage(BuildContext context, String route, {Object args}) {
    Navigator.pushNamed(context, route, arguments: args);
  }

  static void loadPageReplace(BuildContext context, Widget route,
      {Object args}) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => route),
        (Route<dynamic> route) => false);
  }
}
