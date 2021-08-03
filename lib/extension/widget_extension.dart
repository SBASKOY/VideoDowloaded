import 'package:flutter/cupertino.dart';

extension WidgetExtansion on Widget {
  Widget paddingAll([double? val]) => Padding(
        padding: EdgeInsets.all(val ?? 8),
        child: this,
      );
  Widget paddingOnly({double? top, double? bottom,double? left,double? right}) => Padding(
        padding: EdgeInsets.only(
          bottom: bottom??0,
          left: left??0,
          right: right??0,
          top: top??0
        ),
        child: this,
      );
}
