import 'json_utils.dart';

class CyberStatsDto {
  const CyberStatsDto({
    required this.tracksTotal,
    required this.carsTotal,
    required this.activeUsers,
  });

  final int tracksTotal;
  final int carsTotal;
  final int activeUsers;

  factory CyberStatsDto.fromJson(Map<String, dynamic> json) {
    return CyberStatsDto(
      tracksTotal: JsonUtils.asInt(json['tracks_total']) ?? 0,
      carsTotal: JsonUtils.asInt(json['cars_total']) ?? 0,
      activeUsers: JsonUtils.asInt(json['active_users']) ?? 0,
    );
  }
}
