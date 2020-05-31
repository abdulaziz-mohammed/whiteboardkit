import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whiteboardkit/toolbox.dart';
import 'package:whiteboardkit/whiteboard_controller.dart';

import 'whiteboard_draw.dart';
import 'whiteboard_style.dart';

typedef void OnChangeCallback(WhiteboardDraw draw);

const HEIGHT_TO_SUBSTRACT = 80.0;

class Whiteboard extends StatefulWidget {
  final WhiteboardController controller;
  final WhiteboardStyle style;

  Whiteboard({@required this.controller, this.style = const WhiteboardStyle()});

  @override
  WhiteboardState createState() => WhiteboardState();
}

class WhiteboardState extends State<Whiteboard> {
  //drawing tools

  bool showToolBox;
  double toolboxOffset;

  // Size boardSize;
  Size availbleSize;

  bool showControls = false;
  bool showFastForward = true;

  StreamSubscription<Size> onSizeChangedSubscription;
  StreamSubscription<WhiteboardDraw> onCompletedSubscription;

  @override
  void initState() {
    super.initState();

    showToolBox = widget.controller.toolbox;
    toolboxOffset = showToolBox ? HEIGHT_TO_SUBSTRACT : 0;

    if (widget.controller is PlayControls) {
      showControls = true;
      onCompletedSubscription = (widget.controller as PlayControls)
          .onComplete()
          .listen((_) => setState(() => showFastForward = false));
    }

    onSizeChangedSubscription =
        widget.controller.onSizeChange().listen((_) => setState(() {}));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    onCompletedSubscription?.cancel();
    onSizeChangedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // if (!initialized)
      // if (Size(constraints.maxWidth, constraints.maxHeight - toolboxOffset) !=
      //     availbleSize)
        widget.controller.initializeSize(
            constraints.maxWidth, constraints.maxHeight - toolboxOffset);

      availbleSize =
          Size(constraints.maxWidth, constraints.maxHeight - toolboxOffset);
      // initialized = true;

      // print(
      //     "initializeSize: W:${constraints.maxWidth} H:${constraints.maxHeight - toolboxOffset}");

      var boardSize = widget.controller.draw.getSize();
      // print("boardSize: W:${boardSize.width} H:${boardSize.height}");

      // print("toolboxOffset:${toolboxOffset}");

      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: toolboxOffset),
                  width: boardSize.width,
                  height: boardSize.height,
                  alignment: FractionalOffset.center,
                  decoration: BoxDecoration(
                    border: widget.style.border,
                  ),
                  child: GestureDetector(
                    onPanUpdate: (DragUpdateDetails details) {
                      if(widget.controller.readonly) return;

                      RenderBox object = context.findRenderObject();
                      Offset _localPosition =
                          object.globalToLocal(details.globalPosition);
                      widget.controller.onPanUpdate(_localPosition);
                      setState(() {});
                    },
                    onPanEnd: (DragEndDetails details) {
                      if(widget.controller.readonly) return;

                      widget.controller.onPanEnd();
                      setState(() {});
                    },
                    child: StreamBuilder<WhiteboardDraw>(
                        stream: widget.controller.onChange(),
                        builder: (context, snapshot) {
                          var draw = snapshot.data;

                          return CustomPaint(
                            key: UniqueKey(),
                            foregroundPainter: new SuperPainter(draw),
                            size: Size.infinite,
                            child: Container(
                              color: Colors.white,
                            ),
                          );
                        }),
                  ),
                ),
                if (showToolBox)
                  Positioned(
                    bottom: 0.0,
                    width: boardSize.width,
                    child: ToolBox(
                      sketchController: widget.controller,
                      color: widget.style.toolboxColor,
                      options: widget.controller.toolboxOptions,
                    ),
                  ),
                if (showControls)
                  showFastForward
                      ? IconButton(
                          key: ValueKey("skipAnimationButton"),
                          icon: Icon(Icons.fast_forward),
                          color: Colors.black26,
                          onPressed: skipAnimationPressed,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        )
                      : IconButton(
                          icon: Icon(Icons.replay),
                          color: Colors.black26,
                          onPressed: restartAnimationPressed,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        )
              ],
            ),
          ],
        ),
      );
    });
  }

  skipAnimationPressed() {
    (widget.controller as PlayControls).skip();
  }

  restartAnimationPressed() {
    (widget.controller as PlayControls).play();
    setState(() {
      showFastForward = true;
    });
  }
}

class SuperPainter extends CustomPainter {
  WhiteboardDraw draw;

  List<Line> visibleLines;

  Size size;

  SuperPainter(this.draw) {
    if (draw != null)
      size = draw.getSize();
    else
      size = new Size(0, 0);

    if (draw != null && draw.lines != null) {
      var lastWipeIndex = draw.lines.lastIndexWhere((l) => l.wipe);
      visibleLines =
          lastWipeIndex > -1 ? draw.lines.sublist(lastWipeIndex) : draw.lines;
    } else
      visibleLines = new List<Line>();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(
        Rect.fromPoints(new Offset(0, 0), new Offset(size.width, size.height)));

    Paint paint = new Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // if (draw == null || draw.lines == null) return;
    // draw.lines.forEach((l) => l.wipe ? lines = [] : lines.add(l.clone()));

    visibleLines.forEach((line) {
      paint = paint
        ..color = line.color
        ..strokeWidth = line.width;

      drawLine(canvas, paint, line);
    });
  }

  drawLine(Canvas canvas, Paint paint, Line line) {
    for (int i = 0; i < line.points.length - 1; i++) {
      if (line.points[i] != null && line.points[i + 1] != null) {
        canvas.drawLine(
            line.points[i].toOffset(), line.points[i + 1].toOffset(), paint);
      }
    }
  }

  @override
  bool shouldRepaint(SuperPainter oldDelegate) =>
      oldDelegate.size != size ||
      oldDelegate.visibleLines.fold(0, (total, l) => l.points.length + total) !=
          visibleLines.fold(0, (total, l) => l.points.length + total);
}
