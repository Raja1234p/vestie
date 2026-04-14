import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  Widget padding(EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }

  Widget paddingAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Widget center() {
    return Center(
      child: this,
    );
  }

  Widget expand([int flex = 1]) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }
}
