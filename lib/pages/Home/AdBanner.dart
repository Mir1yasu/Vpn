import 'package:flutter/widgets.dart';
import 'package:mandarinvpn/helpers/ColorHelper.dart';
import 'package:mandarinvpn/services/AppodealService.dart';

class AdBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: ColorHelper.secondaryBackColor,
      child: BannerWidget(),
    );
  }
}
