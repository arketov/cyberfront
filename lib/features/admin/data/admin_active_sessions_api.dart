import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/shared/models/json_utils.dart';

class ActiveSessionDto {
  const ActiveSessionDto({
    required this.externalCarId,
    required this.externalTrackId,
    required this.assistantToken,
    required this.userId,
    required this.beatAtUtc,
  });

  final String externalCarId;
  final String externalTrackId;
  final String assistantToken;
  final int userId;
  final String beatAtUtc;

  factory ActiveSessionDto.fromJson(Map<String, dynamic> json) =>
      ActiveSessionDto(
        externalCarId: JsonUtils.asString(json['external_car_id']) ?? '',
        externalTrackId: JsonUtils.asString(json['external_track_id']) ?? '',
        assistantToken: JsonUtils.asString(json['assistant_token']) ?? '',
        userId: JsonUtils.asInt(json['user_id']) ?? 0,
        beatAtUtc: JsonUtils.asString(json['beat_at_utc']) ?? '',
      );
}

class UserMiniDto {
  const UserMiniDto({
    required this.login,
    required this.name,
    required this.imageHash,
  });

  final String login;
  final String name;
  final String imageHash;

  factory UserMiniDto.fromJson(Map<String, dynamic> json) => UserMiniDto(
        login: JsonUtils.asString(json['login']) ?? '',
        name: JsonUtils.asString(json['name']) ?? '',
        imageHash: JsonUtils.asString(json['image_hash']) ?? '',
      );
}

class AdminActiveSessionsApi {
  AdminActiveSessionsApi(this._client);

  final RestApiClient _client;

  Future<List<ActiveSessionDto>> getActiveSessionsWithAuth(
    AuthService auth,
    String appToken,
  ) {
    return auth.withAuth((token) async {
      final response = await _client.get<List<ActiveSessionDto>>(
        'session/active',
        queryParameters: {'app_token': appToken},
        headers: {'Authorization': 'Bearer $token'},
        parse: (json) => (json as List<dynamic>? ?? const [])
            .map((e) => ActiveSessionDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return response.data;
    });
  }

  Future<int> getCarIdByExternalWithAuth(
    AuthService auth,
    String externalId,
  ) {
    return auth.withAuth((token) async {
      final safe = Uri.encodeComponent(externalId);
      final response = await _client.get<int>(
        'cars/id/$safe',
        headers: {'Authorization': 'Bearer $token'},
        parse: (json) => JsonUtils.asInt(json is Map ? json['id'] : null) ?? 0,
      );
      return response.data;
    });
  }

  Future<int> getTrackIdByExternalWithAuth(
    AuthService auth,
    String externalId,
  ) {
    return auth.withAuth((token) async {
      final safe = Uri.encodeComponent(externalId);
      final response = await _client.get<int>(
        'tracks/id/$safe',
        headers: {'Authorization': 'Bearer $token'},
        parse: (json) => JsonUtils.asInt(json is Map ? json['id'] : null) ?? 0,
      );
      return response.data;
    });
  }

  Future<UserMiniDto> getUserByIdWithAuth(
    AuthService auth,
    int userId,
  ) {
    return auth.withAuth((token) async {
      final response = await _client.get<UserMiniDto>(
        'users/$userId',
        headers: {'Authorization': 'Bearer $token'},
        parse: (json) => UserMiniDto.fromJson(json as Map<String, dynamic>),
      );
      return response.data;
    });
  }
}
