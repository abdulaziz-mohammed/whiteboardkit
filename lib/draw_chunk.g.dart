// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw_chunk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrawChunk _$DrawChunkFromJson(Map<String, dynamic> json) {
  return DrawChunk(
    id: json['id'] as int?,
    draw: WhiteboardDraw.fromJson(json["draw"]),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

Map<String, dynamic> _$DrawChunkToJson(DrawChunk instance) => <String, dynamic>{
      'id': instance.id,
      'draw': instance.draw!.toJson(),
      'createdAt': instance.createdAt!.toIso8601String(),
    };
