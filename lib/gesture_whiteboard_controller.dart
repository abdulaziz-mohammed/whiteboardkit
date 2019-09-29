import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'whiteboard_draw.dart';
import 'whiteboard_controller.dart';

class GestureWhiteboardController extends WhiteboardController {
  final _streamController = StreamController<WhiteboardDraw>.broadcast();

  bool _newLine = true;
  DateTime lastPan;
  DateTime lastLine;

  double brushSize = 20.0;
  Color brushColor = Colors.blue;
  bool erase = false;
  double eraserSize = 20.0;

  GestureWhiteboardController({WhiteboardDraw draw}) {
    if(draw != null) {
      this.draw = draw.clone();
      _streamController.sink.add(this.draw);
    }
  }

  @override
  Stream<WhiteboardDraw> onChange() {
    return _streamController.stream;
  }

  close() {
    return _streamController.close();
  }

  onPanUpdate(Offset position) {
    if (this.draw == null) return;

    if (_newLine) {
      this.draw.lines.add(new Line(
            points: [],
            color: erase ? Colors.white : brushColor,
            width: erase ? eraserSize : brushSize,
          ));
      _newLine = false;
      lastLine = DateTime.now();
    }

    if (this.draw.lines.last.points.length > 2 &&
        lastPan != null &&
        (lastPan.millisecond - DateTime.now().millisecond) < 100) {
      var a1 = position.dx - this.draw.lines.last.points.last.x;
      var a2 = position.dy - this.draw.lines.last.points.last.y;
      var a3 = sqrt(pow(a1, 2) + pow(a2, 2));

      if (a3 < 5) return;
    }

    if (this.draw.lines.last.points.length == 0 ||
        position != this.draw.lines.last.points?.last.toOffset()) {
      this.draw.lines.last.points = new List.from(this.draw.lines.last.points)
        ..add(Point.fromOffset(position));
      lastPan = DateTime.now();
    }
    _streamController.sink.add(this.draw);
  }

  onPanEnd() {
    _newLine = true;
    this.draw.lines.last.duration =
        DateTime.now().difference(lastLine).inMilliseconds;

    if (this.draw.lines.length > 0 && this.draw.lines.last.points.length == 1) {
      var secondPoint = new Offset(this.draw.lines.last.points.last.x + 1,
          this.draw.lines.last.points.last.y + 1);
      this.draw.lines.last.points.add(Point.fromOffset(secondPoint));
      _streamController.sink.add(this.draw);
    }
    if (this.draw.lines.length > 0 && this.draw.lines.last.points.length == 0) {
      this.draw.lines.removeLast();
    }
  }

  undo() {
    if (this.draw.lines.length > 0) this.draw.lines.removeLast();
    _streamController.sink.add(this.draw);
  }

  wipe() {
    this.draw.lines.add(new Line(points: [], wipe: true));
    _streamController.sink.add(this.draw);
  }
}
