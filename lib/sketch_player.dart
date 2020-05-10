import 'package:flutter/material.dart';
import 'package:whiteboardkit/whiteboard.dart';

import 'animated_sketch_controller.dart';

class SketchPlayer extends StatefulWidget {
  final AnimatedSketchController controller;
  // final bool skipAnimation;
  final bool hideControls;

  SketchPlayer({
    this.controller,
    // this.skipAnimation = false,
    this.hideControls = false,
  });

  @override
  SketchPlayerState createState() => SketchPlayerState();
}

class SketchPlayerState extends State<SketchPlayer>
    with TickerProviderStateMixin {
  bool showFastForward = true;

  @override
  void initState() {
    widget.controller
        .onComplete()
        .listen((_) => setState(() => showFastForward = false));

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // @override
  // void didUpdateWidget(SketchPlayer oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.skipAnimation != widget.skipAnimation &&
  //       widget.skipAnimation) {
  //     skipAnimationPressed();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Whiteboard(
          controller: widget.controller,
        ),
        widget.hideControls
            ? Container(
                height: 0,
                width: 0,
              )
            : showFastForward
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
    );
  }

  skipAnimationPressed() {
    widget.controller.skip();
  }

  restartAnimationPressed() {
    widget.controller.play();
    setState(() {
      showFastForward = true;
    });
  }

  @override
  void dispose() {
    // controller?.close();
    super.dispose();
  }
}