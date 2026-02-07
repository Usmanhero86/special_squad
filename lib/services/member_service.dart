import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/api_client.dart';
import '../core/auth_storage.dart';
import '../models/member.dart';
import '../models/duty_member.dart';
import '../models/getAllMember.dart';
import '../models/member_overview.dart';
import '../models/membersDetails.dart';
import 'database_helper.dart';

class MemberService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiClient? api;
  bool _initialized = false;

  MemberService({this.api});

  Future<void> initializeDatabase() async {
    if (_initialized) return;

    try {
      // This will trigger database creation or upgrade
      await _dbHelper.database;

      // Check current schema
      final columns = await _dbHelper.getMemberTableColumns();
      debugPrint('Current member table columns: $columns');

      // Ensure location column exists
      await _dbHelper.addLocationColumnIfNotExists();

      _initialized = true;
      debugPrint('Database initialized successfully');
    } catch (e) {
      debugPrint('Error initializing database: $e');
      // If initialization fails, try to reset database
      await _resetAndInitialize();
    }
  }

  Future<void> _resetAndInitialize() async {
    try {
      debugPrint('Attempting to reset database...');
      await _dbHelper.resetDatabase();

      // Try initialization again
      await _dbHelper.database;
      _initialized = true;
      debugPrint('Database reset and initialized successfully');
    } catch (e) {
      debugPrint('Error resetting database: $e');
      throw Exception('Failed to initialize database: $e');
    }
  }

  /// ==============================
  /// API METHODS (from MemberServices)
  /// ==============================

  /// ADD MEMBER (MULTIPART)
  Future<void> addMember({
    required Map<String, dynamic> payload,
    File? photoFile,
  }) async {
    if (api == null) throw Exception('API client not available');

    final accessToken = await AuthStorage.getAccessToken();

    if (accessToken == null) {
      throw Exception('Session expired. Please login again.');
    }

    final uri = Uri.parse('${api!.baseUrl}/api/v1/admin/member');

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

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['responseMessage'] ?? 'Failed to add member');
    }
  }

  /// MEMBER OVERVIEW
  Future<MemberOverview> getMemberOverview() async {
    if (api == null) throw Exception('API client not available');

    final response = await api!.get('/api/v1/admin/member/overview');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch member overview',
      );
    }

    return MemberOverview.fromJson(data['responseBody']);
  }

  /// GET MEMBERS (PAGINATED)
  Future<List<Members>> getMembers({int page = 1, int limit = 10}) async {
    if (api == null) throw Exception('API client not available');

    final response = await api!.get(
      '/api/v1/admin/member?page=$page&limit=$limit',
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Failed to fetch members');
    }

    final List list = data['responseBody']['data'];
    return list.map((e) => Members.fromJson(e)).toList();
  }

  /// GET MEMBER BY ID
  Future<MemberDetail> getMemberById(String memberId) async {
    if (api == null) throw Exception('API client not available');

    final response = await api!.get('/api/v1/admin/member/$memberId');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Failed to fetch member');
    }

    return MemberDetail.fromJson(data['responseBody']);
  }

  /// GET DUTY MEMBERS
  Future<List<Members>> getDutyMembers() async {
    if (api == null) throw Exception('API client not available');

    final response = await api!.get('/api/v1/admin/duty/members');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch duty members',
      );
    }

    final List list = data['responseBody']['data'];
    return list.map((e) => Members.fromJson(e)).toList();
  }

  /// GET ALL DUTY MEMBERS
  Future<List<DutyMember>> getAllDutyMembers() async {
    if (api == null) throw Exception('API client not available');

    debugPrint('🟡 FETCHING DUTY MEMBERS');

    final response = await api!.get('/api/v1/admin/duty/members');

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

  /// UPDATE MEMBER (API)
  Future<void> updateMemberApi(
    String memberId,
    Map<String, dynamic> payload,
  ) async {
    if (api == null) throw Exception('API client not available');

    debugPrint('🟡 UPDATING MEMBER: $memberId');
    debugPrint('📤 FULL URL: ${api!.baseUrl}/api/v1/admin/member/$memberId');
    debugPrint('📤 PAYLOAD: ${jsonEncode(payload)}');

    try {
      final response = await api!.patch(
        '/api/v1/admin/member/$memberId',
        body: payload,
      );

      debugPrint('📥 UPDATE STATUS: ${response.statusCode}');
      debugPrint('📥 UPDATE HEADERS: ${response.headers}');
      debugPrint('📥 UPDATE BODY: ${response.body}');

      // Handle HTML error responses (like 404 pages)
      if (response.body.trim().startsWith('<!DOCTYPE html>') ||
          response.body.trim().startsWith('<html')) {
        debugPrint('🔥 Server returned HTML error page instead of JSON');
        debugPrint(
          '🔥 This usually means the endpoint does not exist or method is not allowed',
        );
        throw Exception(
          'API endpoint not found or method not allowed. Please verify the endpoint with backend team.',
        );
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Try to parse JSON error, fallback to status code
        try {
          final data = jsonDecode(response.body);
          throw Exception(data['responseMessage'] ?? 'Failed to update member');
        } catch (e) {
          throw Exception(
            'HTTP ${response.statusCode}: Failed to update member. ${e.toString()}',
          );
        }
      }

      final data = jsonDecode(response.body);

      if (data['responseSuccessful'] != true) {
        throw Exception(data['responseMessage'] ?? 'Update request failed');
      }

      debugPrint('✅ Member updated successfully');
    } catch (e) {
      debugPrint('🔥 UPDATE MEMBER ERROR: $e');
      rethrow;
    }
  }

  /// DELETE MEMBER (API)
  Future<void> deleteMemberApi(String memberId) async {
    if (api == null) throw Exception('API client not available');

    debugPrint('🟡 DELETING MEMBER: $memberId');

    try {
      final response = await api!.delete('/api/v1/admin/member/$memberId');

      debugPrint('📥 DELETE STATUS: ${response.statusCode}');
      debugPrint('📥 DELETE BODY: ${response.body}');

      // Some APIs return 204 No Content for successful deletion
      if (response.statusCode == 204) {
        return; // Success with no content
      }

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['responseMessage'] ?? 'Failed to delete member');
      }

      if (data['responseSuccessful'] != true) {
        throw Exception(data['responseMessage'] ?? 'Delete request failed');
      }
    } catch (e) {
      debugPrint('🔥 DELETE MEMBER ERROR: $e');
      rethrow;
    }
  }

  /// ==============================
  /// LOCAL DATABASE METHODS (from original MemberService)
  /// ==============================

  Future<void> addvMember(Member member, File? profileImage) async {
    // Ensure database is initialized
    if (!_initialized) {
      await initializeDatabase();
    }

    try {
      String? imageUrl;

      if (profileImage != null) {
        imageUrl = await _saveProfileImage(profileImage, member.id);
      }

      final db = await _dbHelper.database;

      // Convert additionalInfo to JSON string for storage
      String? additionalInfoJson;
      if (member.additionalInfo != null) {
        additionalInfoJson = json.encode(member.additionalInfo);
      }

      // Create the data map
      final data = <String, dynamic>{
        'id': member.id,
        'full_name': member.fullName,
        'id_number': member.idNumber,
        'phone': member.phone,
        'date_of_birth': member.dateOfBirth.millisecondsSinceEpoch,
        'address': member.address,
        'position': member.position,
        'join_date': member.joinDate.millisecondsSinceEpoch,
        'profile_image': imageUrl,
        'is_active': member.isActive ? 1 : 0,
        'additional_info': additionalInfoJson,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

      // Add location only if it's not null
      if (member.location != null) {
        data['location'] = member.location;
      }

      await db.insert('members', data);

      debugPrint('Member added successfully: ${member.fullName}');
    } catch (e) {
      debugPrint('Error adding member: $e');
      debugPrint('Member data: ${member.toMap()}');
      throw Exception('Failed to add member: $e');
    }
  }

  Future<String> _saveProfileImage(File image, String memberId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final memberDir = Directory(path.join(appDir.path, 'members', memberId));

      if (!await memberDir.exists()) {
        await memberDir.create(recursive: true);
      }

      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await image.copy(path.join(memberDir.path, fileName));

      return savedImage.path;
    } catch (e) {
      throw Exception('Failed to save profile image: $e');
    }
  }

  Stream<List<Member>> getMembersStream() async* {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'members',
        orderBy: 'join_date DESC',
      );

      final members = maps.map((map) => _memberFromMap(map)).toList();
      yield members;
    } catch (e) {
      debugPrint('Error getting members: $e');
      yield [];
    }
  }

  Future<List<Member>> getMembersSync() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'members',
        orderBy: 'join_date DESC',
      );

      return maps.map((map) => _memberFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Member>> searchMembers(String query) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'members',
        where: 'full_name LIKE ? OR id_number LIKE ? OR phone LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'full_name ASC',
      );

      return maps.map((map) => _memberFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Member?> getMemberByIdLocal(String id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'members',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return _memberFromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Member>> getMembersByLocation(String location) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'members',
        where: 'location LIKE ?',
        whereArgs: ['%$location%'],
        orderBy: 'full_name ASC',
      );

      return maps.map((map) => _memberFromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting members by location: $e');
      return [];
    }
  }

  Future<List<String>> getMemberLocations() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT DISTINCT location 
        FROM members 
        WHERE location IS NOT NULL AND location != ''
        ORDER BY location ASC
        ''');

      return maps
          .map<String>((map) => map['location']?.toString() ?? '')
          .where((location) => location.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error getting member locations: $e');
      return [];
    }
  }

  Future<void> updateMember(Member member) async {
    // Convert Member model to API payload format
    final payload = {
      'fullName': member.fullName,
      'idNo': member.idNumber,
      'rifleNo': member.rifleNumber,
      'phoneNumber': member.phone,
      'dateOfBirth': member.dateOfBirth.toUtc().toIso8601String(),
      'permanentAddress': member.address,
      'position': member.position,
      'photo': member.profileImage,
      // Add other required fields with defaults if not available
      'tribe': member.additionalInfo?['tribe'] ?? '',
      'religion': member.additionalInfo?['religion'] ?? '',
      'location': member.location ?? '',
      'gender': member.additionalInfo?['gender'] ?? 'Male',
      'maritalStatus': member.additionalInfo?['maritalStatus'] ?? '',
      'ninNo': member.additionalInfo?['ninNo'] ?? '',
      'bvnNo': member.additionalInfo?['bvnNo'] ?? '',
      'state': member.additionalInfo?['state'] ?? '',
      'accountNo': member.additionalInfo?['accountNo'] ?? '',
      'unitArea': member.additionalInfo?['unitArea'] ?? '',
      'unitAreaType': member.additionalInfo?['unitAreaType'] ?? '',
      'guarantorFullName': member.additionalInfo?['guarantorFullName'] ?? '',
      'guarantorRelationship':
          member.additionalInfo?['guarantorRelationship'] ?? '',
      'guarantorTribe': member.additionalInfo?['guarantorTribe'] ?? '',
      'guarantorPhoneNumber':
          member.additionalInfo?['guarantorPhoneNumber'] ?? '',
      'emergencyFullName': member.additionalInfo?['emergencyFullName'] ?? '',
      'emergencyAddress': member.additionalInfo?['emergencyAddress'] ?? '',
      'emergencyPhoneNumber':
          member.additionalInfo?['emergencyPhoneNumber'] ?? '',
      'nextOfKinFullName': member.additionalInfo?['nextOfKinFullName'] ?? '',
      'nextOfKinAddress': member.additionalInfo?['nextOfKinAddress'] ?? '',
      'nextOfKinPhoneNumber':
          member.additionalInfo?['nextOfKinPhoneNumber'] ?? '',
    };

    debugPrint('🔍 MEMBER UPDATE PAYLOAD DETAILS:');
    debugPrint('   Member ID: ${member.id}');
    debugPrint('   Full Name: ${member.fullName}');
    debugPrint('   ID Number: ${member.idNumber}');
    debugPrint('   Rifle Number: ${member.rifleNumber}');
    debugPrint('   Additional Info: ${member.additionalInfo}');

    await updateMemberApi(member.id, payload);
  }

  Future<void> deleteMember(String id) async {
    await deleteMemberApi(id);
  }

  Member _memberFromMap(Map<String, dynamic> map) {
    try {
      // Parse additionalInfo
      Map<String, dynamic>? additionalInfo;
      if (map['additional_info'] != null &&
          map['additional_info'].toString().isNotEmpty) {
        try {
          final additionalInfoStr = map['additional_info'].toString();
          if (additionalInfoStr.startsWith('{')) {
            additionalInfo =
                json.decode(additionalInfoStr) as Map<String, dynamic>;
          }
        } catch (e) {
          debugPrint('Error parsing additional info: $e');
          additionalInfo = null;
        }
      }

      // Get location from dedicated column or additionalInfo
      String? location = map['location']?.toString();
      if ((location == null || location.isEmpty) &&
          additionalInfo != null &&
          additionalInfo['location'] != null) {
        location = additionalInfo['location'].toString();
      }

      return Member(
        id: map['id']?.toString() ?? '',
        fullName: map['full_name']?.toString() ?? 'Unknown',
        rifleNumber: map['id_number']?.toString() ?? '',
        phone: map['phone']?.toString() ?? '',
        dateOfBirth: DateTime.fromMillisecondsSinceEpoch(
          map['date_of_birth'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        ),
        address: map['address']?.toString() ?? '',
        position: map['position']?.toString() ?? 'Member',
        joinDate: DateTime.fromMillisecondsSinceEpoch(
          map['join_date'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        ),
        profileImage: map['profile_image']?.toString(),
        isActive: (map['is_active'] as int? ?? 1) == 1,
        additionalInfo: additionalInfo,
        location: location,
      );
    } catch (e) {
      debugPrint('Error creating member from map: $e');
      debugPrint('Map data: $map');
      return Member(
        id:
            map['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: 'Error Loading Member',
        rifleNumber: '',
        phone: '',
        dateOfBirth: DateTime.now(),
        address: '',
        position: 'Member',
        joinDate: DateTime.now(),
        isActive: false,
      );
    }
  }
}
