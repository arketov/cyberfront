import 'dart:io';

import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/api_exception.dart';
import 'package:cyberdriver/core/network/rest_api_client.dart';
import 'package:cyberdriver/shared/models/json_utils.dart';
import 'package:http/http.dart' as http;

class AdminNewsApi {
  AdminNewsApi(this._client);

  final RestApiClient _client;

  Future<int> createNewsWithAuth(
    AuthService auth, {
    required String title,
    required String body,
  }) {
    return auth.withAuth((token) async {
      final response = await _client.post<Map<String, dynamic>>(
        'admin/news',
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'title': title,
          'body': body,
        },
        parse: (json) => json as Map<String, dynamic>,
      );
      final id = JsonUtils.asInt(response.data['id'] ?? response.data['news_id']);
      if (id == null || id <= 0) {
        throw ApiException(statusCode: 500, message: 'Missing news id');
      }
      return id;
    });
  }

  Future<void> uploadImageWithAuth(
    AuthService auth,
    int newsId,
    File image,
  ) {
    return auth.withAuth((token) async {
      final uri = Uri.parse('${_client.baseUrl}admin/news/$newsId/images');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Image upload failed',
          body: response.body,
          uri: uri,
        );
      }
    });
  }
}
