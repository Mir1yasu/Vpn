import 'package:flutter/material.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:provider/provider.dart';

class TimeConnected extends StatefulWidget {
  @override
  _TimeConnectedState createState() => _TimeConnectedState();
}

class _TimeConnectedState extends State<TimeConnected> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) => Text(
        model.timeFromStart ?? '00:00:00',
        style: StylesHelper.getRubicStyleWithParams(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
