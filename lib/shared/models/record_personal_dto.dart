import 'car_dto.dart';
import 'json_utils.dart';
import 'track_dto.dart';
import 'user_dto.dart';

class RecordPersonalDto {
  final int id;
  final double lapTime;
  final String createdAt;
  final CarDto car;
  final TrackDto track;
  final UserDto user;

  const RecordPersonalDto({
    required this.id,
    required this.lapTime,
    required this.createdAt,
    required this.car,
    required this.track,
    required this.user,
  });

  factory RecordPersonalDto.fromJson(Map<String, dynamic> json) =>
      RecordPersonalDto(
        id: JsonUtils.asInt(json['id']) ?? 0,
        lapTime: JsonUtils.asDouble(json['lap_time']) ?? 0.0,
        createdAt: JsonUtils.asString(json['created_at']) ?? '',
        car: CarDto.fromJson(json['car'] as Map<String, dynamic>),
        track: TrackDto.fromJson(json['track'] as Map<String, dynamic>),
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      );
}
