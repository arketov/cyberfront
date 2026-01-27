import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/shared/models/reg_token_dto.dart';
import 'package:cyberdriver/shared/models/json_utils.dart';

class RegTokensPageDto {
  const RegTokensPageDto({
    required this.count,
    required this.currentPage,
    required this.maxPage,
    required this.data,
  });

  final int count;
  final int currentPage;
  final int maxPage;
  final List<RegTokenDto> data;

  factory RegTokensPageDto.fromJson(Map<String, dynamic> json) =>
      RegTokensPageDto(
        count: JsonUtils.asInt(json['count']) ?? 0,
        currentPage: JsonUtils.asInt(json['current_page']) ?? 0,
        maxPage: JsonUtils.asInt(json['max_page']) ?? 0,
        data: (json['data'] as List<dynamic>? ?? const [])
            .map((e) => RegTokenDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class AdminRegTokensApi {
  AdminRegTokensApi(this._client);

  final RestApiClient _client;

  Future<RegTokensPageDto> getTokensWithAuth(
    AuthService auth, {
    int? page,
  }) {
    return auth.withAuth((token) async {
      final response = await _client.get<RegTokensPageDto>(
        'auth/reg-tokens',
        queryParameters: {if (page != null) 'page': page},
        headers: {'Authorization': 'Bearer $token'},
        parse: (json) => RegTokensPageDto.fromJson(json as Map<String, dynamic>),
      );
      return response.data;
    });
  }

  Future<void> createTokenWithAuth(
    AuthService auth, {
    required String regToken,
    required String descr,
  }) {
    return auth.withAuth((token) async {
      await _client.post<void>(
        'auth/reg-tokens',
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'reg_token': regToken,
          'descr': descr,
        },
        parse: (_) {},
      );
    });
  }

  Future<void> deleteTokenWithAuth(
    AuthService auth,
    String regToken,
  ) {
    return auth.withAuth((token) async {
      final safeToken = Uri.encodeComponent(regToken);
      await _client.delete<void>(
        'auth/reg-tokens/$safeToken',
        headers: {'Authorization': 'Bearer $token'},
        parse: (_) {},
      );
    });
  }
}
