import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  /// ======================
  /// GET
  /// ======================
  Future<http.Response> get(String path) async {
    return _send(
      method: 'GET',
      path: path,
    );
  }

  /// ======================
  /// POST
  /// ======================
  Future<http.Response> post(
      String path, {
        Object? body,
      }) async {
    return _send(
      method: 'POST',
      path: path,
      body: body,
    );
  }

  /// ======================
  /// CORE REQUEST HANDLER
  /// ======================
  Future<http.Response> _send({
    required String method,
    required String path,
    Object? body,
  }) async {
    String? accessToken = await AuthStorage.getAccessToken();

    http.Response response = await _makeRequest(
      method: method,
      path: path,
      body: body,
      accessToken: accessToken,
    );

    // 🔁 Token expired → refresh
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();

      if (!refreshed) {
        await AuthStorage.clear();
        throw Exception('Session expired. Please login again.');
      }

      accessToken = await AuthStorage.getAccessToken();

      response = await _makeRequest(
        method: method,
        path: path,
        body: body,
        accessToken: accessToken,
      );
    }

    return response;
  }

  /// ======================
  /// ACTUAL HTTP CALL
  /// ======================
  Future<http.Response> _makeRequest({
    required String method,
    required String path,
    Object? body,
    String? accessToken,
  }) {
    final uri = Uri.parse('$baseUrl$path');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    switch (method) {
      case 'POST':
        return http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );

      case 'GET':
      default:
        return http.get(
          uri,
          headers: headers,
        );
    }
  }

  /// ======================
  /// REFRESH TOKEN
  /// ======================
  Future<bool> _refreshToken() async {
    final refreshToken = await AuthStorage.getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/admin/auth/refresh/token'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['responseSuccessful'] == true) {
        final newAccessToken = data['responseBody']['accessToken'];
        await AuthStorage.saveAccessToken(newAccessToken);
        return true;
      }
    }

    return false;
  }
}