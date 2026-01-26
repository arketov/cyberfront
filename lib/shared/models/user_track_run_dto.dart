import 'json_utils.dart';

class UserTrackRunDto {
  const UserTrackRunDto({
    required this.userId,
    required this.trackId,
    required this.meters,
    required this.minutes,
    required this.lap,
    required this.updatedAt,
  });

  final int userId;
  final int trackId;
  final int meters;
  final int minutes;
  final int lap;
  final String? updatedAt;

  factory UserTrackRunDto.fromJson(Map<String, dynamic> json) => UserTrackRunDto(
        userId: JsonUtils.asInt(json['user_id']) ?? 0,
        trackId: JsonUtils.asInt(json['track_id']) ?? 0,
        meters: JsonUtils.asInt(json['meters']) ?? 0,
        minutes: JsonUtils.asInt(json['minutes']) ?? 0,
        lap: JsonUtils.asInt(json['lap']) ?? 0,
        updatedAt: JsonUtils.asString(json['updated_at']),
      );
}
