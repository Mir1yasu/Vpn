import 'package:flutter/cupertino.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mandarinvpn/pages/HomePage.dart';
import 'package:mandarinvpn/templates/Loader.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: LocaleText('error_subscription'),
      content: LocaleText('error_subscription_advice'),
      actions: <Widget>[
        CupertinoButton(
          child: LocaleText('close_text'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class SubscriptionCancelDialog extends StatelessWidget {
  const SubscriptionCancelDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: LocaleText('on_subscription_cancel'),
      actions: <Widget>[
        CupertinoButton(
          child: LocaleText('close_text'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class DoneSubscriptionDialog extends StatelessWidget {
  final Function(BuildContext, HomePage) callback;

  const DoneSubscriptionDialog({
    Key key,
    this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: LocaleText('on_subscription_success'),
      actions: <Widget>[
        CupertinoButton(
          child: LocaleText('close_text'),
          onPressed: () {
            Navigator.of(context).pop();
            callback(context, HomePage());
          },
        ),
      ],
    );
  }
}

class DialogHelper {
  static Future<T> showDialog<T extends Object>(
    BuildContext context,
    Widget Function() dialogBuilder,
  ) async {
    return Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => dialogBuilder(),
        transitionsBuilder: (___, animation, ____, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  static Future<void> showLoadingDialog(
    BuildContext context,
    GlobalKey key,
  ) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: CupertinoAlertDialog(
            key: key,
            content: const Center(
              child: Loader(),
            ),
          ),
        );
      },
    );
  }
}
