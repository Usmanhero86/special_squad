import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import '../core/api_client.dart';
import '../core/auth_storage.dart';
import '../models/duty_member.dart';
import '../models/getAllMember.dart';
import '../models/member_overview.dart';
import '../models/membersDetails.dart';

class MemberServices {
  final ApiClient api;

  MemberServices({required this.api});

  /// ==============================
  /// ADD MEMBER (MULTIPART)
  /// ==============================
  Future<void> addMember({
    required Map<String, dynamic> payload,
    File? photoFile,
  }) async {
    final accessToken = await AuthStorage.getAccessToken();

    if (accessToken == null) {
      throw Exception('Session expired. Please login again.');
    }

    final uri = Uri.parse('${api.baseUrl}/api/v1/admin/member');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $accessToken';

    /// Text fields
    payload.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    /// Optional image
    if (photoFile != null) {
      final extension = path.extension(photoFile.path).toLowerCase();

      final mediaType = switch (extension) {
        '.jpg' || '.jpeg' => MediaType('image', 'jpeg'),
        '.png' => MediaType('image', 'png'),
        '.gif' => MediaType('image', 'gif'),
        _ => throw Exception('Unsupported image type: $extension'),
      };

      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photoFile.path,
          contentType: mediaType,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('ADD MEMBER STATUS: ${response.statusCode}');
    debugPrint('ADD MEMBER BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to add member',
      );
    }
  }

  /// ==============================
  /// MEMBER OVERVIEW
  /// ==============================
  Future<MemberOverview> getMemberOverview() async {
    final response = await api.get(
      '/api/v1/admin/member/overview',
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch member overview',
      );
    }

    return MemberOverview.fromJson(data['responseBody']);
  }

  /// ==============================
  /// GET MEMBERS (PAGINATED)
  /// ==============================
  Future<List<Members>> getMembers({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await api.get(
      '/api/v1/admin/member?page=$page&limit=$limit',
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch members',
      );
    }

    final List list = data['responseBody']['data'];
    return list.map((e) => Members.fromJson(e)).toList();
  }

  /// ==============================
  /// GET MEMBER BY ID
  /// ==============================
  Future<MemberDetail> getMemberById(String memberId) async {
    final response = await api.get(
      '/api/v1/admin/member/$memberId',
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch member',
      );
    }

    return MemberDetail.fromJson(data['responseBody']);
  }

  /// ==============================
  /// GET DUTY MEMBERS
  /// ==============================
  Future<List<Members>> getDutyMembers() async {
    final response = await api.get(
      '/api/v1/admin/duty/members',
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch duty members',
      );
    }

    final List list = data['responseBody']['data'];
    return list.map((e) => Members.fromJson(e)).toList();
  }
  /// ===============================
  /// GET DUTY MEMBERS (FROM API)
  /// ===============================
  Future<List<DutyMember>> getAllDutyMembers() async {
    debugPrint('🟡 FETCHING DUTY MEMBERS');

    final response = await api.get('/api/v1/admin/duty/members');

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch duty members');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Request failed');
    }

    final List list = data['responseBody']['data'];

    return list.map((e) => DutyMember.fromJson(e)).toList();
  }
}