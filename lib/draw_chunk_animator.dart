import 'package:flutter/widgets.dart';
import 'package:whiteboardkit/draw_animator.dart';

import 'draw_chunk.dart';
import 'whiteboard_draw.dart';

typedef FirstChunkAdded = void Function(WhiteboardDraw draw);

class DrawChunkAnimator extends DrawAnimator {
  late List<DrawChunk> _serializedChunks;
  late List<DrawChunk> _bufferChunks;

  bool sizeSet = false;
  Size? availbleSize;

  DrawChunkAnimator(
      {required DrawChanged onChange, required DrawCompleted onComplete})
      : super(
          width: 0,
          height: 0,
          onChange: onChange,
          onComplete: onComplete,
        ) {
    _serializedChunks = [];
    _bufferChunks = [];
  }

  addChunk(DrawChunk drawChunk) async {
    if (drawChunk.id == 0) {
      _serializedChunks.clear();
      finalDraw = WhiteboardDraw.empty(
              width: drawChunk.draw!.width, height: drawChunk.draw!.height)
          .getScaled(availbleSize!.width, availbleSize!.height);
      await pause();
    }

    var lastChunkId =
        _serializedChunks.isNotEmpty ? _serializedChunks.last.id! : -1;

    if (drawChunk.id! <= lastChunkId) return;

    if (_bufferChunks.indexWhere((a) => a.id == drawChunk.id) == -1) {
      _bufferChunks.add(drawChunk);
    }

    _bufferChunks.sort((a, b) => a.id!.compareTo(b.id!));

    for (var bufferedChunk in _bufferChunks) {
      if (bufferedChunk.id == lastChunkId + 1) {
        _serializedChunks.add(bufferedChunk);
        lastChunkId++;
        _loadChunkToQueue(bufferedChunk);
      }
    }

    _bufferChunks.retainWhere((chunk) => chunk.id! > lastChunkId);
  }

  _loadChunkToQueue(DrawChunk drawChunk) async {
    await pause();
    var drawPartial =
        drawChunk.draw!.getScaled(finalDraw.width, finalDraw.height);
    var queuedMilliseconds = queued.fold(
        0,
        (dynamic previousValue, queuedLine) =>
            previousValue + queuedLine.duration);
    if (queuedMilliseconds > 4000) {
      for (var queuedLine in queued) {
        queuedLine.duration = 0;
      }
    }

    if (DateTime.now().difference(drawChunk.createdAt!).inSeconds > 60) {
      for (var line in drawPartial.lines) {
        line.duration = 0;
      }
    }

    addLinesToQueue(drawPartial.lines);
    await play();
  }

  @override
  updateSize(double width, double height) async {
    if (availbleSize == null) {
      availbleSize = Size(width, height);
      return;
    }
    super.updateSize(width, height);
  }
}
