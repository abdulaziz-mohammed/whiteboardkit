# whiteboardkit

A Flutter whiteboard widget with so much extendability and flexibility to be used with no need to rewrite your own whiteboard. Enjoy !

![Package demo](screenshot.gif) 

## Installation

Add the following to pubspec.yaml
```yaml
dependencies:
  ...
  whiteboardkit: ^0.1.6
```

## Usage Example

import whiteboardkit.dart

```dart
import 'package:whiteboardkit/whiteboardkit.dart';
```

define GestureWhiteboardController and listen to change event

```dart
  GestureWhiteboardController controller;

  @override
  void initState() {
    controller = new GestureWhiteboardController();
    controller.onChange().listen((draw){
      //do something with it
    });
    super.initState();
  }
```

place your Whiteboard inside a constrained widget ie. container,Expanded etc

```dart
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Whiteboard(
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
```

