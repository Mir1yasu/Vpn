import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mandarinvpn/helpers/ColorHelper.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/models/AboutAndroid.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProxyPage extends StatefulWidget {
  const ProxyPage({Key key}) : super(key: key);

  @override
  _ProxyPageState createState() => _ProxyPageState();
}

class _ProxyPageState extends State<ProxyPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: ColorHelper.primaryBackgroundColor,
          // shadowColor: Colors.transparent,
          title: AutoSizeText(
            Locales.of(context).get('telegram_proxy_text') ?? ' ',
            style: StylesHelper.getRubicStyleWithParams(
              color: Color.fromRGBO(21, 47, 130, 1),
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back,
              color: Color.fromRGBO(21, 47, 130, 1),
              size: 24,
            ),
          ),
          actions: <Widget>[
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, anim, anim1) => ProxyFAQPage(),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 15),
                  width: 54,
                  height: 24,
                  alignment: Alignment.center,
                  child: Text(
                    'FAQ',
                    style: StylesHelper.getRubicStyleWithParams(
                      color: Color.fromRGBO(21, 47, 130, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return;
          },
          child: Container(
            color: ColorHelper.primaryBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('proxy')
                  .doc('telegram')
                  .snapshots(),
              builder: (context, snapshots) => snapshots.hasError ||
                      !snapshots.hasData ||
                      snapshots.data['servers'] == null ||
                      snapshots.data['servers'].length == 0
                  ? Center(
                      child: LocaleText(
                        'no_servers_available',
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: snapshots.data['servers'].length,
                      itemBuilder: (context, index) => ProxyCard(
                        host: snapshots.data['servers'][index]['host'],
                        port: snapshots.data['servers'][index]['port'],
                        keyValue: snapshots.data['servers'][index]['key'],
                        link: snapshots.data['servers'][index]['link'],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProxyCard extends StatelessWidget {
  final host;
  final port;
  final keyValue;
  final link;
  ProxyCard(
      {this.host = '', this.port = '', this.keyValue = '', this.link = ''});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: 330,
        height: 150,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color.fromRGBO(108, 159, 185, 0.25),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${Locales.of(context).get('telegram_host')}: ',
                  style: StylesHelper.getRubicStyleWithParams(
                      color: Color.fromRGBO(21, 47, 130, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  host,
                  style: StylesHelper.getRubicStyleWithParams(
                      color: Color.fromRGBO(21, 47, 130, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                )
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${Locales.of(context).get('telegram_port')}: ',
                  style: StylesHelper.getRubicStyleWithParams(
                      color: Color.fromRGBO(21, 47, 130, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  port,
                  style: StylesHelper.getRubicStyleWithParams(
                      color: Color.fromRGBO(21, 47, 130, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                )
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${Locales.of(context).get('telegram_key')}: ',
                  style: StylesHelper.getRubicStyleWithParams(
                      color: Color.fromRGBO(21, 47, 130, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  keyValue,
                  style: StylesHelper.getRubicStyleWithParams(
                      color: Color.fromRGBO(21, 47, 130, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                )
              ],
            ),
            GestureDetector(
              onTap: () async => await onConnectButtonClick(link),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: 188,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
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
                  child: LocaleText(
                    'telegram_connect',
                    style: StylesHelper.getRubicStyleWithParams(
                      color: Colors.white,
                      fontSize: 14,
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

  Future<void> onConnectButtonClick(String link) async {
    {
      try {
        if (!(await AboutAndroid.isInstalledApplication(
            'org.telegram.messenger'))) {
          if (await canLaunch("http://surl.li/agggv"))
            await launch("http://surl.li/agggv");
        } else {
          if (await canLaunch(link)) await launch(link);
        }
      } on SocketException catch (e) {
        print(e.message);
      }
    }
  }
}

class ProxyFAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: ColorHelper.primaryBackgroundColor,
          shadowColor: Colors.transparent,
          title: Text(
            'FAQ',
            style: StylesHelper.getRubicStyleWithParams(
              color: Color.fromRGBO(21, 47, 130, 1),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back,
              color: Color.fromRGBO(21, 47, 130, 1),
              size: 24,
            ),
          ),
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return;
          },
          child: Container(
            color: ColorHelper.primaryBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('proxy')
                  .doc('telegram')
                  .snapshots(),
              builder: (context, snapshots) => FAQ(snapshots: snapshots),
            ),
          ),
        ),
      ),
    );
  }
}

class ProxyBotLink extends StatelessWidget {
  final link;
  final name;
  ProxyBotLink({this.link = '', this.name = ''});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => await onProxyBotLinkTap(link),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  // color: Color.fromRGBO(144, 210, 245, 1),
                  shape: BoxShape.circle),
              child: SvgPicture.asset(
                "assets/images/vectors/telegram.svg",
              ),
            ),
            Text(
              name,
              style: StylesHelper.getRubicStyleWithParams(
                color: Color.fromRGBO(21, 47, 130, 1),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onProxyBotLinkTap(String link) async {
    try {
      if (!(await AboutAndroid.isInstalledApplication(
          'org.telegram.messenger'))) {
        if (await canLaunch("http://surl.li/agggv"))
          await launch("http://surl.li/agggv");
      } else {
        if (await canLaunch(link)) await launch(link);
      }
    } on SocketException catch (e) {
      print(e.message);
    }
  }
}

class FAQ extends StatelessWidget {
  final snapshots;
  FAQ({this.snapshots});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 27,
        ),
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: Locales.of(context).get('faq_title') ?? ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: Locales.of(context).get('faq_proxy_title') ?? ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: Locales.of(context).get('faq_proxy_description') ?? ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Center(
          child: Container(
            padding: EdgeInsets.only(left: 15),
            width: 310,
            height: 101,
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        "assets/images/vectors/compucter.svg",
                        width: 50,
                        height: 50,
                      ),
                      Text(
                        Locales.of(context).get('compucter') ?? ' ',
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset("assets/images/vectors/rightq.svg"),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SvgPicture.asset(
                        "assets/images/vectors/server.svg",
                        width: 50,
                        height: 50,
                      ),
                      Text(
                        Locales.of(context).get('servisec'),
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset("assets/images/vectors/leftq.svg"),
                Center(
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        "assets/images/vectors/internet.svg",
                        width: 50,
                        height: 50,
                      ),
                      Text(
                        Locales.of(context).get('internet'),
                        style: StylesHelper.getRubicStyleWithParams(
                          color: Color.fromRGBO(21, 47, 130, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: Locales.of(context).get('faq_proxy_for_telegram_title') ??
                    ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: Locales.string(
                        context, 'faq_proxy_for_telegram_description') ??
                    ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextSpan(
                text: Locales.of(context).get('faq_title') ?? ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: Locales.of(context).get('faq_proxy_types_description') ??
                    ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextSpan(
                text: Locales.string(
                        context, 'faq_proxy_types_description_titles') ??
                    ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: Locales.of(context).get('faq_http') ?? ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: Locales.of(context).get('faq_http_description') ?? ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextSpan(
                text: Locales.of(context).get('faq_socks') ?? ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: Locales.of(context).get('faq_socks_description') ?? ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextSpan(
                text: Locales.of(context).get('faq_mtproto_proxy') ?? ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text:
                    Locales.of(context).get('faq_mtproto_proxy_description') ??
                        ' ',
                style: StylesHelper.getRubicStyleWithParams(
                  color: Color.fromRGBO(21, 47, 130, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              if (!snapshots.hasError &&
                  snapshots.hasData &&
                  snapshots.data != null &&
                  snapshots.data['bots'].length != 0)
                TextSpan(
                  text: Locales.of(context).get('proxy_bots_title') ?? ' ',
                  style: StylesHelper.getRubicStyleWithParams(
                    color: Color.fromRGBO(21, 47, 130, 1),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        if (!snapshots.hasError &&
            snapshots.hasData &&
            snapshots.data != null &&
            snapshots.data['bots'].length != 0)
          for (var index = 0; index < snapshots.data['bots'].length; index++)
            ProxyBotLink(
              link: snapshots.data['bots'][index]['link'],
              name: snapshots.data['bots'][index]['name'],
            ),
      ],
    );
  }
}
