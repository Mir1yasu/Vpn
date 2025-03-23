import 'dart:async';
import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:http/http.dart' as http;
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';

class RateCommentDialog extends StatefulWidget {
  RateCommentDialog({Key key}) : super(key: key);

  @override
  State<RateCommentDialog> createState() => _RateCommentDialogState();
}

class _RateCommentDialogState extends State<RateCommentDialog> {
  final _messageController = TextEditingController();

  ButtonState _stateTextWithIcon = ButtonState.idle;

  @override
  void dispose() {
    _messageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Locales.of(context);

    Provider.of<UserModel>(context, listen: false).context = context;

    final outlineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromRGBO(63, 177, 238, 1),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(10),
    );

    return Consumer<UserModel>(
      builder: (context, model, child) {
        return AlertDialog(
          title: Text(
            locale.get('rate_comment_dialog_message'),
          ),
          content: TextFormField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              focusedErrorBorder: outlineInputBorder,
              focusedBorder: outlineInputBorder,
              enabledBorder: outlineInputBorder,
              hintText: locale.get('rate_comment_dialog_comment'),
            ),
          ),
          actions: [
            Center(
              child: ProgressButton.icon(
                iconedButtons: {
                  ButtonState.idle: IconedButton(
                    text: locale.get('rate_comment_dialog_send'),
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    color: Color.fromRGBO(63, 177, 238, 1),
                  ),
                  ButtonState.loading: IconedButton(
                    text: locale.get('rate_comment_dialog_loading'),
                    color: Color.fromRGBO(63, 177, 238, 1),
                  ),
                  ButtonState.fail: IconedButton(
                    text: locale.get('rate_comment_dialog_error'),
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                    ),
                    color: Colors.red.shade300,
                  ),
                  ButtonState.success: IconedButton(
                    text: locale.get('rate_comment_dialog_sent'),
                    icon: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    color: Colors.green.shade400,
                  ),
                },
                onPressed: _onSendButtonPressed,
                state: _stateTextWithIcon,
              ),
            ),
            TextButton(
              onPressed: () => _onBackButtonPressed(context),
              child: Center(
                child: Text(
                  locale.get('rate_comment_dialog_back'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<int> _sendEmail(String message) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    const serviceId = 'service_psw8t6p';
    const templateId = 'template_r04ux5s';
    const userId = 'Xm7ZoPp3RwrBIpIp-';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'message': message,
          }
        },
      ),
    );

    return response.statusCode;
  }

  void _onSendButtonPressed() async {
    switch (_stateTextWithIcon) {
      case ButtonState.idle:
        _stateTextWithIcon = ButtonState.loading;

        final response = await _sendEmail(_messageController.value.text);

        Future.delayed(
          Duration(seconds: 2),
          () {
            setState(() {
              if (response == 200) {
                _stateTextWithIcon = ButtonState.success;
                _messageController.clear();

                Timer(
                  const Duration(seconds: 5),
                  () {
                    Navigator.pop(context, true);
                  },
                );

                AppMetrica.reportEvent('emailRateDialogSuccess');
                if (statisticOn)
                  FirebaseAnalyticaService.reportEvent(
                      'emailRateDialogSuccess');
              } else {
                _stateTextWithIcon = ButtonState.fail;
                _messageController.clear();

                AppMetrica.reportEvent('emailRateDialogFail');
                if (statisticOn)
                  FirebaseAnalyticaService.reportEvent('emailRateDialogFail');
              }
            });
          },
        );

        break;
      case ButtonState.loading:
        break;
      case ButtonState.success:
        _stateTextWithIcon = ButtonState.idle;
        break;
      case ButtonState.fail:
        _stateTextWithIcon = ButtonState.idle;
        break;
    }
    setState(() {
      _stateTextWithIcon = _stateTextWithIcon;
    });
  }

  void _onBackButtonPressed(BuildContext context) =>
      Navigator.pop(context, false);
}
