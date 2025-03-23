import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:mandarinvpn/helpers/ColorHelper.dart';
import 'package:mandarinvpn/helpers/DesignHelper.dart';
import 'package:mandarinvpn/helpers/DialogHelper.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/AboutAndroid.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/pages/Home/AdBanner.dart';
import 'package:mandarinvpn/pages/Home/QuickConnect.dart';
import 'package:mandarinvpn/pages/Home/map.dart';
import 'package:mandarinvpn/pages/Home/rate_comment_dialog.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:mandarinvpn/templates/HomePagePanel.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    context.read<UserModel>().context = context;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userModel = Provider.of<UserModel>(context, listen: false);

      // Check connection status
      userModel.startCheck();

      // Rate app dialog
      _showStartRateDialog(userModel);
    });
  }

  void _showStartRateDialog(UserModel userModel) {
    final rateMyApp = userModel.rateMyApp;

    if (rateMyApp.shouldOpenDialog) {
      rateMyApp.showStarRateDialog(
        context,
        title: Locales.of(context).get('rate_my_app_title'),
        message: Locales.of(context).get('rate_my_app_message'),
        actionsBuilder: (context, stars) {
          stars = stars ?? 0;

          return [
            TextButton(
              child: const Text(
                "OK",
              ),
              onPressed: () async => _onSubmitRate(context, rateMyApp, stars),
            ),
          ];
        },
        ignoreNativeDialog: true,
        dialogStyle: const DialogStyle(
          titleAlign: TextAlign.center,
          messageAlign: TextAlign.center,
          messagePadding: EdgeInsets.only(bottom: 20),
        ),
        onDismissed: () async => _onCancelRate(rateMyApp),
      );

      AppMetrica.reportEvent('showRateDialog');
      if (statisticOn) FirebaseAnalyticaService.reportEvent('showRateDialog');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ColorHelper.primaryBackgroundColor,
          drawer: DesignHelper.createDrawer(context),
          body: Consumer<UserModel>(
            builder: (context, model, child) => Column(
              children: [
                if (!model.subscriptionStatus) AdBanner(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                MapScreen(context),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                HomePagePanel(context),
                // FreeConnect(),
                QuickConnect(),
                Spacer(),
                sendProblem(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sendProblem() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              _sendSupportMail('connection_problems'.localize(context));
            },
            child: LocaleText(
              'connection_problems',
              style: StylesHelper.getRubicStyleWithParams(
                color: Color.fromRGBO(21, 47, 130, 1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     _sendSupportMail('lets_us_know'.localize(context));
          //   },
          //   child: LocaleText(
          //     'lets_us_know',
          //     style: StylesHelper.getRubicStyleWithParams(
          //       color: Color.fromRGBO(21, 47, 130, 1),
          //       fontSize: 14,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  static Future<void> _sendSupportMail(String subject) async {
    try {
      const String GMAIL_SCHEMA = 'com.google.android.gm';
      final bool isGmailInstalled =
          await AboutAndroid.isInstalledApplication(GMAIL_SCHEMA);
      if (isGmailInstalled) {
        final MailOptions mailOptions = MailOptions(
          body: '',
          subject: subject,
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

  Future<void> _onSubmitRate(
    BuildContext context,
    RateMyApp rateMyApp,
    double stars,
  ) async {
    print(
        "Rete my app: user has rated application as ${stars.round()} star(s).");

    if (stars == 0) {
      await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);

      Navigator.pop<RateMyAppDialogButton>(
        context,
        RateMyAppDialogButton.rate,
      );
    } else if (stars <= 3) {
      print("Rete my app: show dialog for user to leave a feedback.");

      final showDialogResult = await DialogHelper.showDialog<bool>(
          context, () => RateCommentDialog());

      if (showDialogResult) {
        rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);

        Navigator.pop<RateMyAppDialogButton>(
          context,
          RateMyAppDialogButton.rate,
        );
      }
    } else {
      print("Rete my app: show native review dialog and launch store.");

      await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);

      Navigator.pop<RateMyAppDialogButton>(
        context,
        RateMyAppDialogButton.rate,
      );

      if ((await rateMyApp.isNativeReviewDialogSupported) ?? false) {
        await rateMyApp.launchNativeReviewDialog();
      }

      final launchStoreResult = await rateMyApp.launchStore();

      if (launchStoreResult != LaunchStoreResult.errorOccurred) {
        if (stars == 5) {
          AppMetrica.reportEvent('rate_5');
          if (statisticOn) FirebaseAnalyticaService.reportEvent('rate_5');
        }
        AppMetrica.reportEvent('redirectToGooglePlay');
        if (statisticOn)
          FirebaseAnalyticaService.reportEvent('redirectToGooglePlay');
      }
    }
  }

  Future<void> _onCancelRate(RateMyApp rateMyApp) =>
      rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
}
