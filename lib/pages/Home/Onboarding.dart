import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mandarinvpn/helpers/ColorHelper.dart';
import 'package:mandarinvpn/helpers/PagesHelper.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/AdController.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/services/AppodealService.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:mandarinvpn/templates/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Onboarding extends StatefulWidget {
  const Onboarding();

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page.floor();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Locales.of(context);
    final deviceSize = MediaQuery.of(context).size;

    final pages = <Widget>[
      OnboardingPageBuilder.image(
        imagePath: 'assets/images/vectors/OnBoarding1.svg',
        title: locale.get('onboarding_page_first_title'),
      ),
      OnboardingPageBuilder.image(
        imagePath: 'assets/images/vectors/OnBoarding2.svg',
        title: locale.get('onboarding_page_second_title'),
      ),
      OnboardingPageBuilder.image(
        imagePath: 'assets/images/vectors/OnBoarding3.svg',
        title: locale.get('onboarding_page_third_title'),
      ),
      // OnboardingPageBuilder.image(
      //   imagePath: 'assets/images/vectors/OnBoarding4.svg',
      //   title: locale.get('onboarding_page_fourth_title'),
      // ),
      OnboardingPageBuilder.advantages(
        title: locale.get('onboarding_page_fifth_title'),
        advantages: [
          locale.get('onboarding_page_fifth_adventages_first'),
          locale.get('onboarding_page_fifth_adventages_second'),
          locale.get('onboarding_page_fifth_adventages_third'),
          locale.get('onboarding_page_fifth_adventages_fourth'),
        ],
      ),
    ];

    return Material(
      child: Consumer<UserModel>(
        builder: (context, model, child) {
          return Container(
            color: ColorHelper.primaryBackgroundColor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildPagesView(pages, deviceSize),
                    SizedBox(height: deviceSize.height * 0.01),
                    _buildDotPagination(pages.length),
                    SizedBox(height: 28),
                    _buildButtonWidget(model, pages.length),
                  ],
                ),
                Positioned(
                  bottom: 15,
                  child: _buildFooter(deviceSize, locale),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPagesView(List<Widget> pages, Size deviceSize) {
    return Container(
      height: deviceSize.height * 0.65,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: PageView(
          children: pages,
          controller: _pageController,
        ),
      ),
    );
  }

  Widget _buildDotPagination(int pagesNumber) {
    final activePageGradient = LinearGradient(
      colors: [
        Color.fromRGBO(57, 83, 164, 1),
        Color.fromRGBO(21, 47, 130, 1),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final notActivePageGradient = LinearGradient(
      colors: [
        Color.fromRGBO(57, 83, 164, 1).withOpacity(0.3),
        Color.fromRGBO(21, 47, 130, 1).withOpacity(0.3),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Container(
      width: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(pagesNumber, (index) {
          final isActive = index == currentPage;
          final dotSize = isActive ? 10.0 : 8.0;

          return GestureDetector(
            onTap: () async => _goToPage(index),
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive ? activePageGradient : notActivePageGradient,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButtonWidget(UserModel model, int pagesNumber) {
    if (currentPage == pagesNumber - 1) {
      return Column(
        children: [
          CustomButton.primaryButton(
            text: 'onboarding_page_fifth_trial_button',
            onPressed: () => _goToSubscriptionPage(model),
          ),
          const SizedBox(height: 15),
          CustomButton.secondaryButton(
            text: 'onboarding_page_fifth_cont_with_ad_button',
            onPressed: () => _goToHomePage(model),
          ),
        ],
      );
    } else {
      return CustomButton.primaryButton(
        text: 'onboarding_page_continue_text',
        onPressed: () async => _onSubscribeWeekly(model),
      );
    }
  }

  Widget _buildFooter(Size deviceSize, Locales locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: deviceSize.width,
          child: AutoSizeText(
            locale.get('onboarding_page_bottom_agreement_text'),
            minFontSize: 12,
            textAlign: TextAlign.center,
            style: StylesHelper.getRubicStyleWithParams(
              color: Color.fromRGBO(21, 47, 130, 1),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: GestureDetector(
            onTap: () async => _launchPrivacyPage(),
            child: LocaleText(
              'privacy_text',
              style: StylesHelper.getRubicStyleWithParams(
                color: Color.fromRGBO(21, 47, 130, 1),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _goToPage(int page) async {
    await _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _goToHomePage(UserModel user) {
    if (user.firstStart) {
      AppMetrica.reportEvent('passAllOnbording');
      if (statisticOn) FirebaseAnalyticaService.reportEvent('passAllOnbording');
    }
    if (!user.subscriptionStatus) {
      AppodealService.instance.initInterstitial();
      AdController.interstitialAdWasShowed = true;
    }

    PagesHelper.loadPage(context, '/home');
  }

  void _goToSubscriptionPage(UserModel user) {
    if (user.firstStart) {
      AppMetrica.reportEvent('passAllOnbording');
      AppMetrica.reportEvent('firstOpenTrialWeek');
      if (statisticOn) {
        FirebaseAnalyticaService.reportEvent('passAllOnbording');
        FirebaseAnalyticaService.reportEvent('firstOpenTrialWeek');
      }
    }
    Navigator.of(context).pop();

    if (!user.subscriptionStatus) {
      PagesHelper.loadPage(context, '/subscription',
          args: {'fromPage': 'onboarding'});
    }
  }

  Future<void> _onSubscribeWeekly(UserModel model) async {
    await _pageController.nextPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    // await model.subscribe(Subscription.weekly);
  }

  Future<void> _launchPrivacyPage() async =>
      await launch('http://mobilebank.by/vpn/privacy.html');
}

class OnboardingPageBuilder extends StatelessWidget {
  const OnboardingPageBuilder({
    @required this.builder,
  });

  final Widget Function(BuildContext) builder;

  factory OnboardingPageBuilder.image({
    String imagePath,
    String title,
  }) {
    return OnboardingPageBuilder(
      builder: (context) {
        final deviceSize = MediaQuery.of(context).size;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset(
              imagePath,
              width: deviceSize.width * 0.5,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(height: deviceSize.height * 0.05),
            AutoSizeText(
              title,
              textAlign: TextAlign.center,
              style: StylesHelper.getRubicStyleWithParams(
                color: Color.fromRGBO(21, 47, 130, 1),
                fontWeight: FontWeight.w500,
              ).copyWith(height: 1.4),
              maxFontSize: 14,
              minFontSize: 12,
              maxLines: 2,
            ),
          ],
        );
      },
    );
  }

  factory OnboardingPageBuilder.advantages({
    String title,
    List<String> advantages,
  }) {
    return OnboardingPageBuilder(
      builder: (context) {
        final deviceSize = MediaQuery.of(context).size;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: deviceSize.height * 0.025),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mandarin VPN',
                  style: StylesHelper.getRubicStyleWithParams(
                      color: Color.fromRGBO(21, 47, 130, 1),
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 25),
            AutoSizeText(
              title,
              style: StylesHelper.getRubicStyleWithParams(
                color: Color.fromRGBO(21, 47, 130, 1),
                fontWeight: FontWeight.w500,
              ).copyWith(height: 1.4),
              maxFontSize: 27,
              minFontSize: 26,
            ),
            SizedBox(height: 15),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Container(
            //       width: 300,
            //       child: AutoSizeText(
            //         Locales.of(context).get('free_trial_1_1') +
            //             ' 3 ' +
            //             Locales.of(context).get('free_trial_1_2'),
            //         textAlign: TextAlign.center,
            //         style: StylesHelper.getRubicStyleWithParams(
            //           color: Color.fromRGBO(21, 47, 130, 1),
            //           fontSize: 18,
            //           fontWeight: FontWeight.w400,
            //         ),
            //         wrapWords: true,
            //       ),
            //     ),
            //   ],
            // ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: advantages.length,
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AutoSizeText(
                        advantages[index],
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontWeight: FontWeight.w400,
                        ).copyWith(height: 1.4),
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 10),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      child: Builder(
        builder: builder,
      ),
    );
  }
}
