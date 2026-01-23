import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/shared/models/user_run_stats_dto.dart';
import 'package:cyberdriver/shared/models/user_run_stats_extend_dto.dart';

class UserRunStatsApi {
  UserRunStatsApi(this._client);

  final RestApiClient _client;

  Future<UserRunStatsDto> getRunStats(String token) async {
    final response = await _client.get<UserRunStatsDto>(
      'users/stats/run',
      headers: {'Authorization': 'Bearer $token'},
      parse: (json) => UserRunStatsDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<UserRunStatsDto> getRunStatsWithAuth(AuthService auth) {
    return auth.withAuth(getRunStats);
  }

  Future<UserRunStatsExtendDto> getRunStatsExtend(String token) async {
    final response = await _client.get<UserRunStatsExtendDto>(
      'users/stats/run/extend',
      headers: {'Authorization': 'Bearer $token'},
      parse: (json) =>
          UserRunStatsExtendDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<UserRunStatsExtendDto> getRunStatsExtendWithAuth(AuthService auth) {
    return auth.withAuth(getRunStatsExtend);
  }
}
