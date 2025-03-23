import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/pages/Home/PremiumPage.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  final BuildContext scaffoldContext;
  MapScreen(this.scaffoldContext);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) => Material(
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width * .92,
            height: MediaQuery.of(context).size.height * 0.32,
            color: Colors.white,
            //   child: Container(
            //     color: Colors.white,
            // //     padding: EdgeInsets.only(top: 10),
            // Container(
            //               color: Colors.red,
            //               width: deviceWidth(context) * 0.15,
            //               height: deviceHeight(context) * 0.037,
            //               child: Align(
            //                 alignment: Alignment.topLeft,
            //                 child: SvgPicture.asset(
            //                   "assets/images/vectors/settings.svg",
            //                   width: MediaQuery.of(context).size.width * .05,
            //                   height:
            //                       MediaQuery.of(context).size.height * 0.025,
            //                   color: Color.fromRGBO(21, 47, 130, 1),
            //                 ),
            //               ),
            //             ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Container(
                        color: Colors.white,
                        width: deviceWidth(context) * 0.13,
                        height: deviceHeight(context) * 0.041,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SvgPicture.asset(
                            "assets/images/vectors/settings.svg",
                            width: MediaQuery.of(context).size.width * .05,
                            height: MediaQuery.of(context).size.height * 0.025,
                            color: Color.fromRGBO(21, 47, 130, 1),
                          ),
                        ),
                      ),
                      onTap: () {
                        AppMetrica.reportEvent('settingsClick');
                        if (statisticOn)
                          FirebaseAnalyticaService.reportEvent('settingsClick');

                        Scaffold.of(widget.scaffoldContext).openDrawer();
                      },
                    ),
                    Text(
                      'Mandarin VPN',
                      style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    GestureDetector(
                      child: Container(
                        color: Colors.white,
                        width: deviceWidth(context) * 0.13,
                        height: deviceHeight(context) * 0.041,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SvgPicture.asset(
                            "assets/images/vectors/crown_icon.svg",
                            width: MediaQuery.of(context).size.width * .05,
                            height: MediaQuery.of(context).size.height * 0.025,
                            color: Color.fromRGBO(255, 185, 1, 1),
                          ),
                        ),
                      ),
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.transparent,
                        builder: (context) => PremiumPage(),
                      ),
                    ),
                  ],
                ),
                // if (!model.subscriptionStatus)
                //   // MainAxisAlignment.end
                //   GestureDetector(
                //     child: SvgPicture.asset(
                //       "assets/images/vectors/crown_icon.svg",
                //       width: 20,
                //       height: 16,
                //       color: Color.fromRGBO(255, 185, 1, 1),
                //     ),
                //     onTap: () => showModalBottomSheet(
                //       context: context,
                //       isScrollControlled: true,
                //       builder: (context) => PremiumPage(),
                //     ),
                //   ),
                // Expanded(
                //   child: Container(
                //     height: MediaQuery.of(context).size.height,
                //     alignment: Alignment.bottomCenter,
                //     padding: const EdgeInsets.only(bottom: 40),
                //     child: GestureDetector(
                //       onTap: () => showModalBottomSheet(
                //         context: context,
                //         isScrollControlled: true,
                //         builder: (context) => PremiumPage(),
                //       ),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         children: <Widget>[
                //           Image(image: ImageHelper.raster['crown_icon']),
                //           SizedBox(
                //             width: 8,
                //           ),
                // LocaleText(
                //   'premium_title',
                //   style: StylesHelper.getRubicStyleWithParams(
                //     color: Colors.white,
                //     fontSize: 14,
                //     fontWeight: FontWeight.w500,
                //   ),
                // )
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                if (model.preferableServer == 'Canada' &&
                    model.getAndroidStatus != 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_canada_off.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                if (model.preferableServer == 'United States' &&
                    model.getAndroidStatus != 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_unites_state_off.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                if (model.preferableServer == 'Russia' &&
                    model.getAndroidStatus != 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_russia_off.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                if (model.preferableServer == 'France' &&
                    model.getAndroidStatus != 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_france_off.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                if (model.preferableServer == 'Germany' &&
                    model.getAndroidStatus != 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_germany_off.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                if (model.preferableServer == 'Poland' &&
                    model.getAndroidStatus != 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_poland_off.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                //Connected
                if (model.preferableServer == 'Canada' &&
                    model.getAndroidStatus == 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_canada_on.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                if (model.preferableServer == 'United States' &&
                    model.getAndroidStatus == 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_unites_state_on.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                if (model.preferableServer == 'Russia' &&
                    model.getAndroidStatus == 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_russia_on.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                if (model.preferableServer == 'France' &&
                    model.getAndroidStatus == 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_france_on.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                if (model.preferableServer == 'Germany' &&
                    model.getAndroidStatus == 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_germany_on.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                if (model.preferableServer == 'Poland' &&
                    model.getAndroidStatus == 'CONNECTED')
                  SvgPicture.asset(
                    "assets/images/vectors/coutry_map/map_poland_on.svg",
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    //     ),
    //   ),
    // );
  }
}
