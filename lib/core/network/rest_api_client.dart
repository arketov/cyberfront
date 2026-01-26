import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'api_response.dart';
import '../utils/logger.dart';

/// Minimal REST API client with JSON helpers and simple error handling.
class RestApiClient {
  RestApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    Map<String, String>? defaultHeaders,
  })  : _httpClient = httpClient ?? http.Client(),
        defaultHeaders = {
          'Accept': 'application/json',
          if (defaultHeaders != null) ...defaultHeaders,
        };

  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final http.Client _httpClient;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parse,
  }) {
    return request(
      path: path,
      method: 'GET',
      headers: headers,
      queryParameters: queryParameters,
      parse: parse,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    T Function(dynamic json)? parse,
  }) {
    return request(
      path: path,
      method: 'POST',
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      parse: parse,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    T Function(dynamic json)? parse,
  }) {
    return request(
      path: path,
      method: 'PUT',
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      parse: parse,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    T Function(dynamic json)? parse,
  }) {
    return request(
      path: path,
      method: 'DELETE',
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      parse: parse,
    );
  }

  Future<ApiResponse<T>> request<T>({
    required String path,
    String method = 'GET',
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    T Function(dynamic json)? parse,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final mergedHeaders = {
      ...defaultHeaders,
      if (headers != null) ...headers,
    };

    final encodedBody = _encodeBody(body, mergedHeaders);
    final upperMethod = method.toUpperCase();
    logger.info('API -> $upperMethod $uri${body != null ? ' (body)' : ''}');

    final request = http.Request(upperMethod, uri)
      ..headers.addAll(mergedHeaders);
    if (encodedBody != null) {
      request.body = encodedBody;
    }

    try {
      final streamed = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response, uri, upperMethod, parse);
    } catch (error, stackTrace) {
      logger.warning('API !! $upperMethod $uri failed', error, stackTrace);
      rethrow;
    }
  }

  void close() => _httpClient.close();

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final baseUri = Uri.parse(baseUrl);
    final resolved = baseUri.resolve(path);
    if (query == null || query.isEmpty) {
      return resolved;
    }

    final encodedQuery = {
      ...resolved.queryParameters,
      for (final entry in query.entries) entry.key: '${entry.value}',
    };
    return resolved.replace(queryParameters: encodedQuery);
  }

  String? _encodeBody(Object? body, Map<String, String> headers) {
    if (body == null) return null;
    if (body is String) return body;
    if (body is List || body is Map) {
      headers.putIfAbsent('Content-Type', () => 'application/json');
      return jsonEncode(body);
    }
    return body.toString();
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    Uri uri,
    String method,
    T Function(dynamic json)? parse,
  ) {
    final decoded = _tryDecode(response.body);
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

    if (isSuccess) {
      if (parse != null) {
        try {
          final parsed = parse(decoded);
          logger.info('API <- ${response.statusCode} $method $uri');
          return ApiResponse(
            statusCode: response.statusCode,
            data: parsed,
            rawBody: response.body,
            headers: response.headers,
          );
        } catch (error, stackTrace) {
          logger.severe('Failed to parse response: $uri', error, stackTrace);
          throw ApiException(
            statusCode: response.statusCode,
            message: 'Failed to parse response',
            body: response.body,
            uri: uri,
          );
        }
      }
      logger.info('API <- ${response.statusCode} $method $uri');
      return ApiResponse(
        statusCode: response.statusCode,
        data: decoded as T,
        rawBody: response.body,
        headers: response.headers,
      );
    }

    final message = _errorMessage(decoded, response.statusCode);
    logger.warning(
      'API !! ${response.statusCode} $method $uri - $message | body: ${response.body}',
    );
    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      body: response.body,
      uri: uri,
    );
  }

  dynamic _tryDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _errorMessage(dynamic decoded, int statusCode) {
    if (decoded is Map && decoded['message'] is String) {
      return decoded['message'] as String;
    }
    if (decoded is Map && decoded['detail'] is String) {
      return decoded['detail'] as String;
    }
    if (decoded is Map && decoded['error'] is String) {
      return decoded['error'] as String;
    }
    return 'Request failed with status $statusCode';
  }
}
