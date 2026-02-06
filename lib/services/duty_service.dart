import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/duty_post.dart';
import '../models/duty_assignment.dart';
import '../models/getAllMember.dart';

class DutyService {
  final ApiClient api;

  DutyService({required this.api});

  /// ===============================
  /// ADD DUTY POST
  /// ===============================
  Future<DutyPost> addDutyPost(String postName) async {
    final response = await api.post(
      '/api/v1/admin/duty',
      body: {
        'postName': postName,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['responseMessage'] ?? 'Failed to create duty post');
    }

    return DutyPost.fromJson(data['responseBody']);
  }

  /// ===============================
  /// GET DUTY POSTS (WITH DATE FILTER ✅)
  Future<List<DutyPost>> getDutyPosts({
    int page = 1,
    int limit = 10,
    required DateTime date,
  }) async {
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final endpoint =
        '/api/v1/admin/duty?page=$page&limit=$limit&date=$formattedDate';

    // ✅ PRINT EXACT URL BEING HIT
    debugPrint('🟡 FETCH DUTY POSTS');
    debugPrint('📍 FULL URL: ${api.baseUrl}$endpoint');
    debugPrint('📍 DATE: $formattedDate');

    final response = await api.get(endpoint);

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch duty posts',
      );
    }

    final List list = data['responseBody']['data'] ?? [];
    return list.map((e) => DutyPost.fromJson(e)).toList();
  }

  /// ===============================
  /// GET ASSIGNED MEMBERS
  /// ===============================
  Future<List<DutyAssignment>> getAssignedMembers(String dutyPostId) async {
    final response =
    await api.get('/api/v1/admin/duty/assign/$dutyPostId');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch assigned members',
      );
    }

    final List list = data['responseBody'] ?? [];
    return list.map((e) => DutyAssignment.fromJson(e)).toList();
  }

  /// ===============================
  /// GET DUTY MEMBERS
  /// ===============================
  Future<List<Members>> getDutyMembers() async {
    final response = await api.get('/api/v1/admin/duty/members');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch duty members',
      );
    }

    final List list = data['responseBody']['data'] ?? [];
    return list.map((e) => Members.fromJson(e)).toList();
  }

  /// ===============================
  /// ASSIGN DUTY (ALREADY CORRECT)
  /// ===============================
  Future<bool> assignDuty({
    required String postId,
    required List<String> memberIds,
    required DateTime date,
    required String shift,
    String? notes,
  }) async {
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final response = await api.post(
      '/api/v1/admin/duty/assign',
      body: {
        'dutyPostId': postId,
        'memberIds': memberIds,
        'date': formattedDate,
        'shift': shift,
        if (notes != null) 'notes': notes,
      },
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode != 200 && response.statusCode != 201) ||
        data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Failed to assign duty');
    }

    return true;
  }
}