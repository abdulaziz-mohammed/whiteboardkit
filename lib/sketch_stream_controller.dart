import 'dart:async';

import 'package:whiteboardkit/whiteboard_controller.dart';

import 'draw_chunk.dart';
import 'draw_chunk_animator.dart';
import 'whiteboard_draw.dart';

class SketchStreamController extends WhiteboardController {
  final completeController = StreamController<bool>.broadcast();

  DrawChunkAnimator animator;

  SketchStreamController() : super(readonly: true) {
    _init();
  }

  @override
  initializeSize(double width, double height) {
    if (this.draw == null)
      this.draw = WhiteboardDraw.empty(width: width, height: height);

    super.initializeSize(width, height);

    animator?.updateSize(width, height);
  }

  Stream<bool> onComplete() {
    return completeController.stream;
  }

  @override
  close() {
    completeController?.close();
    animator?.close();
    super.close();
  }

  _init() {
    animator?.close();
    animator = new DrawChunkAnimator(
        onChange: (draw) {
          this.draw = draw;
          streamController.sink.add(draw);
        },
        onComplete: () => completeController.sink.add(true));
  }

  void addChunk(DrawChunk drawChunk) {
    if (drawChunk.id == 0) {
      // animator?.updateSize(availbleSize.width, availbleSize.height);
      this.draw = WhiteboardDraw.empty(
          width: drawChunk.draw.width, height: drawChunk.draw.height);
      // animator?.close();
      // animator = null;

      // Future.delayed(Duration(seconds: 5),(){
      sizeChangedController.sink.add(this.draw.getSize());
      // });
    } else {}
    animator?.addChunk(drawChunk);
    // if (drawChunk.id == 0) {
    //   initializeSize(availbleSize.width, availbleSize.height);
    // }
  }

  skip() => animator.skip();
}
