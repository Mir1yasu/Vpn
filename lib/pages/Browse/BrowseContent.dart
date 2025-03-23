import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mandarinvpn/helpers/ColorHelper.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:mandarinvpn/templates/ListBuilder.dart';
import 'package:provider/provider.dart';

class BrowseContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification overscroll) {
                  overscroll.disallowIndicator();
                  return;
                },
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 68,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(21, 47, 130, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 24),
                      child: LocaleText(
                        'all_countries_text',
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListBuilder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        scrollDirection: Axis.vertical,
                        items: model.allCountries,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
