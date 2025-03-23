import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mandarinvpn/helpers/ColorHelper.dart';
import 'package:mandarinvpn/helpers/LocalesHelper.dart';
import 'package:mandarinvpn/helpers/PagesHelper.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/pages/HomePage.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:mandarinvpn/services/PreferencesService.dart';
import 'package:mandarinvpn/templates/custom_button.dart';
import 'package:provider/provider.dart';

class PrivacyPage extends StatefulWidget {
  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  String _currentLanguage;

  @override
  void initState() {
    super.initState();

    _currentLanguage = LocalesHelper.locales.first;

    Devicelocale.currentAsLocale.then((value) async {
      final deviceLangCode = value.languageCode.toLowerCase();

      await Locales.change(context, deviceLangCode);

      if (LocalesHelper.locales.contains(deviceLangCode)) {
        _currentLanguage = deviceLangCode;
      }

      if (_currentLanguage == 'pl') {
        AppMetrica.reportEvent('first_polish_locale');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('first_polish_locale');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          shadowColor: Colors.white,
          backgroundColor: ColorHelper.primaryBackgroundColor,
          title: AutoSizeText(
            Locales.of(context).get('privacy_title'),
            textAlign: TextAlign.center,
            style: StylesHelper.getRubicStyleWithParams(
              color: Color(0xff152F82),
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => _onAgreePressed(context, model),
            icon: Icon(
              Icons.clear,
              color: Color(0xff152F82),
            ),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  child: PopupMenuButton<String>(
                    initialValue: _currentLanguage,
                    onSelected: (value) async =>
                        _onLocaleSelected(context, value),
                    itemBuilder: _buildLocaleMenuItems,
                    child: _buildLocaleText(_currentLanguage),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return;
          },
          child: Container(
            color: ColorHelper.primaryBackgroundColor,
            padding: const EdgeInsets.only(left: 16, top: 10, right: 16),
            child: ListView(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: AutoSizeText(
                      Locales.of(context).get('privacy_page_description'),
                      style: TextStyle(
                        color: Color(0xff152F82),
                        fontWeight: FontWeight.w500,
                      ),
                      maxFontSize: 18,
                      minFontSize: 14,
                      maxLines: 55,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: CustomButton.primaryButton(
                      text: 'agree_and_continue',
                      width: _currentLanguage == 'ru' ||
                              _currentLanguage == 'de' ||
                              _currentLanguage == 'pl'
                          ? 280
                          : 220,
                      onPressed: () async => _onAgreePressed(context, model),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildLocaleMenuItems(BuildContext context) {
    return LocalesHelper.locales
        .map((locale) => _buildLocalePopupMenuItem(locale))
        .toList();
  }

  PopupMenuItem<String> _buildLocalePopupMenuItem(String languageCode) {
    return PopupMenuItem(
      child: _buildLocaleText(languageCode),
      value: languageCode,
    );
  }

  Widget _buildLocaleText(String languageCode) {
    return Text(
      languageCode.toUpperCase(),
      style: StylesHelper.getRubicStyleWithParams(
        color: Color(0xff152F82),
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    );
  }

  void _onLocaleSelected(BuildContext context, String value) {
    setState(() {
      _currentLanguage = value;
    });

    Locales.change(context, value);
  }

  Future<void> _onAgreePressed(BuildContext context, UserModel model) async {
    AppMetrica.reportEvent('termsAccepted');
    if (statisticOn) FirebaseAnalyticaService.reportEvent('termsAccepted');

    await PreferencesService.setBool('isFirstStart', false);
    await PreferencesService.setString('language', _currentLanguage);

    PagesHelper.loadPageReplace(context, HomePage());
    PagesHelper.loadPage(context, '/onboarding');

    model.updateState();
  }
}
