import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_session.dart';

class AuthStorage {
  AuthStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _sessionKey = 'auth.session';

  final FlutterSecureStorage _storage;

  Future<AuthSession?> readSession() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AuthSession.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> writeSession(AuthSession session) async {
    final json = jsonEncode(session.toJson());
    await _storage.write(key: _sessionKey, value: json);
  }

  Future<void> clear() async {
    await _storage.delete(key: _sessionKey);
  }
}
