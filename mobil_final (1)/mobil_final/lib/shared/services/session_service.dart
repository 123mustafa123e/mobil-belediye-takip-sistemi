import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ariza_model.dart';
import '../models/user_model.dart';

class SessionService {
  SessionService(this._prefs);

  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _roleKey = 'auth_role';
  static const String _cacheKey = 'cached_arizalar';

  Future<void> saveSession({
    required UserModel user,
    required String token,
    required String role,
  }) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    await _prefs.setString(_roleKey, role);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    await _prefs.remove(_roleKey);
  }

  String? get token => _prefs.getString(_tokenKey);

  UserModel? get user {
    final raw = _prefs.getString(_userKey);
    if (raw == null) {
      return null;
    }

    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  String? get role => _prefs.getString(_roleKey);

  Future<void> cacheArizalar(List<ArizaModel> arizalar) async {
    await _prefs.setString(
      _cacheKey,
      jsonEncode(arizalar.map((ariza) => ariza.toJson()).toList()),
    );
  }

  List<ArizaModel> getCachedArizalar() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) {
      return <ArizaModel>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ArizaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  bool get hasSession => token != null && user != null;
}
