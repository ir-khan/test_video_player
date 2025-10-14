import 'package:flutter/material.dart';

mixin MediaQueryMixin<T extends StatefulWidget> on State<T> {
  late Size size;
  late Orientation orientation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.sizeOf(context);
    orientation = MediaQuery.orientationOf(context);
  }
}
