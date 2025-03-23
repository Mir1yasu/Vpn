import 'dart:ui';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mandarinvpn/helpers/ColorHelper.dart';
import 'package:mandarinvpn/helpers/ImageHelper.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:mandarinvpn/templates/SubscriptionElement.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage();

  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  @override
  void initState() {
    super.initState();
    AppMetrica.reportEvent('crownTrialWindowShow');
    if (statisticOn)
      FirebaseAnalyticaService.reportEvent('crownTrialWindowShow');
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Consumer<UserModel>(
        builder: (context, model, child) => DraggableScrollableSheet(
          initialChildSize: .9,
          builder: (context, conteroller) => Container(
            decoration: BoxDecoration(
              color: ColorHelper.primaryBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1).withOpacity(.12),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    top: deviceSize.height * .02,
                    child: Container(
                      margin: EdgeInsets.only(top: deviceSize.height * 0.01),
                      width: deviceSize.width * 0.2,
                      height: deviceSize.height * 0.009,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(21, 47, 130, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  SubscriptionModifitedPage(),
                ],
              ),
            ),
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
  PageController _pageController = PageController(initialPage: 0);
  int currentPage = 0;
  int trialDuration = 3;
  List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    setState(() {
      pages = <Widget>[
        SubscriptionElement(
          title:
              Locales.of(context).get('subscription_element_week_title') ?? ' ',
          description: Locales.of(context)
                  .get('subscription_element_week_description') ??
              ' ',
          youSave: '',
          isModified: true,
        ),
        SubscriptionElement(
          title: Locales.of(context).get('subscription_element_month_title') ??
              ' ',
          description: Locales.of(context)
                  .get('subscription_element_month_description') ??
              ' ',
          youSave: '-50%',
          isModified: true,
          oldPrice: '23.99\$',
        ),
        SubscriptionElement(
          title:
              Locales.of(context).get('subscription_element_year_title') ?? ' ',
          description: Locales.of(context)
                  .get('subscription_element_year_description') ??
              ' ',
          youSave: '-75%',
          isModified: true,
          oldPrice: '239.96\$',
        ),
      ];
    });

    return Consumer<UserModel>(
      builder: (context, model, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Crown and text
            Padding(padding: EdgeInsets.only(top: 50)),
            Column(
              children: [
                SvgPicture.asset(
                  "assets/images/vectors/crown_icon.svg",
                  width: 22,
                  color: Colors.amber,
                ),
                Padding(padding: EdgeInsets.only(top: 16)),
                AutoSizeText(
                  '${Locales.of(context).get('premium_title')}',
                  maxLines: 1,
                  style: StylesHelper.getRubicStyleWithParams(
                    color: Color.fromRGBO(21, 47, 130, 1),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 4)),
                AutoSizeText(
                  '$trialDuration ${Locales.of(context).get(trialDuration == 3 ? 'premium_title_continue_1' : 'premium_title_continue_2')}',
                  maxLines: 1,
                  style: StylesHelper.getRubicStyleWithParams(
                    color: Color.fromRGBO(21, 47, 130, 1),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 12)),
                // AutoSizeText(
                //   '${Locales.of(context).get('premium_description')} $trialDuration ${Locales.of(context).get('premium_description_continue')}',
                //   textAlign: TextAlign.center,
                //   maxLines: 5,
                //   style: StylesHelper.getRubicStyleWithParams(
                //     color: Color.fromRGBO(21, 47, 130, 1),
                //     fontSize: 14,
                //     fontWeight: FontWeight.w400,
                //   ).copyWith(height: 1.4),
                // ),
                Container(
                  width: 300,
                  child: Container(
                    width: 250,
                    child: AutoSizeText(
                      Locales.of(context).get('free_trial_1_1') +
                          ' $trialDuration ' +
                          Locales.of(context).get('free_trial_1_2'),
                      textAlign: TextAlign.center,
                      style: StylesHelper.getRubicStyleWithParams(
                        color: Color.fromRGBO(21, 47, 130, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      // maxLines: 2,
                      wrapWords: true,
                    ),
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
                    height: 120,
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
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
              onTap: () =>
                  subscribe(currentPage, model.firstStart, model.subscribe),
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
            Padding(padding: EdgeInsets.only(top: 8)),
            Column(
              children: [
                // Container(
                //   height: 40,
                //   child: TextButton(
                //     child: Text(
                //       Locales.of(context).get('advantages_premium') ??
                //           ' ',
                //       textAlign: TextAlign.center,
                //       style: StylesHelper.getRubicStyleWithParams(
                //         color: Color.fromRGBO(21, 47, 130, 1),
                //         fontSize: 14,
                //         fontWeight: FontWeight.w700,
                //       ),
                //     ),
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         PageRouteBuilder(
                //           opaque: false,
                //           pageBuilder: (BuildContext context, _, __) =>
                //               PremiumAdvantages(),
                //         ),
                //       );
                //     },
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 12,
                  ),
                  child: AutoSizeText(
                    Locales.of(context).get('subscription_note'),
                    style: StylesHelper.getRubicStyleWithParams(
                      fontSize: 14,
                      color: Color.fromRGBO(21, 47, 130, 1),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
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
                      launch('http://mobilebank.by/vpn/terms.html');
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16)),
              ],
            ),
          ],
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
          AppMetrica.reportEvent('firstOpencrownTrialWindowClickMonth');
          if (statisticOn)
            FirebaseAnalyticaService.reportEvent(
                'firstOpencrownTrialWindowClickMonth');
        } else {
          AppMetrica.reportEvent('startTrialWeek');
          AppMetrica.reportEvent('crownTrialWindowClickWeek');
          if (statisticOn) {
            FirebaseAnalyticaService.reportEvent('startTrialWeek');
            FirebaseAnalyticaService.reportEvent('crownTrialWindowClickWeek');
          }
        }
        break;
      case 1:
        if (isFirstTrial) {
          AppMetrica.reportEvent('firstOpenTrialMonth');
          AppMetrica.reportEvent('firstOpencrownTrialWindowClickMonth');
          if (statisticOn) {
            FirebaseAnalyticaService.reportEvent('firstOpenTrialMonth');
            FirebaseAnalyticaService.reportEvent(
                'firstOpencrownTrialWindowClickMonth');
          }
        } else {
          AppMetrica.reportEvent('startTrialMonth');
          AppMetrica.reportEvent('crownTrialWindowClickMonth');
          if (statisticOn) {
            FirebaseAnalyticaService.reportEvent('startTrialMonth');
            FirebaseAnalyticaService.reportEvent('crownTrialWindowClickMonth');
          }
        }
        break;
      case 2:
        if (isFirstTrial) {
          AppMetrica.reportEvent('firstOpenTrialAnnual');
          AppMetrica.reportEvent('firstOpencrownTrialWindowClickMonth');
          if (statisticOn) {
            FirebaseAnalyticaService.reportEvent('firstOpenTrialAnnual');
            FirebaseAnalyticaService.reportEvent(
                'firstOpencrownTrialWindowClickMonth');
          }
        } else {
          AppMetrica.reportEvent('startTrialAnnual');
          AppMetrica.reportEvent('crownTrialWindowClickYear');
          if (statisticOn) {
            FirebaseAnalyticaService.reportEvent('startTrialAnnual');
            FirebaseAnalyticaService.reportEvent('crownTrialWindowClickYear');
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
                  Flexible(
                    child: Text(
                      Locales.of(context).get('premium_advantages1'),
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
                child: SubscriptionModifitedPagePremium(),
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

class SubscriptionModifitedPagePremium extends StatefulWidget {
  const SubscriptionModifitedPagePremium({Key key}) : super(key: key);

  @override
  _SubscriptionModifitedPagePremiumState createState() =>
      _SubscriptionModifitedPagePremiumState();
}

class _SubscriptionModifitedPagePremiumState
    extends State<SubscriptionModifitedPagePremium> {
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
