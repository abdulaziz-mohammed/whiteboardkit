import 'package:flutter/material.dart';
import 'package:whiteboardkit/toolbox.dart';
import 'package:whiteboardkit/whiteboard_controller.dart';

import 'whiteboard_draw.dart';
import 'gesture_whiteboard_controller.dart';

typedef void OnChangeCallback(WhiteboardDraw draw);

const HEIGHT_TO_SUBSTRACT = 80.0;

class Whiteboard extends StatefulWidget {
  // final double width;
  // final double height;
  final WhiteboardController controller;

  Whiteboard({
    // this.width = 0,
    // this.height = 0,
    @required this.controller,
  });

  @override
  WhiteboardState createState() => WhiteboardState();
}

class WhiteboardState extends State<Whiteboard> {
  // List<Line> lines = <Line>[];

  //drawing tools

  bool showToolBox;
  double toolboxOffset;

  Size boardSize;

  bool initialized = false;

  @override
  void initState() {
    showToolBox = widget.controller is GestureWhiteboardController;
    toolboxOffset = showToolBox ? HEIGHT_TO_SUBSTRACT : 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: LayoutBuilder(builder: (context, constraints) {
        if (!initialized)
          widget.controller.initializeSize(
              constraints.maxHeight - toolboxOffset, constraints.maxWidth);
        initialized = true;

        //  widget.controller.getBoardSize();
        // if (widget.controller is AnimatedSketchController) {
        //   boardSize = widget.controller.getSize();
        // } else {
        //   boardSize = new Size(constraints.maxWidth, constraints.maxHeight);
        // }
        boardSize = widget.controller.getSize();

        return StreamBuilder<WhiteboardDraw>(
            stream: widget.controller.onChange(),
            builder: (context, snapshot) {
              List<Line> lines = [];
              if (snapshot.data != null) {
                snapshot.data.lines
                    .forEach((l) => l.wipe ? lines = [] : lines.add(l.clone()));

                lines = scaleLines(
                    lines,
                    snapshot.data.width,
                    snapshot.data.height,
                    boardSize.width,
                    boardSize.height);
              }

              return Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: toolboxOffset),
                        width: boardSize.width,
                        height: boardSize.height,
                        alignment: FractionalOffset.center,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: Colors.black12),
                        ),
                        child: GestureDetector(
                          onPanUpdate: (DragUpdateDetails details) {
                            RenderBox object = context.findRenderObject();
                            Offset _localPosition =
                                object.globalToLocal(details.globalPosition);
                            widget.controller.onPanUpdate(_localPosition);
                            setState(() {});
                          },
                          onPanEnd: (DragEndDetails details) {
                            widget.controller.onPanEnd();
                            setState(() {});
                          },
                          child: CustomPaint(
                            foregroundPainter: new SuperPainter(
                              lines: lines,
                            ),
                            size: Size.infinite,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (showToolBox)
                        Positioned(
                          bottom: 0.0,
                          child: ToolBox(
                            width: boardSize.width,
                            sketchController: widget.controller,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            });
      }),
    );
  }

  Size calculateScaledSize(WhiteboardDraw draw, double boardWidth, double boardHeight) {
    var scaleX = boardWidth / draw.width; // 0.5
    var scaleY = boardHeight / draw.height; // 1

    var scale = 0.0;

    var height = 0.0;
    var width = 0.0;

    if (scaleX < scaleY) {
      scale = scaleX;
      height = boardHeight * scale;
      width = boardWidth;
    } else {
      scale = scaleY;
      height = boardHeight;
      width = boardWidth * scale;
    }

    return new Size(width, height);
  }

  WhiteboardDraw scaleDraw(WhiteboardDraw draw, double boardWidth, double boardHeight) {
    var scaleX = boardWidth / draw.width; // 0.5
    var scaleY = boardHeight / draw.height; // 1

    var scale = 0.0;

    var height = 0.0;
    var width = 0.0;

    if (scaleX < scaleY) {
      scale = scaleX;
      height = boardHeight * scale;
      width = boardWidth;
    } else {
      scale = scaleY;
      height = boardHeight;
      width = boardWidth * scale;
    }

    return draw.copyWith(
        lines: draw.lines
            .map((line) => line.clone()
              ..points = line.points
                  .map((point) => new Point(point.x * scale, point.y * scale))
                  .toList()
              ..width = line.width * scale)
            .toList(),
        width: width,
        height: height);
  }

  List<Line> scaleLines(List<Line> lines, double width, double height,
      double boardWidth, double boardHeight) {
    var scaleX = boardWidth / width; // 0.5
    var scaleY = boardHeight / height; // 1

    var scale = 0.0;

    if (scaleX < scaleY) {
      scale = scaleX;
    } else {
      scale = scaleY;
    }

    return lines
        .map((line) => line.clone()
          ..points = line.points
              .map((point) => new Point(point.x * scale, point.y * scale))
              .toList()
          ..width = line.width * scale)
        .toList();
  }
}

class SuperPainter extends CustomPainter {
  List<Line> lines;

  SuperPainter({this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(
        Rect.fromPoints(new Offset(0, 0), new Offset(size.width, size.height)));

    Paint paint = new Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    lines.forEach((line) {
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
      oldDelegate.lines.fold(0, (total, l) => l.points.length + total) !=
      lines.fold(0, (total, l) => l.points.length + total);
}
