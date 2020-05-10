import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:whiteboardkit/whiteboard_controller.dart';

import 'whiteboard_draw.dart';

class AnimatedSketchController extends WhiteboardController {
  DrawGenerator generator;

  Size scaledSize;

  AnimatedSketchController(WhiteboardDraw draw) {
    this.draw = draw.clone();
    generator = new DrawGenerator();
  }

  @override
  initializeSize(double height, double width) {
    super.initializeSize(height, width);
    scaledSize = calculateScaledSize(this.draw);

    generator.play(draw);
  }

  @override
  Stream<WhiteboardDraw> onChange() {
    return generator.streamController.stream;
  }

  Stream<bool> onComplete() {
    return generator.streamCompleteController.stream;
  }

  close() {
    generator.close();
  }

  onPanUpdate(Offset position) {}

  onPanEnd() {}

  play() async {
    generator.play(draw);
  }

  skip() => generator.skip();

  @override
  Size getSize() => scaledSize;

  Size calculateScaledSize(WhiteboardDraw draw) {
    var scaleX = this.width / draw.width; // 0.5
    var scaleY = this.height / draw.height; // 1

    var scale = 0.0;

    var height = 0.0;
    var width = 0.0;

    if (scaleX < scaleY) {
      scale = scaleX;
      height = this.height * scale;
      width = this.width;
    } else {
      scale = scaleY;
      height = this.height;
      width = this.width * scale;
    }

    return new Size(width, height);
  }
}

class DrawGenerator {
  final streamController = StreamController<WhiteboardDraw>.broadcast();
  final streamCompleteController = StreamController<bool>.broadcast();

  final cancel = false;
  bool _skip = false;

  skip() => _skip = true;

  bool _closed = false;

  bool _firstTimePlay = true;

  play(WhiteboardDraw draw) {
    Future(() async {
      _skip = false;
      var currentDraw =
          new WhiteboardDraw(lines: [], width: draw.width, height: draw.height);

      if (_firstTimePlay)
        await Future.delayed(Duration(
          seconds: 1,
        ));
      _firstTimePlay = false;

      for (var line in draw.lines) {
        currentDraw.lines.add(line.copyWith(points: []));
        for (var point in line.points) {
          var duration = line.duration ~/ line.points.length;
          if (cancel) _skip = true;
          await Future.delayed(Duration(milliseconds: duration));
          if (_closed) return true;
          currentDraw.lines.last.points.add(point);
          streamController.sink.add((currentDraw));

          if (_skip) break;
        }
        if (_skip) {
          streamController.sink.add((draw));
          break;
        }
      }
      if (cancel == false) streamCompleteController.sink.add(true);
    });
  }

  close() {
    streamController?.close();
    streamCompleteController?.close();
    _closed = true;
  }
}
