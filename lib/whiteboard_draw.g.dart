// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whiteboard_draw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhiteboardDraw _$DrawFromJson(Map<String, dynamic> json) {
  return WhiteboardDraw(
      lines: (json['lines'] as List)
          .map((e) => Line.fromJson(e as Map<String, dynamic>))
          .toList(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble());
}

Map<String, dynamic> _$DrawToJson(WhiteboardDraw instance) => <String, dynamic>{
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'width': instance.width,
      'height': instance.height
    };

Line _$LineFromJson(Map<String, dynamic> json) {
  return Line(
      points: json['points'] == null? []: (json['points'] as List)
          .map((e) => Point.fromJson(e as Map<String, dynamic>))
          .toList(),
      color: _colorFromString(json['color'] as String),
      width: (json['width'] as num).toDouble(),
      wipe: json['wipe'] as bool?,
      duration: json['duration'] as int?);
}

Map<String, dynamic> _$LineToJson(Line instance) => <String, dynamic>{
      'points': instance.points.map((e) => e.toJson()).toList(),
      'color': _colorToString(instance.color),
      'width': instance.width,
      'duration': instance.duration,
      'wipe': instance.wipe
    };

Point _$PointFromJson(Map<String, dynamic> json) {
  return Point((json['x'] as num?)?.toDouble(), (json['y'] as num?)?.toDouble());
}

Map<String, dynamic> _$PointToJson(Point instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y};
