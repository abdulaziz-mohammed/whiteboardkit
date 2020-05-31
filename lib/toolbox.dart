import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:whiteboardkit/toolbox_options.dart';

import 'drawing_controller.dart';

enum ToolBoxSelected { none, size, color, erase }

class ToolBox extends StatefulWidget {
  // final double width;
  final DrawingController sketchController;
  final Color color;
  final ToolboxOptions options;

  ToolBox(
      {
      // @required this.width,
      @required this.sketchController,
      @required this.color,
      @required this.options});

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
    var row = <Widget>[];

    switch (selected) {
      case ToolBoxSelected.erase:
        row =
            brushSizes.map((size) => _buildEraseToolSizeButton(size)).toList();
        break;
      case ToolBoxSelected.size:
        row =
            brushSizes.map((size) => _buildBrushToolSizeButton(size)).toList();
        break;
      case ToolBoxSelected.color:
        row = brushColors
            .map((color) => _buildBrushToolColorButton(color))
            .toList();
        break;
      default:
        break;
    }

    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width - 1,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: row.length > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ...row,
                      ],
                    )
                  : Container(),
            ),
          ),
        ),
        // Stack(
        //   alignment: Alignment.center,
        //   children: <Widget>[
        //     Positioned(
        //       top: 30,
        //       height: 100,
        //       width: 200,
        //       child: Container(
        //         child: selected == ToolBoxSelected.color
        //             ? Row(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 crossAxisAlignment: CrossAxisAlignment.center,
        //                 children: brushColors
        //                     .map((color) => _buildBrushToolColorButton(color))
        //                     .toList(),
        //               )
        //             : Container(),
        //       ),
        //     ),
        //   ],
        // ),
        Container(
          height: 30,
        ),
        Container(
          height: 80.0,
          color: Colors.transparent,
          // width: widget.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildToolButton(
                      Icon(
                        FontAwesomeIcons.pen,
                        size: 20,
                      ),
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
                        color: widget.color,
                      ),
                      onPress: () => {widget.sketchController.wipe()},
                    ),
                    if (widget.options.undo)
                      _buildToolButton(
                          Icon(
                            FontAwesomeIcons.undo,
                            color: widget.color,
                            size: 24,
                          ),
                          onPress: widget.sketchController.undo),
                  ],
                ),
                decoration: BoxDecoration(
                  // color: Colors.white,
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
    var first = brushSizes.indexOf(size) == 0;
    var last = brushSizes.indexOf(size) == brushSizes.length - 1;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12, width: 2),
          bottom: BorderSide(color: Colors.black12, width: 2),
          right: BorderSide(color: Colors.black12, width: first ? 2 : 1),
          left: BorderSide(color: Colors.black12, width: last ? 2 : 1),
        ),
        color: size == brushSize && !erase ? Colors.grey[300] : Colors.white,
      ),
      height: 90,
      width: 80,
      child: IconButton(
        icon: Icon(FontAwesomeIcons.pen),
        color: Colors.black54,
        iconSize: size * 1.6,
        onPressed: () => changeSize(size),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
    );
  }

  Widget _buildBrushToolColorButton(Color color) {
    var first = brushColors.indexOf(color) == 0;
    var last = brushColors.indexOf(color) == brushColors.length - 1;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12, width: 2),
          bottom: BorderSide(color: Colors.black12, width: 2),
          right: BorderSide(color: Colors.black12, width: first ? 2 : 1),
          left: BorderSide(color: Colors.black12, width: last ? 2 : 1),
        ),
        color: color == brushColor && !erase ? Colors.grey[300] : Colors.white,
      ),
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
    var first = brushSizes.indexOf(size) == 0;
    var last = brushSizes.indexOf(size) == brushSizes.length - 1;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12, width: 2),
          bottom: BorderSide(color: Colors.black12, width: 2),
          right: BorderSide(color: Colors.black12, width: first ? 2 : 1),
          left: BorderSide(color: Colors.black12, width: last ? 2 : 1),
        ),
        color: size == eraserSize && erase ? Colors.grey[300] : Colors.white,
      ),
      height: 60,
      width: 60,
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
