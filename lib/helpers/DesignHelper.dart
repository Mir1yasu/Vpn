import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:mandarinvpn/helpers/ImageHelper.dart';
import 'package:mandarinvpn/models/AboutAndroid.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/pages/Browse/BrowseContent.dart';
import 'package:mandarinvpn/services/PreferencesService.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'PagesHelper.dart';
import 'StylesHelper.dart';

abstract class DesignHelper {
  DesignHelper._();

  static Widget createLoadingPageBackground(BuildContext context,
      {@required Widget child}) {
    return Material(
      color: Colors.white,
      child: Container(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .15,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: const <Color>[
                        Color.fromRGBO(0, 132, 199, 1),
                        Color.fromRGBO(105, 202, 253, 0)
                      ]),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .3575,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: const <Color>[
                        Color.fromRGBO(190, 218, 232, 0),
                        Color.fromRGBO(19, 142, 204, 1)
                      ]),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: child,
            )
          ],
        ),
      ),
    );
  }

  static Widget createHomePageBackground(BuildContext context,
      {@required Widget child}) {
    return Material(
      color: Colors.white,
      child: Container(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .15,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const <Color>[
                      Color.fromRGBO(0, 132, 199, 1),
                      Color.fromRGBO(105, 202, 253, 0)
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .15,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const <Color>[
                      Color.fromRGBO(190, 218, 232, 0),
                      Color.fromRGBO(19, 142, 204, 1)
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: child,
            )
          ],
        ),
      ),
    );
  }

  static Widget createScrollElementButtonPattern({@required Widget child}) {
    return Container(
      width: 269,
      height: 51,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color.fromRGBO(21, 47, 130, 1),
            width: 0,
          ),
        ),
      ),
      child: child,
    );
  }

  static Widget createScrollElementsButtonPattern({@required Widget child}) {
    return Container(
      width: 269,
      height: 51,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(17),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(108, 159, 185, 0.25),
            blurRadius: 25,
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget createSubscriptionCardBackgroundPattern(
      {@required Widget child}) {
    return Material(
      color: Colors.white,
      child: Container(
        width: 280,
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color.fromRGBO(0, 132, 199, 1),
                      Color.fromRGBO(105, 202, 253, 0)
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget createDrawer(BuildContext context) {
    double deviceHeight(BuildContext context) =>
        MediaQuery.of(context).size.height;
    double deviceWidth(BuildContext context) =>
        MediaQuery.of(context).size.width;
    return Drawer(
      child: Consumer<UserModel>(
        builder: (context, model, child) => Container(
          width: MediaQuery.of(context).size.width * .75,
          color: Colors.white,
          padding: const EdgeInsets.only(left: 0),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overscroll) {
              overscroll.disallowIndicator();
              return;
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16, left: 16, right: 15),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: LocaleText(
                          'settings_text',
                          style: StylesHelper.getRubicStyleWithParams(
                            color: Color.fromRGBO(21, 47, 130, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          color: Colors.white,
                          width: deviceWidth(context) * 0.13,
                          height: deviceHeight(context) * 0.05,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ImageHelper.vector['close_icon'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      width: 269,
                      height: 51,
                      decoration: BoxDecoration(),
                      padding: EdgeInsets.only(left: 11),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Image(image: ImageHelper.raster['crown_icon']),
                              SizedBox(
                                width: 15,
                                height: 12,
                              ),
                              LocaleText(
                                'premium_title',
                                style: StylesHelper.getRubicStyleWithParams(
                                  color: Color.fromRGBO(21, 47, 130, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: const EdgeInsets.only(left: 5)),
                          LocaleText(
                            model.subscriptionStatus
                                ? 'active_text'
                                : 'inactive_text',
                            style: StylesHelper.getRubicStyleWithParams(
                              color: Color.fromRGBO(21, 47, 130, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      if (model.subscriptionStatus) return null;
                      PagesHelper.loadPage(context, '/subscription',
                          args: {'fromPage': 'menu'});
                    },
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Consumer<UserModel>(
                        builder: (context, model, child) => GestureDetector(
                          child: DesignHelper.createScrollElementButtonPattern(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 11),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '${Locales.of(context).get('country_text')}: ',
                                        style: StylesHelper
                                            .getRubicStyleWithParams(
                                          color: Color.fromRGBO(21, 47, 130, 1),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      LocaleText(
                                        '${model.preferableServer != null ? model.preferableServer.toString().toLowerCase().trim().replaceAll(' ', '') : ''}',
                                        style: StylesHelper
                                            .getRubicStyleWithParams(
                                          color: Color.fromRGBO(21, 47, 130, 1),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.transparent,
                              builder: (context) => BrowseContent(),
                            );
                          },
                        ),
                      ),
                      GestureDetector(
                        child: DesignHelper.createScrollElementButtonPattern(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 11),
                              child: LocaleText(
                                'privacy_text',
                                style: StylesHelper.getRubicStyleWithParams(
                                  color: Color.fromRGBO(21, 47, 130, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        onTap: () async =>
                            launch('http://mobilebank.by/vpn/privacy.html'),
                      ),
                      GestureDetector(
                        child: DesignHelper.createScrollElementButtonPattern(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 11),
                              child: LocaleText(
                                'terms_text',
                                style: StylesHelper.getRubicStyleWithParams(
                                  color: Color.fromRGBO(21, 47, 130, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        onTap: () async =>
                            launch('http://mobilebank.by/vpn/terms.html'),
                      ),
                      GestureDetector(
                          child: DesignHelper.createScrollElementButtonPattern(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 11),
                                child: LocaleText(
                                  'feedback_text',
                                  style: StylesHelper.getRubicStyleWithParams(
                                    color: Color.fromRGBO(21, 47, 130, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () async => await _sendSupportMail()),
                      GestureDetector(
                        child: DesignHelper.createScrollElementButtonPattern(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 11),
                              child: Container(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      '${Locales.of(context).get('language_text')}: ',
                                      style:
                                          StylesHelper.getRubicStyleWithParams(
                                        color: Color.fromRGBO(21, 47, 130, 1),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    LocaleText(
                                      'language_now',
                                      style:
                                          StylesHelper.getRubicStyleWithParams(
                                        color: Color.fromRGBO(21, 47, 130, 1),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        onTap: () async => await showLanguageBoard(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showLanguageBoard(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 280,
          height: 400,
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 1),
            borderRadius: BorderRadius.circular(32),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromRGBO(108, 159, 185, 0.25),
                blurRadius: 30,
              ),
            ],
          ),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overscroll) {
              overscroll.disallowIndicator();
              return;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              child: Column(
                // padding: const EdgeInsets.only(
                //   top: 10,
                //   left: 10,
                //   right: 10,
                // ),
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    child: DesignHelper.createScrollElementsButtonPattern(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 11),
                          child: Text(
                            'English',
                            style: StylesHelper.getRubicStyleWithParams(
                              color: Color.fromRGBO(21, 47, 130, 1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async => {
                      Locales.change(context, 'en'),
                      PreferencesService.setString('language', 'en'),
                      Navigator.of(_).pop()
                    },
                  ),
                  GestureDetector(
                    child: DesignHelper.createScrollElementsButtonPattern(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 11),
                          child: Text(
                            'Deutsch',
                            style: StylesHelper.getRubicStyleWithParams(
                              color: Color.fromRGBO(21, 47, 130, 1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async => {
                      Locales.change(context, 'de'),
                      PreferencesService.setString('language', 'de'),
                      Navigator.of(_).pop()
                    },
                  ),
                  GestureDetector(
                    child: DesignHelper.createScrollElementsButtonPattern(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 11),
                          child: Text(
                            'Русский',
                            style: StylesHelper.getRubicStyleWithParams(
                              color: Color.fromRGBO(21, 47, 130, 1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async => {
                      Locales.change(context, 'ru'),
                      PreferencesService.setString('language', 'ru'),
                      Navigator.of(_).pop()
                    },
                  ),
                  GestureDetector(
                    child: DesignHelper.createScrollElementsButtonPattern(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 11),
                          child: Text(
                            'Português',
                            style: StylesHelper.getRubicStyleWithParams(
                              color: Color.fromRGBO(21, 47, 130, 1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async => {
                      Locales.change(context, 'pt'),
                      PreferencesService.setString('language', 'pt'),
                      Navigator.of(_).pop()
                    },
                  ),
                  GestureDetector(
                    child: DesignHelper.createScrollElementsButtonPattern(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 11),
                          child: Text(
                            'Español',
                            style: StylesHelper.getRubicStyleWithParams(
                              color: Color.fromRGBO(21, 47, 130, 1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async => {
                      Locales.change(context, 'es'),
                      PreferencesService.setString('language', 'es'),
                      Navigator.of(_).pop()
                    },
                  ),
                  GestureDetector(
                    child: DesignHelper.createScrollElementsButtonPattern(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 11),
                          child: Text(
                            'Polska',
                            style: StylesHelper.getRubicStyleWithParams(
                              color: Color.fromRGBO(21, 47, 130, 1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async => {
                      Locales.change(context, 'pl'),
                      PreferencesService.setString('language', 'pl'),
                      Navigator.of(_).pop()
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _sendSupportMail() async {
    try {
      const String GMAIL_SCHEMA = 'com.google.android.gm';
      final bool isGmailInstalled =
          await AboutAndroid.isInstalledApplication(GMAIL_SCHEMA);
      if (isGmailInstalled) {
        final MailOptions mailOptions = MailOptions(
          body: '',
          subject: '',
          recipients: ['vpn.mandarin.app@gmail.com'],
          isHTML: false,
          appSchema: GMAIL_SCHEMA,
        );
        await FlutterMailer.send(mailOptions);
        return;
      }
      await launch(
          'https://play.google.com/store/apps/details?id=com.mandarin.vpn');
    } catch (e) {
      print(e.message);
      await launch(
          'https://play.google.com/store/apps/details?id=com.mandarin.vpn');
    }
  }
}
