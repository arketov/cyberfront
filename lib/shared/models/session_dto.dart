import 'json_utils.dart';
import 'car_dto.dart';
import 'track_dto.dart';

class SessionDto {
  const SessionDto({
    required this.durationMinutes,
    required this.distanceMeters,
    required this.averageSpeed,
    required this.carefuness,
    required this.createdAt,
    required this.car,
    required this.track,
  });

  final int durationMinutes;
  final int distanceMeters;
  final double averageSpeed;
  final int carefuness;
  final String? createdAt;
  final CarDto? car;
  final TrackDto? track;

  factory SessionDto.fromJson(Map<String, dynamic> json) => SessionDto(
        durationMinutes: JsonUtils.asInt(json['duration']) ?? 0,
        distanceMeters: JsonUtils.asInt(json['distanse']) ?? 0,
        averageSpeed: JsonUtils.asDouble(json['average_speed']) ?? 0,
        carefuness: JsonUtils.asInt(json['carefuness']) ?? 0,
        createdAt: JsonUtils.asString(json['created_at']),
        car: json['car'] is Map<String, dynamic>
            ? CarDto.fromJson(json['car'] as Map<String, dynamic>)
            : null,
        track: json['track'] is Map<String, dynamic>
            ? TrackDto.fromJson(json['track'] as Map<String, dynamic>)
            : null,
      );
}
