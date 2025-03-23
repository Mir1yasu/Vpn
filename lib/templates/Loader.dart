import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mandarinvpn/helpers/ImageHelper.dart';

class Loader extends StatefulWidget {
  final String loaderImage;

  const Loader({Key key, this.loaderImage = 'loading'}) : super(key: key);

  @override
  _LoaderState createState() => _LoaderState(loaderImage);
}

class _LoaderState extends State<Loader> with TickerProviderStateMixin {
  final String loaderImage;
  AnimationController _animation;

  _LoaderState(this.loaderImage);

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RotationTransition(
        turns: _animation,
        child: ImageHelper.vector[loaderImage],
      ),
    );
  }
}
