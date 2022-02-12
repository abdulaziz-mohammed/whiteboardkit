import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whiteboardkit/whiteboardkit.dart';
import 'draw_chunker.dart';
import 'toolbox_options.dart';
import 'whiteboard_draw.dart';
import 'whiteboard_controller.dart';

class DrawingController extends WhiteboardController {
  bool _newLine = true;
  DateTime? lastPan;
  late DateTime firstPointTime;

  double? brushSize = 20.0;
  Color brushColor = Colors.blue;
  bool erase = false;
  double? eraserSize = 20.0;

  final _chunkController = StreamController<DrawChunk>.broadcast();
  DrawChunker? _chunker;
  final bool enableChunk;

  DrawingController({WhiteboardDraw? draw, this.enableChunk = false})
      : super(
            readonly: false,
            toolbox: true,
            toolboxOptions: ToolboxOptions(undo: !enableChunk)) {
    if (draw != null) {
      this.draw = draw.copyWith();
      streamController.sink.add(this.draw!.copyWith());
    }

    //chunker
    if (enableChunk)
      Timer.periodic(const Duration(seconds: 5), (_) => _flushChunk());
  }

  @override
  close() {
    _chunkController.close();
    return super.close();
  }

  @override
  initializeSize(double width, double height) {
    draw ??= WhiteboardDraw.empty(width: width, height: height);
    super.initializeSize(width, height);

    _chunker ??= draw!.chunker(5);
  }

  onPanUpdate(Offset position) {
    if (draw == null) return;

    if (_newLine) {
      if (_chunker != null &&
          lastPan != null &&
          DateTime.now().difference(lastPan!).inMilliseconds <
              _chunker!.durationInMilliseconds &&
          (draw!.lines.isEmpty || draw!.lines.last.wipe != true)) {
        draw!.lines.add(Line(
          points: [],
          color: Colors.white,
          width: 0,
          duration: DateTime.now().difference(lastPan!).inMilliseconds,
        ));
      }

      draw!.lines.add(Line(
          points: [],
          color: erase ? Colors.white : brushColor,
          width: erase ? eraserSize : brushSize,
          duration: 0));
      _newLine = false;
      firstPointTime = DateTime.now();
    }

    if (draw!.lines.last.points.length > 2 &&
        lastPan != null &&
        (lastPan!.millisecond - DateTime.now().millisecond) < 100) {
      var a1 = position.dx - draw!.lines.last.points.last.x!;
      var a2 = position.dy - draw!.lines.last.points.last.y!;
      var a3 = sqrt(pow(a1, 2) + pow(a2, 2));

      if (a3 < 5) return;
    }

    if (draw!.lines.last.points.isEmpty ||
        position != draw!.lines.last.points.last.toOffset()) {
      draw!.lines.last.points = List.from(draw!.lines.last.points)
        ..add(Point.fromOffset(position));
      draw!.lines.last.duration =
          DateTime.now().difference(firstPointTime).inMilliseconds;
      lastPan = DateTime.now();
    }
    streamController.sink.add(draw!.copyWith());
  }

  onPanEnd() {
    _newLine = true;
    draw!.lines.last.duration =
        DateTime.now().difference(firstPointTime).inMilliseconds;

    if (draw!.lines.isNotEmpty && draw!.lines.last.points.length == 1) {
      var secondPoint = Offset(draw!.lines.last.points.last.x! + 1,
          draw!.lines.last.points.last.y! + 1);
      draw!.lines.last.points.add(Point.fromOffset(secondPoint));
    }
    if (draw!.lines.isNotEmpty && draw!.lines.last.points.isEmpty) {
      draw!.lines.removeLast();
    }
    streamController.sink.add(draw!.copyWith());
  }

  undo() {
    if (draw!.lines.isNotEmpty) draw!.lines.removeLast();
    streamController.sink.add(draw!.copyWith());
  }

  wipe() {
    draw!.lines.add(Line(points: [], wipe: true));
    streamController.sink.add(draw!.copyWith());
  }

  Future<void> _flushChunk() async {
    if (draw == null || !_chunkController.hasListener) return;
    if (_chunker == null) return;
    var chunk = _chunker!.next();
    if (chunk != null) _chunkController.sink.add(chunk);
  }

  Stream<DrawChunk> onChunk() {
    return _chunkController.stream;
  }
}
