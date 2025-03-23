import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key key,
    @required this.text,
    @required this.onPressed,
    this.width = 300,
    this.height = 48,
    this.padding,
    this.textStyle,
    this.textAlign = TextAlign.center,
    this.decoration,
  }) : super(key: key);

  final String text;
  final void Function() onPressed;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final Decoration decoration;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding,
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: decoration,
        child: Row(
          children: [
            Expanded(
              child: LocaleText(
                text,
                style: textStyle,
                textAlign: textAlign,
              ),
            ),
          ],
        ),
      ),
    );
  }

  factory CustomButton.primaryButton({
    @required String text,
    @required void Function() onPressed,
    TextAlign textAlign = TextAlign.center,
    double width = 300,
    double height = 48,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 5),
      textStyle: StylesHelper.getRubicStyleWithParams(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      textAlign: textAlign,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(63, 177, 238, 1),
            Color.fromRGBO(21, 136, 198, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(108, 159, 185, 0.25),
            blurRadius: 20,
          ),
        ],
      ),
    );
  }

  factory CustomButton.secondaryButton({
    @required String text,
    @required void Function() onPressed,
    TextAlign textAlign = TextAlign.center,
    double width = 300,
    double height = 48,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 5),
      textStyle: StylesHelper.getRubicStyleWithParams(
        color: Color.fromRGBO(21, 136, 198, 1),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      textAlign: textAlign,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Color.fromRGBO(21, 136, 198, 1),
        ),
      ),
    );
  }
}
