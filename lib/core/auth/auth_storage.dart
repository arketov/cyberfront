import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_session.dart';

class AuthStorage {
  AuthStorage(this._prefs);

  static const _sessionKey = 'auth.session';

  final SharedPreferences _prefs;

  AuthSession? readSession() {
    final raw = _prefs.getString(_sessionKey);
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
    await _prefs.setString(_sessionKey, json);
  }

  Future<void> clear() async {
    await _prefs.remove(_sessionKey);
  }
}
