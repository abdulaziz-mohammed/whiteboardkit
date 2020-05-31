import 'package:flutter/material.dart';
import 'package:whiteboardkit/whiteboard.dart';
import 'package:whiteboardkit/whiteboard_draw.dart';
import 'static_sketch_controller.dart';
import 'whiteboard_style.dart';

class StaticSketch extends StatefulWidget {
  final WhiteboardDraw draw;
  final WhiteboardStyle style;

  StaticSketch({@required this.draw, this.style = const WhiteboardStyle()});

  @override
  State<StaticSketch> createState() => StaticSketchState();
}

class StaticSketchState extends State<StaticSketch>
    with TickerProviderStateMixin {
  StaticSketchController controller;

  @override
  void initState() {
    super.initState();
    controller = new StaticSketchController(widget.draw);
  }

  @override
  void didUpdateWidget(StaticSketch oldWidget) {
    if (widget.draw != oldWidget.draw) {
      controller?.close();
      controller = new StaticSketchController(widget.draw);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Whiteboard(
      controller: controller,
    );
  }

  @override
  void dispose() {
    controller?.close();
    super.dispose();
  }
}
