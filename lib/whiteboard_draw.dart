import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:whiteboardkit/draw_chunker.dart';
import 'package:xml/xml.dart' as xml;

part 'whiteboard_draw.g.dart';

@JsonSerializable(nullable: false, explicitToJson: true)
class WhiteboardDraw {
  List<Line> lines;
  double width;
  double height;

  WhiteboardDraw({this.lines = const [], this.width = 0, this.height = 0});

  factory WhiteboardDraw.fromJson(Map<String, dynamic> json) =>
      _$DrawFromJson(json);

  Map<String, dynamic> toJson() => _$DrawToJson(this);

  WhiteboardDraw clone() {
    return new WhiteboardDraw(
        lines: lines.map((line) => line.clone()).toList(),
        width: width,
        height: height);
  }

  WhiteboardDraw copyWith(
      {String id, List<Line> lines, double width, double height}) {
    return WhiteboardDraw(
      lines: lines ?? this.lines.map((line) => line.clone()).toList(),
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  factory WhiteboardDraw.empty(
          {@required double width, @required double height}) =>
      WhiteboardDraw(height: height, width: width, lines: []);

  // Duration get drawingDuration {
  //   var duration = new Duration();

  //   if (lines != null)
  //     lines.forEach((line) {
  //       if (line.points.length == 2) //point
  //         duration += Duration(milliseconds: 300);
  //       else if (line.wipe) //wipe
  //         duration += Duration(milliseconds: 1000);
  //       else //path
  //         duration +=
  //             Duration(milliseconds: line.duration);
  //     });
  //   return duration;
  // }

  Size getSize() => new Size(width, height);

  Duration get drawingDuration {
    var duration = new Duration();

    if (lines != null)
      lines.forEach((line) {
        duration += Duration(milliseconds: line.duration);
      });
    return duration;
  }

  DrawChunker chunker(int seconds) => DrawChunker(this, seconds * 1000);

  List<Line> getLinesWithoutWipe() {
    var lastWipeIndex = lines.lastIndexWhere((l) => l.wipe);
    var visibleLines =
        lastWipeIndex > -1 ? lines.sublist(lastWipeIndex) : lines;
    return visibleLines;
  }

  void scale(double targetWidth, double targetHeight) {
    var newSize = getScaledSize(targetWidth, targetHeight);

    var scale = newSize.width / width;

    this.width = newSize.width;
    this.height = newSize.height;
    this.lines = this
        .lines
        .map((line) => line.clone()
          ..points = line.points
              .map((point) => new Point(point.x * scale, point.y * scale))
              .toList()
          ..width = line.width * scale)
        .toList();
  }

  WhiteboardDraw getScaled(double targetWidth, double targetHeight) {
    return copyWith()..scale(targetWidth, targetHeight);
  }

  Size getScaledSize(double targetWidth, double targetHeight) {
    var scaleX = this.width / targetWidth; // 0.5
    var scaleY = this.height / targetHeight; // 1

    var scale = 0.0;

    var finalHeight = 0.0;
    var finalWidth = 0.0;

    if (scaleX > scaleY) {
      scale = scaleX;
      finalHeight = this.height / scale;
      finalWidth = targetWidth;
    } else {
      scale = scaleY;
      finalHeight = targetHeight;
      finalWidth = this.width / scale;
    }

    if (finalWidth == double.nan) finalWidth = 0;
    if (finalHeight == double.nan) finalHeight = 0;

    return Size(finalWidth, finalHeight);
  }

  // String getSVG({bool history = true}) {
  //   var draw = this.clone();
  //   var visibleSinceIndex = 0;
  //   if (this.lines.lastIndexWhere((element) => element.wipe == true) != -1)
  //     visibleSinceIndex =
  //         draw.lines.lastIndexWhere((element) => element.wipe == true) + 1;

  //   var pathsStrings = List<String>();
  //   var wipes = List<int>();

  //   for (var i = 0; i < draw.lines.length; i++) {
  //     var line = draw.lines[i];
  //     if (line.wipe) {
  //       wipes.add(i);
  //       continue;
  //     }

  //     var hexColor = '#${line.color.value.toRadixString(16).substring(2)}';
  //     var width = line.width;
  //     var visible = i >= visibleSinceIndex;
  //     if (line.points.length == 1) {
  //       pathsStrings.add(
  //           '<circle cx="${line.points[0].x}" cy="${line.points[0].y}" r="${width}" fill="${hexColor}" data-duration="${line.duration}" visibility="${visible ? "visible" : "hidden"}"/>');
  //     } else if (line.points.length > 1) {
  //       var moveCommand = "M${line.points.first.x},${line.points.first.y}";
  //       var lineCommands =
  //           line.points.skip(1).map((p) => "L${p.x},${p.y}").join(' ');
  //       pathsStrings.add(
  //           '<path d="${moveCommand} ${lineCommands}" stroke="${hexColor}" stroke-width="${width}" data-duration="${line.duration}" visibility="${visible ? "visible" : "hidden"}" fill="none" stroke-linecap="round" stroke-linejoin="round"/>');
  //     }
  //   }

  //   return '<svg height="${draw.height}" width="${draw.width}" data-wipes="${wipes.join(",")}" xmlns="http://www.w3.org/2000/svg" version="1.1">${pathsStrings.join('')}</svg>';
  // }

  String getSVG({bool animation = true}) {
    final builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.1"');

    builder.element("svg", nest: () {
      var draw = this.clone();

      var visibleSinceIndex = 0;
      if (this.lines.lastIndexWhere((element) => element.wipe == true) != -1)
        visibleSinceIndex =
            draw.lines.lastIndexWhere((element) => element.wipe == true) + 1;

      if (!animation && visibleSinceIndex > 0) {
        draw.lines = draw.lines.skip(visibleSinceIndex + 1).toList();
        visibleSinceIndex = 0;
      }

      var wipes = List<int>();

      for (var i = 0; i < draw.lines.length; i++) {
        var line = draw.lines[i];
        if (line.wipe) {
          wipes.add(i);
          continue;
        }

        var hexColor = '#${line.color.value.toRadixString(16).substring(2)}';
        var width = line.width;
        var visible = i >= visibleSinceIndex;
        if (line.points.length == 1) {
          builder.element("circle", nest: () {
            builder.attribute("cx", line.points[0].x);
            builder.attribute("cy", line.points[0].y);
            builder.attribute("r", width);
            builder.attribute("fill", hexColor);
            if (animation) builder.attribute("data-duration", line.duration);
            if (animation)
              builder.attribute("visibility", visible ? "visible" : "hidden");
          });
          // pathsStrings.add(
          //     '<circle cx="${line.points[0].x}" cy="${line.points[0].y}" r="${width}" fill="${hexColor}" data-duration="${line.duration}" visibility="${visible ? "visible" : "hidden"}"/>');
        } else if (line.points.length > 1) {
          var moveCommand = "M${line.points.first.x},${line.points.first.y}";
          var lineCommands =
              line.points.skip(1).map((p) => "L${p.x},${p.y}").join(' ');

          builder.element("path", nest: () {
            builder.attribute("d", moveCommand + " " + lineCommands);
            builder.attribute("stroke", hexColor);
            builder.attribute("stroke-width", width);
            builder.attribute("fill", "none");
            builder.attribute("stroke-linecap", "round");
            builder.attribute("stroke-linejoin", "round");
            if (animation) builder.attribute("data-duration", line.duration);
            if (animation)
              builder.attribute("visibility", visible ? "visible" : "hidden");
          });
          // pathsStrings.add(
          //     '<path d="${moveCommand} ${lineCommands}" stroke="${hexColor}" stroke-width="${width}" data-duration="${line.duration}" visibility="${visible ? "visible" : "hidden"}" fill="none" stroke-linecap="round" stroke-linejoin="round"/>');
        }
      }
      builder.attribute("version", "1.1");
      builder.attribute("xmlns", "http://www.w3.org/2000/svg");
      builder.attribute("height", draw.height);
      builder.attribute("width", draw.width);
      if (animation) builder.attribute("data-wipes", wipes.join(","));
    });
    return builder.build().document.findElements("svg").first.toString();

    // return '<svg height="${draw.height}" width="${draw.width}" data-wipes="${wipes.join(",")}" xmlns="http://www.w3.org/2000/svg" version="1.1">${pathsStrings.join('')}</svg>';
  }

  factory WhiteboardDraw.fromWhiteboardSVG(String svg) {
    final document = xml.parse(svg);
    // print("document.toXmlString()");
    // print(document.toXmlString());

    // print('document.attributes.map((e) => e.name.local).join(",")');
    // print(document.attributes.map((e) => e.name.local).join(","));

    // print('document.attributes.map((e) => e.name.qualified).join(",")');
    // print(document.attributes.map((e) => e.name.qualified).join(","));

    // print('document.findAllElements("*").map((e) => e.name.qualified).join(",")');
    // print(document.findElements("*").map((e) => e.name.qualified).join(","));

    var svgElement = document.findElements("svg").first;

    var height = svgElement.attributes
        .firstWhere((att) => att.name.local == "height")
        .value;
    var width = svgElement.attributes
        .firstWhere((att) => att.name.local == "width")
        .value;

    var lines = List<Line>();

    svgElement.findElements("*").forEach((element) {
      if (element.name.local == "path") {
        var color = element.attributes
            .firstWhere((att) => att.name.local == "stroke")
            .value;
        var width = element.attributes
            .firstWhere((att) => att.name.local == "stroke-width")
            .value;
        var durationAttr = element.attributes.firstWhere(
          (att) => att.name.local == "data-duration",
          orElse: () => null,
        );
        var duration = durationAttr == null ? 0 : int.parse(durationAttr.value);
        var points = element.attributes
            .firstWhere((att) => att.name.local == "d")
            .value
            .split(" ")
            .map((command) {
          var coords = command.substring(1).split(",");
          return new Point(double.parse(coords[0]), double.parse(coords[1]));
        }).toList();
        lines.add(Line(
          points: points,
          color: HexColor(color),
          width: double.parse(width),
          duration: duration,
        ));
      } else if (element.name.local == "circle") {
        var color = element.attributes
            .firstWhere((att) => att.name.local == "fill")
            .value;
        var width =
            element.attributes.firstWhere((att) => att.name.local == "r").value;
        var durationAttr = element.attributes.firstWhere(
          (att) => att.name.local == "data-duration",
          orElse: () => null,
        );
        var duration = durationAttr == null ? 0 : int.parse(durationAttr.value);
        var x = element.attributes
            .firstWhere((att) => att.name.local == "cx")
            .value;
        var y = element.attributes
            .firstWhere((att) => att.name.local == "cy")
            .value;
        lines.add(Line(
          points: [new Point(double.parse(x), double.parse(y))],
          color: HexColor(color),
          width: double.parse(width),
          duration: duration,
        ));
      }
    });

    var wipesAttr = svgElement.attributes.firstWhere(
      (att) => att.name.local == "data-wipes",
      orElse: () => null,
    );

    var wipes = wipesAttr == null ? [] : wipesAttr.value.split(",");

    wipes.forEach((wipe) {
      if (int.tryParse(wipe) != null)
        lines.insert(int.parse(wipe), new Line(wipe: true));
    });

    return WhiteboardDraw(
      height: double.parse(height),
      width: double.parse(width),
      lines: lines,
    );
  }
}

@JsonSerializable(nullable: false, explicitToJson: true)
class Line {
//  @JsonKey(fromJson: _offsetsFromList, toJson: _offsetsToList)
//  List<Offset> points;

  List<Point> points;

  @JsonKey(fromJson: _colorFromString, toJson: _colorToString)
  Color color;

  double width;
  int duration;

  bool wipe;

  Line(
      {this.points = const [],
      this.color = Colors.blue,
      this.width = 10.0,
      this.wipe = false,
      this.duration = 0});

  factory Line.fromJson(Map<String, dynamic> json) => _$LineFromJson(json);

  Map<String, dynamic> toJson() => _$LineToJson(this);

  Line clone() {
    return new Line(
        points: points.map((point) => new Point(point.x, point.y)).toList(),
        color: color,
        width: width,
        wipe: wipe,
        duration: duration);
  }

  Line copyWith(
      {List<Point> points,
      Color color,
      double width,
      bool wipe,
      int duration}) {
    return Line(
      points: points ?? this.points.map((p) => new Point(p.x, p.y)).toList(),
      color: color ?? this.color,
      width: width ?? this.width,
      wipe: wipe ?? this.wipe,
      duration: duration ?? this.duration,
    );
  }

  // void scaleTo(double targetWidth, double targetHeight) {
  //   var newSize = _getScaledSize(targetWidth, targetHeight);

  //   var scale = newSize.width / width;

  //   return this.copyWith(
  //       width: newSize.width,
  //       height: newSize.height,
  //       lines: this
  //           .lines
  //           .map((line) => line.clone()
  //             ..points = line.points
  //                 .map((point) => new Point(point.x * scale, point.y * scale))
  //                 .toList()
  //             ..width = line.width * scale)
  //           .toList());
  // }
}

Color _colorFromString(String colorStr) {
  var color = new Color(int.parse(colorStr));
  return color;
} //Colors.blue;

String _colorToString(Color color) {
  var string = color.value.toString();
  return string;
}

//Color _colorFromString(String color) => new HexColor(color);
//
//String _colorToString(Color color) => color.value.toString();

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

@JsonSerializable()
class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
  Map<String, dynamic> toJson() => _$PointToJson(this);

  factory Point.fromOffset(Offset offset) => new Point(offset.dx, offset.dy);
  Offset toOffset() => Offset(x, y);

  bool operator ==(other) =>
      other is Point && this.x == other.x && this.y == other.y;

  @override
  int get hashCode => hashValues(this.x, this.y);
}
