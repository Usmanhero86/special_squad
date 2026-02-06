import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/auth_storage.dart';

/// ===============================
/// USER MODEL
/// ===============================
class User {
  final String id;
  final String email;
  final String fullName;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['name'] ?? 'Admin',
      role: json['role'] ?? 'User',
    );
  }
}

/// ===============================
/// AUTH SERVICE (API CLIENT BASED)
/// ===============================
class AuthService {
  final ApiClient api;

  AuthService({required this.api});

  /// ===============================
  /// LOGIN
  /// ===============================
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await api.post(
      '/api/v1/admin/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    debugPrint('🟡 LOGIN STATUS: ${response.statusCode}');
    debugPrint('📥 LOGIN BODY: ${response.body}');

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Login failed');
    }

    final responseBody = data['responseBody'];
    final userJson = responseBody['user'];

    final user = User.fromJson(userJson);

    // ✅ SAVE TOKENS USING AuthStorage
    await AuthStorage.saveAccessToken(responseBody['accessToken']);
    await AuthStorage.saveRefreshToken(responseBody['refreshToken']);

    // ✅ SAVE USER INFO (OPTIONAL BUT USEFUL)
    await AuthStorage.saveUserName(user.fullName);
    await AuthStorage.saveUserRole(user.role);

    return user;
  }

  /// ===============================
  /// LOGOUT
  /// ===============================
  Future<void> logout() async {
    await AuthStorage.clear();
  }

  /// ===============================
  /// CHECK AUTH STATE
  /// ===============================
  Future<bool> isLoggedIn() async {
    final token = await AuthStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}