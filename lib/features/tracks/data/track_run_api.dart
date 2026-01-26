import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/shared/models/user_track_run_dto.dart';

class TrackRunApi {
  TrackRunApi(this._client);

  final RestApiClient _client;

  Future<UserTrackRunDto> getTrackRunWithAuth(
    AuthService auth,
    int userId,
    int trackId,
  ) {
    return auth.withAuth((token) async {
      final response = await _client.get<UserTrackRunDto>(
        'users/$userId/tracks/$trackId/run',
        headers: {'Authorization': 'Bearer $token'},
        parse: (json) => UserTrackRunDto.fromJson(json as Map<String, dynamic>),
      );
      return response.data;
    });
  }
}
