import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/shared/models/news_dto.dart';
import 'package:cyberdriver/shared/models/json_utils.dart';

class NewsPageDto {
  const NewsPageDto({
    required this.count,
    required this.currentPage,
    required this.maxPage,
    required this.data,
  });

  final int count;
  final int currentPage;
  final int maxPage;
  final List<NewsDto> data;

  factory NewsPageDto.fromJson(Map<String, dynamic> json) => NewsPageDto(
        count: JsonUtils.asInt(json['count']) ?? 0,
        currentPage: JsonUtils.asInt(json['current_page']) ?? 0,
        maxPage: JsonUtils.asInt(json['max_page']) ?? 0,
        data: (json['data'] as List<dynamic>? ?? const [])
            .map((e) => NewsDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class NewsApi {
  NewsApi(this._client);

  final RestApiClient _client;

  Future<NewsPageDto> getNewsPage({int? page}) async {
    final response = await _client.get<NewsPageDto>(
      'news',
      queryParameters: {if (page != null) 'page': page},
      parse: (json) => NewsPageDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<NewsDto> getNews(int newsId) async {
    final response = await _client.get<NewsDto>(
      'news/$newsId',
      parse: (json) => NewsDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<void> deleteNewsWithAuth(AuthService auth, int newsId) {
    return auth.withAuth((token) async {
      await _client.delete<Map<String, dynamic>>(
        'admin/news/$newsId',
        headers: {'Authorization': 'Bearer $token'},
      );
    });
  }
}
