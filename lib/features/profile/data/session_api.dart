import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/shared/models/session_dto.dart';
import 'package:cyberdriver/shared/models/json_utils.dart';

class SessionPageDto {
  const SessionPageDto({
    required this.count,
    required this.currentPage,
    required this.maxPage,
    required this.data,
  });

  final int count;
  final int currentPage;
  final int maxPage;
  final List<SessionDto> data;

  factory SessionPageDto.fromJson(Map<String, dynamic> json) => SessionPageDto(
        count: JsonUtils.asInt(json['count']) ?? 0,
        currentPage: JsonUtils.asInt(json['current_page']) ?? 0,
        maxPage: JsonUtils.asInt(json['max_page']) ?? 0,
        data: (json['data'] as List<dynamic>? ?? const [])
            .map((e) => SessionDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class SessionApi {
  SessionApi(this._client);

  final RestApiClient _client;

  Future<SessionPageDto> getSessionsWithAuth(
    AuthService auth, {
    int? page,
  }) {
    return auth.withAuth((token) async {
      final response = await _client.get<SessionPageDto>(
        'session',
        queryParameters: {if (page != null) 'page': page},
        headers: {'Authorization': 'Bearer $token'},
        parse: (json) => SessionPageDto.fromJson(json as Map<String, dynamic>),
      );
      return response.data;
    });
  }
}
