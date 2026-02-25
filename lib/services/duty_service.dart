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
      body: {'postName': postName},
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
      throw Exception(data['responseMessage'] ?? 'Failed to fetch duty posts');
    }

    final List list = data['responseBody']['data'] ?? [];

    // If no posts found for this date, try fetching all posts without date filter
    if (list.isEmpty) {
      debugPrint(
        '⚠️ No duty posts for date $formattedDate, fetching all posts...',
      );
      return await getAllDutyPosts(page: page, limit: limit);
    }

    return list.map((e) => DutyPost.fromJson(e)).toList();
  }

  /// ===============================
  /// GET ALL DUTY POSTS (WITHOUT DATE FILTER)
  /// ===============================
  Future<List<DutyPost>> getAllDutyPosts({int page = 1, int limit = 10}) async {
    final endpoint = '/api/v1/admin/duty?page=$page&limit=$limit';

    debugPrint('🟡 FETCH ALL DUTY POSTS (NO DATE FILTER)');
    debugPrint('📍 FULL URL: ${api.baseUrl}$endpoint');

    final response = await api.get(endpoint);

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Failed to fetch duty posts');
    }

    final List list = data['responseBody']['data'] ?? [];
    debugPrint('✅ ALL DUTY POSTS FETCHED: ${list.length}');
    return list.map((e) => DutyPost.fromJson(e)).toList();
  }

  /// ===============================
  /// GET ASSIGNED MEMBERS
  /// ===============================
  Future<List<DutyAssignment>> getAssignedMembers(String dutyPostId) async {
    final response = await api.get('/api/v1/admin/duty/assign/$dutyPostId');

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

  /// ===============================
  /// DELETE DUTY POST
  /// ===============================
  Future<void> deleteDutyPost(String dutyPostId) async {
    debugPrint('🟡 DELETING DUTY POST: $dutyPostId');

    try {
      final response = await api.delete('/api/v1/admin/duty/$dutyPostId');

      debugPrint('📥 DELETE STATUS: ${response.statusCode}');
      debugPrint('📥 DELETE BODY: ${response.body}');

      // Some APIs return 204 No Content for successful deletion
      if (response.statusCode == 204) {
        debugPrint('✅ Duty post deleted successfully (204 No Content)');
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          data['responseMessage'] ?? 'Failed to delete duty post',
        );
      }

      if (data['responseSuccessful'] != true) {
        throw Exception(data['responseMessage'] ?? 'Delete request failed');
      }

      debugPrint('✅ Duty post deleted successfully');
    } catch (e) {
      debugPrint('🔥 DELETE DUTY POST ERROR: $e');
      rethrow;
    }
  }

  /// ===============================
  /// UPDATE DUTY POST
  /// ===============================
  Future<DutyPost> updateDutyPost({
    required String dutyPostId,
    required String postName,
    String? description,
  }) async {
    debugPrint('🟡 UPDATING DUTY POST: $dutyPostId');
    debugPrint('📤 POST NAME: $postName');
    debugPrint('📤 DESCRIPTION: $description');

    try {
      final response = await api.patch(
        '/api/v1/admin/duty/$dutyPostId',
        body: {
          'postName': postName,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );

      debugPrint('📥 UPDATE STATUS: ${response.statusCode}');
      debugPrint('📥 UPDATE BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          data['responseMessage'] ?? 'Failed to update duty post',
        );
      }

      if (data['responseSuccessful'] != true) {
        throw Exception(data['responseMessage'] ?? 'Update request failed');
      }

      debugPrint('✅ Duty post updated successfully');
      return DutyPost.fromJson(data['responseBody']);
    } catch (e) {
      debugPrint('🔥 UPDATE DUTY POST ERROR: $e');
      rethrow;
    }
  }

  /// ===============================
  /// DELETE DUTY ASSIGNMENT
  /// ===============================
  Future<void> deleteDutyAssignment(String assignmentId) async {
    debugPrint('🟡 DELETING DUTY ASSIGNMENT: $assignmentId');

    try {
      // Use the correct endpoint: /api/v1/admin/duty/assign/{assignmentId}
      final response = await api.delete(
        '/api/v1/admin/duty/assign/$assignmentId',
      );

      debugPrint('📥 DELETE ASSIGNMENT STATUS: ${response.statusCode}');
      debugPrint('📥 DELETE ASSIGNMENT BODY: ${response.body}');

      // Handle HTML error responses (like 404 pages)
      if (response.body.trim().startsWith('<!DOCTYPE html>') ||
          response.body.trim().startsWith('<html')) {
        debugPrint('🔥 Server returned HTML error page instead of JSON');
        debugPrint(
          '🔥 This usually means the endpoint does not exist or method is not allowed',
        );
        throw Exception(
          'API endpoint not found. Please verify the endpoint is: DELETE /api/v1/admin/duty/assign/{assignmentId}',
        );
      }

      // Some APIs return 204 No Content for successful deletion
      if (response.statusCode == 204) {
        debugPrint('✅ Duty assignment deleted successfully (204 No Content)');
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          data['responseMessage'] ?? 'Failed to delete duty assignment',
        );
      }

      if (data['responseSuccessful'] != true) {
        throw Exception(data['responseMessage'] ?? 'Delete request failed');
      }

      debugPrint('✅ Duty assignment deleted successfully');
    } catch (e) {
      debugPrint('🔥 DELETE DUTY ASSIGNMENT ERROR: $e');
      rethrow;
    }
  }
}
