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
  Future<User> login({required String email, required String password}) async {
    try {
      debugPrint('🟡 AuthService.login() called');
      debugPrint('📧 Email: $email');
      debugPrint('🔗 API URL: ${api.baseUrl}/api/v1/admin/auth/login');

      final response = await api.post(
        '/api/v1/admin/auth/login',
        body: {'email': email, 'password': password},
      );

      debugPrint('🟡 LOGIN STATUS: ${response.statusCode}');
      debugPrint('📥 LOGIN BODY: ${response.body}');

      if (response.statusCode != 200) {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        throw Exception(
          'Server error: ${response.statusCode}. Please try again.',
        );
      }

      final Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        debugPrint('❌ JSON Parse Error: $e');
        throw Exception('Invalid server response. Please try again.');
      }

      debugPrint('📊 Response Data: $data');

      if (data['responseSuccessful'] != true) {
        final message = data['responseMessage'] ?? 'Login failed';
        debugPrint('❌ API Error: $message');
        throw Exception(message);
      }

      final responseBody = data['responseBody'];
      if (responseBody == null) {
        debugPrint('❌ Missing response body');
        throw Exception('Invalid server response. Please try again.');
      }

      final userJson = responseBody['user'];
      if (userJson == null) {
        debugPrint('❌ Missing user data');
        throw Exception('Invalid user data received. Please try again.');
      }

      final user = User.fromJson(userJson);
      debugPrint('✅ User created: ${user.fullName}');

      // ✅ SAVE TOKENS USING AuthStorage
      final accessToken = responseBody['accessToken'];
      final refreshToken = responseBody['refreshToken'];

      if (accessToken == null || refreshToken == null) {
        debugPrint('❌ Missing tokens');
        throw Exception('Authentication tokens missing. Please try again.');
      }

      await AuthStorage.saveAccessToken(accessToken);
      await AuthStorage.saveRefreshToken(refreshToken);

      // ✅ SAVE USER INFO (OPTIONAL BUT USEFUL)
      await AuthStorage.saveUserName(user.fullName);
      await AuthStorage.saveUserRole(user.role);

      debugPrint('✅ Login successful for: ${user.fullName}');
      return user;
    } catch (e) {
      debugPrint('❌ AuthService.login() error: $e');
      rethrow;
    }
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
