import 'package:flutter/cupertino.dart';

class ListBuilder extends StatelessWidget {
  final EdgeInsets padding;
  final Axis scrollDirection;

  final List<dynamic> items;
  final String filter;

  const ListBuilder(
      {Key key,
      this.padding = const EdgeInsets.all(0),
      this.scrollDirection = Axis.vertical,
      this.items,
      this.filter = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      shrinkWrap: true,
      scrollDirection: scrollDirection,
      itemCount: items?.length,
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }
}
