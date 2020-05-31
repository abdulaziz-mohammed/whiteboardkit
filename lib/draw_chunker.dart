import 'package:whiteboardkit/whiteboardkit.dart';

import 'whiteboard_draw.dart';

class DrawChunker {
  final WhiteboardDraw draw;
  DrawChunk lastChunk;

  int durationInMilliseconds;

  DrawChunker(this.draw, this.durationInMilliseconds) : lastChunk = null;

  int _lastLineIndex = -1;
  int _lastLinePointsChunked = 0;
  int _lastLineDurationChunked = 0;

  DrawChunk next() {
    var draw = this.draw.copyWith();

    if (draw == null || draw.lines.length == 0) return null;

    var chunkDraw = draw.copyWith(lines: []);

    //first chunk
    if (lastChunk == null) {
      chunkDraw.lines = draw.lines;
    } else {
      //no lines changes
      if (_lastLineIndex > -1 && draw.lines.length - 1 == _lastLineIndex) {
        //no points changes
        if (_lastLinePointsChunked == draw.lines.last.points.length) {
          return null;
        }
      }

      chunkDraw.lines =
          draw.lines.skip(_lastLineIndex + 1).map((l) => l.clone()).toList();

      //if last line points changed
      if (_lastLinePointsChunked != draw.lines[_lastLineIndex].points.length) {
        Line linePart = draw.lines[_lastLineIndex].clone();
        linePart.points =
            linePart.points.skip(_lastLinePointsChunked - 1).toList();
        if (linePart.duration == 0) {
          linePart.duration = durationInMilliseconds;
        } else {
          linePart.duration =
              draw.lines[_lastLineIndex].duration - _lastLineDurationChunked;
        }
        chunkDraw.lines.insert(0, linePart);
      } else {}
    }

    // search for wipe and reset if found
    var wipeIndex = chunkDraw.lines.lastIndexWhere((a) => a.wipe);
    if (wipeIndex > -1) {
      chunkDraw.lines = chunkDraw.lines.skip(wipeIndex + 1).toList();
      lastChunk = null;
      if(chunkDraw.lines.length == 0) return null;
    }

    _lastLineIndex = draw.lines.length - 1;

    if (draw.lines.length > 0) {
      _lastLinePointsChunked = draw.lines.last.points.length;
    } else {
      _lastLinePointsChunked = 0;
    }

    if (chunkDraw.lines.length > 0) {
      _lastLineDurationChunked = chunkDraw.lines.last.duration;
    } else {
      _lastLineDurationChunked = 0;
    }

    return lastChunk = DrawChunk(
      id: lastChunk == null ? 0 : lastChunk.id + 1,
      draw: chunkDraw,
      createdAt: DateTime.now()
    );
  }
}
