import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whiteboardkit/draw_animator.dart';
import 'package:whiteboardkit/whiteboard_controller.dart';

import 'whiteboard_draw.dart';

class PlaybackController extends WhiteboardController
    implements PlayControls {
  final completeController = StreamController<WhiteboardDraw>.broadcast();
  DrawAnimator animator;
  WhiteboardDraw replayDraw;

  PlaybackController({@required WhiteboardDraw draw})
      : super(readonly: true) {
    this.draw = draw.copyWith(lines: []);
    _init();
    replayDraw = draw;
    animator.loadDraw(replayDraw);
  }

  @override
  initializeSize(double width, double height) {
    super.initializeSize(width, height);

    animator.updateSize(width, height);
  }

  Stream<WhiteboardDraw> onComplete() {
    return completeController.stream;
  }

  @override
  close() {
    completeController?.close();
    animator?.close();
    super.close();
  }

  play() async {
    animator.loadDraw(replayDraw);
  }

  _init() {
    animator?.close();
    animator = new DrawAnimator(
        width: draw.width,
        height: draw.height,
        onChange: (draw) {
          this.draw = draw;
          streamController.sink.add(draw);
        },
        onComplete: () => completeController.sink.add(this.draw.clone()));
  }

  skip() => animator.skip();
}
