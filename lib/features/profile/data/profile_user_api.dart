import 'dart:convert';
import 'dart:typed_data';

import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/api_exception.dart';
import 'package:cyberdriver/core/network/rest_api_client.dart';
import 'package:cyberdriver/shared/models/user_dto.dart';
import 'package:http/http.dart' as http;

class ProfileUserApi {
  ProfileUserApi(this._client);

  final RestApiClient _client;

  Future<UserDto> updateProfileWithAuth(
    AuthService auth, {
    required String name,
  }) {
    return auth.withAuth((token) async {
      final response = await _client.request<Map<String, dynamic>>(
        path: 'users/me',
        method: 'PATCH',
        headers: {'Authorization': 'Bearer $token'},
        body: {'name': name},
        parse: (json) => json as Map<String, dynamic>,
      );
      return UserDto.fromJson(response.data);
    });
  }

  Future<UserDto> uploadImageWithAuth(
    AuthService auth,
    Uint8List bytes, {
    String filename = 'avatar.jpg',
  }) {
    return auth.withAuth((token) async {
      final uri = Uri.parse('${_client.baseUrl}users/me/image');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';
      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: filename),
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
      if (response.body.isEmpty) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Missing user response',
          body: response.body,
          uri: uri,
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Invalid user response',
          body: response.body,
          uri: uri,
        );
      }
      return UserDto.fromJson(decoded);
    });
  }
}
