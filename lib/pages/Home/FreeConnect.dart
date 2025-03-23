import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:provider/provider.dart';

class FreeConnect extends StatelessWidget {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) => Container(
        margin: EdgeInsets.only(top: deviceHeight(context) * 0.04),
        padding: EdgeInsets.symmetric(horizontal: deviceWidth(context) * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                String value = model.vpnServers
                    .firstWhere((e) => e.isFree == true)
                    .displayName;
                if (value == null) value = model.vpnServers.first.displayName;
                model.preferableServer = value;
                model.onCountrySelect(value);
                model.updateState();
                model.connect(value);
              },
              child: Container(
                width: deviceWidth(context) * .92,
                height: deviceHeight(context) * 0.09,
                padding: EdgeInsets.symmetric(
                    horizontal: deviceWidth(context) * 0.025),
                alignment: Alignment.center,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: deviceWidth(context) * .1,
                      height: deviceHeight(context) * 0.05,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        // color: Color.fromRGBO(125, 54, 217, 1),
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: SvgPicture.asset(
                        "assets/images/vectors/free_location.svg",
                        width: deviceWidth(context) * .1,
                        height: deviceHeight(context) * 0.05,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: deviceWidth(context) * .04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 170,
                              child: AutoSizeText(
                                Locales.of(context).get('free_location_text') ??
                                    ' ',
                                textAlign: TextAlign.left,
                                style: StylesHelper.getRubicStyleWithParams(
                                  color: Color.fromRGBO(21, 47, 130, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxFontSize: 16,
                                minFontSize: 12,
                                maxLines: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: deviceHeight(context) * 0.0065),
                            ),
                            SizedBox(
                              width: 100,
                              child: AutoSizeText(
                                Locales.of(context).get('free_server_text') ??
                                    ' ',
                                textAlign: TextAlign.left,
                                style: StylesHelper.getRubicStyleWithParams(
                                    color: Color.fromRGBO(21, 47, 130, 1),
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12),
                                maxFontSize: 12,
                                minFontSize: 8,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: deviceWidth(context) * .1,
                      height: deviceHeight(context) * 0.05,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Color.fromRGBO(21, 47, 130, 1),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
