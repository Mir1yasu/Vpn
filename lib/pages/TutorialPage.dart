import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mandarinvpn/helpers/ColorHelper.dart';
import 'package:mandarinvpn/helpers/ImageHelper.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';

class TutorialPage extends StatefulWidget {
  _TutorialPage createState() => _TutorialPage();
}

class _TutorialPage extends State<TutorialPage> {
  int step = 1;
  getText(value) {
    switch (value) {
      case 1:
        return 'Open Safari Settings at the\nSystem Settings screen';
      case 2:
        return 'Go to the Content Blockers';
      case 3:
        return 'Enable Mandarin VPN \n as a content blocker';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Container(
          color: ColorHelper.primaryBackColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 50,
              ),
              Container(
                height: 57,
                color: ColorHelper.primaryTextColor,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 17),
                      child: IconButton(
                        onPressed: () => null,
                        icon: Icon(
                          Icons.clear,
                          color: ColorHelper.secondaryBackColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 43),
                      child: Text('Adblock Setup Tutorial',
                          style: StylesHelper.getRubicStyleWithParams(
                            color: Color(0xffFAFAFA),
                            fontSize: 16,
                          )),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 33,
                  bottom: 33,
                ),
                child: Center(
                  child: Image(
                    image: ImageHelper.raster['screen$step'],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                ),
                child: Text(
                  'STEP $step',
                  textAlign: TextAlign.left,
                  style: StylesHelper.getRubicStyleWithParams(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 11,
                  left: 16,
                ),
                child: Text(
                  getText(step),
                  style: StylesHelper.getRubicStyleWithParams(
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment(0, 1),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ImageHelper.vector['stepPoint$step'],
                  ),
                ),
              ),
              Expanded(
                child: Align(
                    alignment: Alignment(0, 1),
                    child: Container(
                      padding: EdgeInsets.only(bottom: 32),
                      width: 260,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            color: ColorHelper.blueColor),
                        child: CupertinoButton(
                          padding: EdgeInsets.only(left: 19, right: 19),
                          onPressed: () {
                            if (step < 3) {
                              setState(() {
                                step++;
                              });
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            height: 50,
                            child: Center(
                              child: Text(
                                step != 3 ? 'NEXT' : 'DONE',
                                style: StylesHelper.getRubicStyleWithParams(
                                    color: ColorHelper.secondaryBackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
