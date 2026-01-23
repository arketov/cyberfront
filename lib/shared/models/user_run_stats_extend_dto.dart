import 'json_utils.dart';

class UserRunStatsExtendDto {
  const UserRunStatsExtendDto({
    required this.carsWithRuns,
    required this.carsTotal,
    required this.tracksWithRuns,
    required this.tracksTotal,
    required this.avgCarMeters,
    required this.avgCarMinutes,
    required this.avgTrackMeters,
    required this.avgTrackMinutes,
  });

  final int carsWithRuns;
  final int carsTotal;
  final int tracksWithRuns;
  final int tracksTotal;
  final int avgCarMeters;
  final int avgCarMinutes;
  final int avgTrackMeters;
  final int avgTrackMinutes;

  factory UserRunStatsExtendDto.fromJson(Map<String, dynamic> json) {
    return UserRunStatsExtendDto(
      carsWithRuns: JsonUtils.asInt(json['cars_with_runs']) ?? 0,
      carsTotal: JsonUtils.asInt(json['cars_total']) ?? 0,
      tracksWithRuns: JsonUtils.asInt(json['tracks_with_runs']) ?? 0,
      tracksTotal: JsonUtils.asInt(json['tracks_total']) ?? 0,
      avgCarMeters: JsonUtils.asInt(json['avg_car_meters']) ?? 0,
      avgCarMinutes: JsonUtils.asInt(json['avg_car_minutes']) ?? 0,
      avgTrackMeters: JsonUtils.asInt(json['avg_track_meters']) ?? 0,
      avgTrackMinutes: JsonUtils.asInt(json['avg_track_minutes']) ?? 0,
    );
  }
}
