import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'gesture_whiteboard_controller.dart';

enum ToolBoxSelected { none, size, color, erase }

class ToolBox extends StatefulWidget {
  final double width;
  final GestureWhiteboardController sketchController;

  ToolBox({@required this.width, @required this.sketchController});

  @override
  _ToolBoxState createState() => _ToolBoxState();
}

class _ToolBoxState extends State<ToolBox> {
  double brushSize;
  Color brushColor;
  bool erase;
  double eraserSize;

  ToolBoxSelected selected;

  final brushSizes = <double>[10, 20, 30, 40];
  final brushColors = <Color>[
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.brown,
    Colors.yellow,
    Colors.green
  ];

  @override
  void initState() {
    brushSize = 20.0;
    brushColor = Colors.blue;
    erase = false;
    eraserSize = 20.0;

    selected = ToolBoxSelected.none;

    widget.sketchController.brushSize = brushSize;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: selected == ToolBoxSelected.erase
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: brushSizes
                      .map((size) => _buildEraseToolSizeButton(size))
                      .toList(),
                )
              : Container(),
        ),
        Container(
          child: selected == ToolBoxSelected.size
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: brushSizes
                      .map((size) => _buildBrushToolSizeButton(size))
                      .toList(),
                )
              : Container(),
        ),
        Container(
          child: selected == ToolBoxSelected.color
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: brushColors
                      .map((color) => _buildBrushToolColorButton(color))
                      .toList(),
                )
              : Container(),
        ),
        Container(
          height: 80.0,
          color: Colors.transparent,
          width: widget.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildToolButton(
                      Icon(Icons.fiber_manual_record),
                      select: ToolBoxSelected.size,
                    ),
                    _buildToolButton(Icon(Icons.color_lens),
                        select: ToolBoxSelected.color, color: brushColor),
                    _buildToolButton(
                      Icon(
                        FontAwesomeIcons.eraser,
                        color: new Color(0xffff93f5),
                        size: 26.0,
                      ),
                      select: ToolBoxSelected.erase,
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildToolButton(
                      Icon(
                        FontAwesomeIcons.file,
                        size: 26.0,
                      ),
                      onPress: () => {widget.sketchController.wipe()},
                    ),
                    _buildToolButton(Icon(Icons.undo),
                        onPress: widget.sketchController.undo),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildToolButton(Icon icon,
      {ToolBoxSelected select,
      Function onPress,
      Color color = Colors.black54,
      double size = 30.0}) {
    return IconButton(
      icon: icon,
      color: color,
      iconSize: size,
      onPressed: () {
        if (select == null) {
          hide();
          onPress();
        } else {
          if (selected == select)
            hide();
          else
            show(select);
        }
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }

  Widget _buildBrushToolSizeButton(double size) {
    return Container(
      color: size == brushSize && !erase ? Colors.black12 : Colors.transparent,
      child: IconButton(
        icon: Icon(Icons.fiber_manual_record),
        color: Colors.black54,
        iconSize: size * 1.6,
        onPressed: () => changeSize(size),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
    );
  }

  Widget _buildBrushToolColorButton(Color color) {
    return Container(
      color:
          color == brushColor && !erase ? Colors.black12 : Colors.transparent,
      child: IconButton(
        icon: Icon(Icons.color_lens),
        color: color,
        iconSize: 40.0,
        onPressed: () => changeColor(color),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
    );
  }

  Widget _buildEraseToolSizeButton(double size) {
    return Container(
      color: size == eraserSize && erase ? Colors.black12 : Colors.transparent,
      child: IconButton(
        icon: Icon(FontAwesomeIcons.eraser),
        color: new Color(0xffff93f5),
        iconSize: size,
        onPressed: () => changeEraser(true, size),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
    );
  }

  void show(ToolBoxSelected selected) {
    setState(() {
      this.selected = selected;
    });
  }

  void hide() {
    setState(() {
      selected = ToolBoxSelected.none;
    });
  }

  void changeSize(double size) {
    setState(() {
      changeEraser(false, eraserSize);
      brushSize = size;
      widget.sketchController.brushSize = brushSize;
      hide();
    });
  }

  void changeColor(Color color) {
    setState(() {
      changeEraser(false, eraserSize);
      brushColor = color;
      widget.sketchController.brushColor = color;
      hide();
    });
  }

  void changeEraser(bool erase, double size) {
    setState(() {
      eraserSize = size;
      this.erase = erase;
      widget.sketchController.erase = erase;
      widget.sketchController.eraserSize = size;
      hide();
    });
  }

//  void changeErase(bool erase) {
//    setState(() {
//      this.erase = erase;
//      widget.onEraserChange(erase);
//      hide();
//    });
//  }
}
