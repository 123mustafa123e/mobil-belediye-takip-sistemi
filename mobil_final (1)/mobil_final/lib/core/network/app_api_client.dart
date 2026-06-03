import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class AppApiClient {
  AppApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl => AppConstants.baseUrl;

  Map<String, String> _headers({String? token}) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<http.Response> get(String path, {String? token}) async {
    return _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token: token),
    );
  }

  Future<http.Response> post(String path, {Object? body, String? token}) async {
    return _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token: token),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> put(String path, {Object? body, String? token}) async {
    return _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token: token),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<T> readJson<T>(String path, {String? token}) async {
    final response = await get(path, token: token);

    if (response.statusCode >= 400) {
      throw Exception(
        'GET $path başarısız: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as T;
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    String? token,
  }) async {
    final response = await post(path, body: body, token: token);

    if (response.statusCode >= 400) {
      throw Exception(
        'POST $path başarısız: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Object? body,
    String? token,
  }) async {
    final response = await put(path, body: body, token: token);

    if (response.statusCode >= 400) {
      throw Exception(
        'PUT $path başarısız: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
