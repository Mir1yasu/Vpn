import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mandarinvpn/helpers/ImageHelper.dart';
import 'package:mandarinvpn/helpers/StylesHelper.dart';
import 'package:mandarinvpn/models/UserModel.dart';
import 'package:provider/provider.dart';

class HomePagePanel extends StatefulWidget {
  final BuildContext scaffoldContext;
  HomePagePanel(this.scaffoldContext);

  @override
  _HomePagePanelState createState() => _HomePagePanelState();
}

class _HomePagePanelState extends State<HomePagePanel> {
  int currentPage = 0;
  CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    var model = context.read<UserModel>();
    model.addListener(() async {
      var page = model.getAllCountryNames().indexOf(model.preferableServer);
      await Future.delayed(Duration(milliseconds: 100));
      if (currentPage != page) {
        onPageChanged(page);
        moveToSelectedCountry(page);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) {
        int indexCountry = 0;
        try {
          indexCountry =
              model.getAllCountryNames().indexOf(model.preferableServer);
        } catch (e) {
          indexCountry = 0;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
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
          width: (MediaQuery.of(context).size.width * .92).roundToDouble(),
          height: (MediaQuery.of(context).size.height * 0.145).roundToDouble(),
          child: Container(
            height:
                (MediaQuery.of(context).size.height * 0.122).roundToDouble(),
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overscroll) {
                overscroll.disallowIndicator();
                return;
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015,
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: CarouselSlider.builder(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          initialPage: indexCountry,
                          enableInfiniteScroll: true,
                          enlargeCenterPage: true,
                          reverse: true,
                          viewportFraction: .2,
                          enlargeStrategy: CenterPageEnlargeStrategy.height,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (page, t) {
                            if (model.getAndroidStatus != 'DISCONNECTED') {
                              model.disconnect();
                            }
                            onPageChanged(page);
                            try {
                              model.preferableServer = page >= 0 &&
                                      page < model.getAllCountryNames().length
                                  ? model.getAllCountryNames()[page]
                                  : '';
                            } catch (e) {
                              model.preferableServer = '';
                            }
                          },
                        ),
                        itemCount: model.getAllCountryNames().length,
                        itemBuilder: (context, index, _) {
                          return CountryElement(
                            isSelected: indexCountry == index,
                            countryName: index >= 0 &&
                                    index < model.getAllCountryNames().length
                                ? model.getAllCountryNames()[index]
                                : '',
                            onPressed: () => moveToSelectedCountry(index),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      bottom: MediaQuery.of(context).size.height * 0.015,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!model.subscriptionStatus &&
                            model.preferableServer != 'Canada')
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Image(
                              image: ImageHelper.raster['crown_icon'],
                              height: 13,
                            ),
                          ),
                        LocaleText(
                          model.preferableServer
                              .toString()
                              .toLowerCase()
                              .trim()
                              .replaceAll(' ', ''),
                          style: StylesHelper.getRubicStyleWithParams(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(21, 47, 130, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void onPageChanged(int page) {
    currentPage = page;
    setState(() {});
  }

  void moveToSelectedCountry(int page) {
    _carouselController.animateToPage(
      page,
      duration: Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }
}

class CountryElement extends StatelessWidget {
  CountryElement({
    this.countryName,
    this.onPressed,
    this.isSelected,
  });

  final String countryName;
  final void Function() onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final countryAssetName =
        'assets/images/vectors/coutry_map/${countryName.toLowerCase()}.svg';

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: (MediaQuery.of(context).size.width * 0.15).roundToDouble(),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Color.fromRGBO(57, 83, 164, 1),
                  width: 3,
                )
              : null,
        ),
        child: SvgPicture.asset(
          countryAssetName,
        ),
      ),
    );
  }
}
