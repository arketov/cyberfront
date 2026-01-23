import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/core/utils/logger.dart';

import 'auth_session.dart';
import 'auth_storage.dart';

class AuthService {
  AuthService._(this._client, this._storage);

  static AuthService? _instance;

  static Future<AuthService> getInstance() async {
    if (_instance != null) return _instance!;
    final storage = AuthStorage();
    final client = createApiClient(AppConfig.dev);
    _instance = AuthService._(client, storage);
    return _instance!;
  }

  final RestApiClient _client;
  final AuthStorage _storage;

  AuthSession? _session;

  AuthSession? get session => _session;
  bool get isLoggedIn => _session != null;

  Future<void> loadSession() async {
    _session = await _storage.readSession();
  }

  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post<AuthSession>(
      'auth/login',
      body: {
        'username': username,
        'password': password,
      },
      parse: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
    _session = response.data;
    await _storage.writeSession(_session!);
    return _session!;
  }

  Future<AuthSession> refresh() async {
    final stored = await _storage.readSession();
    final token = _session?.accessToken ?? stored?.accessToken;
    if (token == null || token.isEmpty) {
      throw ApiException(statusCode: 401, message: 'Missing token');
    }

    final response = await _client.post<AuthSession>(
      'auth/refresh',
      headers: {'Authorization': 'Bearer $token'},
      body: {'token': token},
      parse: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
    _session = response.data;
    await _storage.writeSession(_session!);
    return _session!;
  }

  Future<T> withAuth<T>(Future<T> Function(String token) action) async {
    final stored = await _storage.readSession();
    final token = _session?.accessToken ?? stored?.accessToken;
    if (token == null || token.isEmpty) {
      throw ApiException(statusCode: 401, message: 'Missing token');
    }

    try {
      return await action(token);
    } on ApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
    }

    try {
      final refreshed = await refresh();
      return await action(refreshed.accessToken);
    } catch (error, stackTrace) {
      logger.severe('Auth refresh failed', error, stackTrace);
      await logout();
      rethrow;
    }
  }

  Future<void> logout() async {
    final stored = await _storage.readSession();
    final token = _session?.accessToken ?? stored?.accessToken;
    if (token != null && token.isNotEmpty) {
      try {
        await _client.post<Map<String, dynamic>>(
          'auth/logout',
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (error, stackTrace) {
        logger.warning('Logout failed', error, stackTrace);
      }
    }
    _session = null;
    await _storage.clear();
  }
}
