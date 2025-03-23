import 'dart:developer';
import 'dart:ui';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mandarinvpn/helpers/ColorHelper.dart';
import 'package:mandarinvpn/helpers/ImageHelper.dart';
import 'package:mandarinvpn/helpers/PagesHelper.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/AdController.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/services/AppodealService.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:mandarinvpn/templates/SubscriptionElement.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  PageController _pageController = PageController(initialPage: 0);
  int currentPage = 0;
  int trialDuration = 3;
  List<Widget> pages;
  bool flag = false;
  String fromPage;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, String>{}) as Map<String, String>;
    fromPage = arguments['fromPage'];
    if (fromPage != null && !flag) {
      flag = true;
      log('message arguments $fromPage');

      if (fromPage == 'splashScreen') {
        AppMetrica.reportEvent('appOpenTrialWindowShow');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('appOpenTrialWindowShow');
      } else if (fromPage == 'menu') {
        AppMetrica.reportEvent('menuTrialWindowShow');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('menuTrialWindowShow');
      } else if (fromPage == 'tapConnect') {
        AppMetrica.reportEvent('tryToConnectTrialWindowShow');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('tryToConnectTrialWindowShow');
      }
    }

    setState(() {
      pages = <Widget>[
        SubscriptionElement(
          title:
              Locales.of(context).get('subscription_element_week_title') ?? ' ',
          description: Locales.of(context)
                  .get('subscription_element_week_description') ??
              ' ',
          youSave: '',
        ),
        SubscriptionElement(
          title: Locales.of(context).get('subscription_element_month_title') ??
              ' ',
          description: Locales.of(context)
                  .get('subscription_element_month_description') ??
              ' ',
          youSave: '-50%',
          oldPrice: '23.99\$',
        ),
        SubscriptionElement(
          title:
              Locales.of(context).get('subscription_element_year_title') ?? ' ',
          description: Locales.of(context)
                  .get('subscription_element_year_description') ??
              ' ',
          youSave: '-75%',
          oldPrice: '239.96\$',
        ),
      ];
    });
    return Consumer<UserModel>(
      builder: (context, model, child) => Scaffold(
        body: Material(
          color: Colors.black,
          child: Container(
            color: ColorHelper.primaryBackgroundColor,
            child: WillPopScope(
              onWillPop: () async => onCloseTrialButtonClick(context, model),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SafeArea(
                        child: GestureDetector(
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SvgPicture.asset(
                                "assets/images/vectors/close_icon.svg",
                              ),
                            ),
                          ),
                          onTap: () => onCloseTrialButtonClick(context, model),
                        ),
                      ),
                    ],
                  ),
                  // Crown and text
                  Column(
                    children: [
                      SvgPicture.asset(
                        "assets/images/vectors/crown_icon.svg",
                        width: 22,
                        color: Colors.amber,
                      ),
                      Padding(padding: EdgeInsets.only(top: 22)),
                      AutoSizeText(
                        '${Locales.of(context).get('premium_title')}',
                        maxLines: 1,
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 6)),
                      AutoSizeText(
                        '$trialDuration ${Locales.of(context).get(trialDuration == 3 ? 'premium_title_continue_1' : 'premium_title_continue_2')}',
                        maxLines: 1,
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 18)),
                      Container(
                        width: 300,
                        child: AutoSizeText(
                          Locales.of(context).get('free_trial_1_1') +
                              ' $trialDuration ' +
                              Locales.of(context).get('free_trial_1_2'),
                          textAlign: TextAlign.center,
                          style: StylesHelper.getRubicStyleWithParams(
                            color: Color.fromRGBO(21, 47, 130, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          wrapWords: true,
                        ),
                      ),
                    ],
                  ),
                  // PageView and scroll indicator
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: Container()),
                        Container(
                          width: 300,
                          height: 130,
                          child: NotificationListener<
                              OverscrollIndicatorNotification>(
                            onNotification:
                                (OverscrollIndicatorNotification overscroll) {
                              overscroll.disallowIndicator();
                              return;
                            },
                            child: PageView(
                              children: pages,
                              controller: _pageController,
                              onPageChanged: (page) => updateCurrentPage(page),
                            ),
                          ),
                        ),
                        Container(
                          width: 45,
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              for (var i = 0; i < 3; i++)
                                GestureDetector(
                                  onTap: () => onPageIndexTap(i),
                                  child: Container(
                                    width: currentPage == i ? 10 : 8,
                                    height: currentPage == i ? 10 : 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: currentPage == i
                                          ? LinearGradient(
                                              colors: <Color>[
                                                Color.fromRGBO(57, 83, 164, 1),
                                                Color.fromRGBO(21, 47, 130, 1),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            )
                                          : LinearGradient(
                                              colors: <Color>[
                                                Color.fromRGBO(57, 83, 164, 1)
                                                    .withOpacity(0.3),
                                                Color.fromRGBO(21, 47, 130, 1)
                                                    .withOpacity(0.3),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                  // Subscription button
                  GestureDetector(
                    onTap: () => subscribe(
                        currentPage, model.firstStart, model.subscribe),
                    child: Container(
                      width: 300,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
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
                      ),
                      child: Text(
                        Locales.of(context).get('get_trial_text') ?? ' ',
                        textAlign: TextAlign.center,
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Additional buttons
                  Padding(padding: EdgeInsets.only(top: 16)),
                  Column(
                    children: [
                      Container(
                        height: 40,
                        child: TextButton(
                          child: Text(
                            Locales.of(context).get('advantages_premium') ??
                                ' ',
                            textAlign: TextAlign.center,
                            style: StylesHelper.getRubicStyleWithParams(
                              color: Color.fromRGBO(21, 47, 130, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (BuildContext context, _, __) =>
                                    PremiumAdvantages(),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: AutoSizeText(
                                Locales.of(context).get('restore_text'),
                                style: StylesHelper.getRubicStyleWithParams(
                                  fontSize: 14,
                                  color: Color.fromRGBO(21, 47, 130, 1),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () {
                                model.restore();
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: AutoSizeText(
                                Locales.of(context).get('privacy_text'),
                                style: StylesHelper.getRubicStyleWithParams(
                                  fontSize: 14,
                                  color: Color.fromRGBO(21, 47, 130, 1),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () {
                                launch('http://mobilebank.by/vpn/privacy.html');
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 25,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Text(
                            Locales.of(context).get('terms_text'),
                            style: StylesHelper.getRubicStyleWithParams(
                              fontSize: 14,
                              color: Color.fromRGBO(21, 47, 130, 1),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            launch(
                                'https://pages.flycricket.io/mandarin-vpn/terms.html');
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onPageIndexTap(int page) async {
    await _pageController
        .animateToPage(page,
            duration: Duration(milliseconds: 200), curve: Curves.easeInOut)
        .then(
          (t) => updateCurrentPage(page),
        );
  }

  void updateCurrentPage(int page) {
    if (page != 0) {
      trialDuration = 7;
    } else {
      trialDuration = 3;
    }
    currentPage = page;
    setState(() {});
  }

  void subscribe(int page, bool isFirstTrial, Function(Subscription) callback) {
    switch (page) {
      case 0:
        if (isFirstTrial) {
          AppMetrica.reportEvent('firstOpenTrialWeekOnBoarding');
          if (statisticOn)
            FirebaseAnalyticaService.reportEvent(
                'firstOpenTrialWeekOnBoarding');
          if (fromPage == 'splashScreen') {
            AppMetrica.reportEvent('firstOpenappOpenTrialClickWeek');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'firstOpenappOpenTrialClickWeek');
          } else if (fromPage == 'menu') {
            AppMetrica.reportEvent('firstOpenmenuTrialWindowClickWeek');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'firstOpenmenuTrialWindowClickWeek');
          } else if (fromPage == 'tapConnect') {
            AppMetrica.reportEvent('firstOpentryToConnectTrialClickWeek');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'firstOpentryToConnectTrialClickWeek');
          }
        } else {
          AppMetrica.reportEvent('startTrialWeek');
          if (statisticOn)
            FirebaseAnalyticaService.reportEvent('startTrialWeek');
          if (fromPage == 'splashScreen') {
            AppMetrica.reportEvent('appOpenTrialClickWeek');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent('appOpenTrialClickWeek');
          } else if (fromPage == 'menu') {
            AppMetrica.reportEvent('menuTrialWindowClickWeek');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent('menuTrialWindowClickWeek');
          } else if (fromPage == 'tapConnect') {
            AppMetrica.reportEvent('tryToConnectTrialClickWeek');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'tryToConnectTrialClickWeek');
          }
        }
        break;
      case 1:
        if (isFirstTrial) {
          AppMetrica.reportEvent('firstOpenTrialMonthOnBoarding');
          if (statisticOn)
            FirebaseAnalyticaService.reportEvent(
                'firstOpenTrialMonthOnBoarding');
          if (fromPage == 'splashScreen') {
            AppMetrica.reportEvent('firstOpenappOpenTrialClickMonth');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'firstOpenappOpenTrialClickMonth');
          } else if (fromPage == 'menu') {
            AppMetrica.reportEvent('firstOpenmenuTrialWindowClickWeek');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'firstOpenmenuTrialWindowClickWeek');
          } else if (fromPage == 'tapConnect') {
            AppMetrica.reportEvent('firstOpentryToConnectTrialClickMonth');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'firstOpentryToConnectTrialClickMonth');
          }
        } else {
          AppMetrica.reportEvent('startTrialMonth');
          if (statisticOn)
            FirebaseAnalyticaService.reportEvent('startTrialMonth');
          if (fromPage == 'splashScreen') {
            AppMetrica.reportEvent('appOpenTrialClickMonth');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent('appOpenTrialClickMonth');
          } else if (fromPage == 'menu') {
            AppMetrica.reportEvent('menuTrialWindowClickWeek');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent('menuTrialWindowClickWeek');
          } else if (fromPage == 'tapConnect') {
            AppMetrica.reportEvent('tryToConnectTrialClickMonth');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'tryToConnectTrialClickMonth');
          }
        }
        break;
      case 2:
        if (isFirstTrial) {
          AppMetrica.reportEvent('firstOpenTrialAnnualOnBoarding');
          if (statisticOn)
            FirebaseAnalyticaService.reportEvent(
                'firstOpenTrialAnnualOnBoarding');
          if (fromPage == 'splashScreen') {
            AppMetrica.reportEvent('firstOpenappOpenTrialClickYear');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'firstOpenappOpenTrialClickYear');
          } else if (fromPage == 'menu') {
            AppMetrica.reportEvent('firstOpenmenuTrialWindowClickWeek');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'firstOpenmenuTrialWindowClickWeek');
          } else if (fromPage == 'tapConnect') {
            AppMetrica.reportEvent('firstOpentryToConnectTrialClickYear');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'firstOpentryToConnectTrialClickYear');
          }
        } else {
          AppMetrica.reportEvent('startTrialAnnual');
          if (statisticOn)
            FirebaseAnalyticaService.reportEvent('startTrialAnnual');
          if (fromPage == 'splashScreen') {
            AppMetrica.reportEvent('appOpenTrialClickYear');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent('appOpenTrialClickYear');
          } else if (fromPage == 'menu') {
            AppMetrica.reportEvent('menuTrialWindowClickWeek');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent('menuTrialWindowClickWeek');
          } else if (fromPage == 'tapConnect') {
            AppMetrica.reportEvent('tryToConnectTrialClickYear');
            if (statisticOn)
              FirebaseAnalyticaService.reportEvent(
                  'tryToConnectTrialClickYear');
          }
        }
        break;
      default:
        return;
    }

    callback(getSubscriptionById(page));
  }

  Subscription getSubscriptionById(int id) {
    switch (id) {
      case 0:
        return Subscription.weekly;
      case 1:
        return Subscription.monthly;
      case 2:
        return Subscription.annual;
    }
    return null;
  }

  Future<bool> onCloseTrialButtonClick(
      BuildContext context, UserModel model) async {
    try {
      if (!model.subscriptionStatus && fromPage == 'splashScreen') {
        AppodealService.instance.initInterstitial();
        AdController.interstitialAdWasShowed = true;
      }
      AppMetrica.reportEvent('closeTrialWindow');
      if (statisticOn) FirebaseAnalyticaService.reportEvent('closeTrialWindow');

      PagesHelper.loadPage(context, '/home');
    } on PlatformException catch (e) {
      print(e.message);
    }
    return true;
  }
}

class PremiumAdvantages extends StatefulWidget {
  @override
  _PremiumAdvantagesState createState() => _PremiumAdvantagesState();
}

class _PremiumAdvantagesState extends State<PremiumAdvantages> {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: AlertDialog(
          scrollable: false,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Image(
                            image: ImageHelper.raster['crown_icon'],
                            width: deviceWidth(context) * 0.075,
                            height: deviceHeight(context) * 0.075,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Color.fromRGBO(21, 47, 130, 1),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: deviceHeight(context) * 0.0045),
                    ),
                    Text(
                      Locales.of(context).get('premium_advantages'),
                      style: StylesHelper.getRubicStyleWithParams(
                        fontSize: 16,
                        color: Color.fromRGBO(21, 47, 130, 1),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      Locales.of(context).get('premium_title'),
                      style: StylesHelper.getRubicStyleWithParams(
                        fontSize: 16,
                        color: Color.fromRGBO(21, 47, 130, 1),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: deviceHeight(context) * 0.04,
              ),
              Row(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: deviceWidth(context) * 0.025),
                  ),
                  SvgPicture.asset(
                    "assets/images/vectors/point.svg",
                    color: Color.fromRGBO(21, 47, 130, 1),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: deviceWidth(context) * 0.03),
                  ),
                  // Flexible(
                  //   child: Text(
                  //     Locales.of(context).get('premium_advantages1'),
                  //     textAlign: TextAlign.center,
                  //     style: StylesHelper.getRubicStyleWithParams(
                  //       color: Color.fromRGBO(21, 47, 130, 1),
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w400,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(
                height: deviceHeight(context) * 0.025,
              ),
              Row(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: deviceWidth(context) * 0.025),
                  ),
                  SvgPicture.asset(
                    "assets/images/vectors/point.svg",
                    color: Color.fromRGBO(21, 47, 130, 1),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: deviceWidth(context) * 0.03),
                  ),
                  Flexible(
                    child: Text(
                      Locales.of(context).get('premium_advantages2'),
                      // textAlign: TextAlign.center,
                      style: StylesHelper.getRubicStyleWithParams(
                        color: Color.fromRGBO(21, 47, 130, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: deviceHeight(context) * 0.025,
              ),
              Row(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: deviceWidth(context) * 0.025),
                  ),
                  SvgPicture.asset(
                    "assets/images/vectors/point.svg",
                    color: Color.fromRGBO(21, 47, 130, 1),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: deviceWidth(context) * 0.03),
                  ),
                  Flexible(
                    child: Text(
                      Locales.of(context).get('premium_advantages3'),
                      // textAlign: TextAlign.center,
                      style: StylesHelper.getRubicStyleWithParams(
                        color: Color.fromRGBO(21, 47, 130, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: deviceHeight(context) * 0.025,
              ),
              Row(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: deviceWidth(context) * 0.025),
                  ),
                  SvgPicture.asset(
                    "assets/images/vectors/point.svg",
                    color: Color.fromRGBO(21, 47, 130, 1),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: deviceWidth(context) * 0.030),
                  ),
                  Flexible(
                    child: Text(
                      Locales.of(context).get('premium_advantages4'),
                      textAlign: TextAlign.center,
                      style: StylesHelper.getRubicStyleWithParams(
                        color: Color.fromRGBO(21, 47, 130, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: deviceHeight(context) * 0.045,
              ),
              Container(
                child: SubscriptionModifitedPage(),
              ),
              SizedBox(
                height: deviceHeight(context) * 0.045,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SubscriptionModifitedPage extends StatefulWidget {
  const SubscriptionModifitedPage({Key key}) : super(key: key);

  @override
  _SubscriptionModifitedPageState createState() =>
      _SubscriptionModifitedPageState();
}

class _SubscriptionModifitedPageState extends State<SubscriptionModifitedPage> {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  int currentPage = 0;
  int trialDuration = 3;

  List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment(0, .6),
              child: GestureDetector(
                onTap: () => subscribe(model.firstStart, model.subscribe),
                child: Container(
                  width: deviceWidth(context) * 0.6,
                  height: deviceHeight(context) * 0.065,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
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
                  ),
                  child: Text(
                    Locales.of(context).get('telegram_connect') ?? ' ',
                    textAlign: TextAlign.center,
                    style: StylesHelper.getRubicStyleWithParams(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void subscribe(bool isFirstTrial, Function(Subscription) callback) {
    if (isFirstTrial) {
      AppMetrica.reportEvent('firstOpenTrialWeek');
      if (statisticOn)
        FirebaseAnalyticaService.reportEvent('firstOpenTrialWeek');
    } else {
      AppMetrica.reportEvent('startTrialWeek');
      if (statisticOn) FirebaseAnalyticaService.reportEvent('startTrialWeek');
    }

    callback(getSubscriptionById());
  }

  Subscription getSubscriptionById() {
    return Subscription.weekly;
  }
}
