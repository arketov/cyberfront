import 'package:shared_preferences/shared_preferences.dart';

import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/network/network.dart';

import 'auth_session.dart';
import 'auth_storage.dart';

class AuthService {
  AuthService._(this._client, this._storage);

  static AuthService? _instance;

  static Future<AuthService> getInstance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    final storage = AuthStorage(prefs);
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
    _session = _storage.readSession();
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
    final token = _session?.accessToken ?? _storage.readSession()?.accessToken;
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

  Future<void> logout() async {
    final token = _session?.accessToken ?? _storage.readSession()?.accessToken;
    if (token != null && token.isNotEmpty) {
      await _client.post<Map<String, dynamic>>(
        'auth/logout',
        headers: {'Authorization': 'Bearer $token'},
      );
    }
    _session = null;
    await _storage.clear();
  }
}
