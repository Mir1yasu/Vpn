import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/main.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/services/FirebaseAnalytics.dart';
import 'package:provider/provider.dart';

class CustomExpansionPanel extends StatefulWidget {
  final List<Widget> cities;
  final String countryName;

  const CustomExpansionPanel(
      {Key key, this.countryName = 'Canada', this.cities})
      : super(key: key);

  @override
  _CustomExpansionPanelState createState() =>
      _CustomExpansionPanelState(countryName, cities);
}

class _CustomExpansionPanelState extends State<CustomExpansionPanel>
    with TickerProviderStateMixin {
  bool _expanded = false;

  AnimationController slideAnimationController;
  Animation<double> slideDownAnimation;

  final String countryName;
  final List<Widget> cities;
  String countryFlag;
  int citiesCount;

  _CustomExpansionPanelState(this.countryName, this.cities) {
    if (cities == null || cities.length == 0) {
      citiesCount = 1;
      return;
    }

    citiesCount = cities.length;
  }

  @override
  void initState() {
    countryFlag = countryName.replaceAll(new RegExp(' '), '').toLowerCase();
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  void prepareAnimations() {
    slideAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    slideDownAnimation = CurvedAnimation(
      parent: slideAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (_expanded) {
      slideAnimationController.forward();
    } else {
      slideAnimationController.reverse();
    }
  }

  @override
  void didUpdateWidget(CustomExpansionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) => GestureDetector(
        onTap: () async {
          AppMetrica.reportEvent('choseCountry$countryName');
          if (statisticOn)
            FirebaseAnalyticaService.reportEvent('choseCountry$countryName');

          model.preferableServer = countryName;
          model.onCountrySelect(countryName);
          model.updateState();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: 330,
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 15),
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
            children: <Widget>[
              SvgPicture.asset(
                'assets/images/vectors/coutry_map/${countryName.toLowerCase().replaceAll('', '')}.svg',
                width: 36,
                height: 36,
                fit: BoxFit.fill,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        Locales.string(
                            context,
                            countryName
                                .toLowerCase()
                                .trim()
                                .replaceAll(' ', '')),
                        textAlign: TextAlign.left,
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        Locales.of(context).get('single_location_text') ?? ' ',
                        textAlign: TextAlign.left,
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 11),
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: countryName == model.preferableServer
                            ? null
                            : Color.fromRGBO(144, 210, 245, 1).withOpacity(0.3),
                        gradient: countryName == model.preferableServer
                            ? LinearGradient(
                                colors: <Color>[
                                  Color.fromRGBO(57, 83, 164, 1),
                                  Color.fromRGBO(21, 47, 130, 1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: countryName == model.preferableServer
                          ? SvgPicture.asset(
                              'assets/images/vectors/checkmark.svg',
                              width: 12,
                              height: 10,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    slideAnimationController.dispose();
    super.dispose();
  }
}
