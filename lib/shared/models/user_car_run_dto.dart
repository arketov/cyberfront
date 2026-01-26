import 'json_utils.dart';

class UserCarRunDto {
  const UserCarRunDto({
    required this.userId,
    required this.carId,
    required this.meters,
    required this.minutes,
    required this.lap,
    required this.updatedAt,
  });

  final int userId;
  final int carId;
  final int meters;
  final int minutes;
  final int lap;
  final String? updatedAt;

  factory UserCarRunDto.fromJson(Map<String, dynamic> json) => UserCarRunDto(
        userId: JsonUtils.asInt(json['user_id']) ?? 0,
        carId: JsonUtils.asInt(json['car_id']) ?? 0,
        meters: JsonUtils.asInt(json['meters']) ?? 0,
        minutes: JsonUtils.asInt(json['minutes']) ?? 0,
        lap: JsonUtils.asInt(json['lap']) ?? 0,
        updatedAt: JsonUtils.asString(json['updated_at']),
      );
}
