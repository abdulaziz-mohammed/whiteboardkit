import 'dart:async';
import 'package:whiteboardkit/whiteboard_controller.dart';

import 'whiteboard_draw.dart';

class StaticSketchController extends WhiteboardController {

  StaticSketchController(WhiteboardDraw draw) : super(readonly: true) {
    if (draw.lines.lastIndexWhere((element) => element.wipe == true) != -1)
      this.draw = draw.clone().copyWith(
          lines: draw.lines.skip(
              draw.lines.lastIndexWhere((element) => element.wipe == true)));
    else
      this.draw = draw.clone();
  }

  @override
  initializeSize(double width, double height) {
    super.initializeSize(width, height);

    Future.delayed(Duration(milliseconds: 0), () {
      streamController.sink.add(this.draw);
    });
  }
}
