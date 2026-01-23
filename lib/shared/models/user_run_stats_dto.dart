import 'car_dto.dart';
import 'track_dto.dart';
import 'json_utils.dart';

class UserRunStatsDto {
  const UserRunStatsDto({
    required this.totalMeters,
    required this.totalMinutes,
    required this.favoriteCar,
    required this.favoriteTrack,
  });

  final int totalMeters;
  final int totalMinutes;
  final CarDto? favoriteCar;
  final TrackDto? favoriteTrack;

  factory UserRunStatsDto.fromJson(Map<String, dynamic> json) {
    final carRaw = json['favorite_car'];
    final trackRaw = json['favorite_track'];

    return UserRunStatsDto(
      totalMeters: JsonUtils.asInt(json['total_meters']) ?? 0,
      totalMinutes: JsonUtils.asInt(json['total_minutes']) ?? 0,
      favoriteCar: carRaw is Map<String, dynamic> ? CarDto.fromJson(carRaw) : null,
      favoriteTrack: trackRaw is Map<String, dynamic> ? TrackDto.fromJson(trackRaw) : null,
    );
  }
}
