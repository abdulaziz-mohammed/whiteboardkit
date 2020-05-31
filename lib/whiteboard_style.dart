import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WhiteboardStyle {
  final Border border;
  final Color toolboxColor;

  const WhiteboardStyle({this.border = const Border.fromBorderSide(BorderSide(width: 1.0, color: Colors.transparent)), this.toolboxColor = Colors.black38});
}
