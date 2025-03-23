import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mandarinvpn/helpers/ColorHelper.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';

class SubscriptionElement extends StatelessWidget {
  final String title;
  final String description;
  final String youSave;
  final bool isModified;
  final String oldPrice;

  const SubscriptionElement({
    Key key,
    this.title = '',
    this.description = '',
    this.oldPrice,
    this.youSave = '',
    this.isModified = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 144,
          alignment: Alignment.center,
          child: Container(
            width: 296,
            height: 181,
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: <Color>[
                  Color.fromRGBO(63, 177, 238, 1),
                  Color.fromRGBO(21, 136, 198, 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isModified ? ColorHelper.primaryBackgroundColor : null,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isModified
                      ? Colors.white.withOpacity(0.25)
                      : ColorHelper.primaryBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AutoSizeText(
                      title,
                      style: StylesHelper.getRubicStyleWithParams(
                        color: Color.fromRGBO(21, 47, 130, 1),
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                      maxFontSize: 40,
                      minFontSize: 20,
                      maxLines: 1,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      text: TextSpan(
                        children: [
                          if (oldPrice != null && oldPrice.isNotEmpty)
                            TextSpan(
                              text: oldPrice,
                              style: StylesHelper.getRubicStyleWithParams(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ).copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          TextSpan(
                            text: ' $description',
                            style: StylesHelper.getRubicStyleWithParams(
                              color: Color.fromRGBO(21, 47, 130, 1),
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (youSave != '')
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 68,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Color.fromRGBO(250, 180, 6, 1),
                    Color.fromRGBO(255, 127, 3, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                youSave,
                style: StylesHelper.getRubicStyleWithParams(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
