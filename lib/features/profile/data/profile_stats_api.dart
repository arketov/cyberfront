import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/shared/models/user_stats_dto.dart';

class ProfileStatsApi {
  ProfileStatsApi(this._client);

  final RestApiClient _client;

  Future<UserStatsDto> getStats(String token) async {
    final response = await _client.get<UserStatsDto>(
      'users/stats',
      headers: {'Authorization': 'Bearer $token'},
      parse: (json) => UserStatsDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<UserStatsDto> getStatsWithAuth(AuthService auth) {
    return auth.withAuth(getStats);
  }
}
