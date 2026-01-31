import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/member.dart';
import 'database_helper.dart';

class MemberService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _initialized = false;

  Future<void> initializeDatabase() async {
    if (_initialized) return;

    try {
      // This will trigger database creation or upgrade
      final db = await _dbHelper.database;

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
      final db = await _dbHelper.database;
      _initialized = true;
      debugPrint('Database reset and initialized successfully');
    } catch (e) {
      print('Error resetting database: $e');
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> addMember(Member member, File? profileImage) async {
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
        'join_date': member.joinDate.millisecondsSinceEpoch, // Fixed: 'join_date'
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

      print('Member added successfully: ${member.fullName}');
    } catch (e) {
      print('Error adding member: $e');
      print('Member data: ${member.toMap()}');
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

  Stream<List<Member>> getMembers() async* {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'members',
        orderBy: 'join_date DESC',
      );

      final members = maps.map((map) => _memberFromMap(map)).toList();
      yield members;
    } catch (e) {
      print('Error getting members: $e');
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

  Future<Member?> getMemberById(String id) async {
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
      print('Error getting members by location: $e');
      return [];
    }
  }

  Future<List<String>> getMemberLocations() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
          '''
        SELECT DISTINCT location 
        FROM members 
        WHERE location IS NOT NULL AND location != ''
        ORDER BY location ASC
        '''
      );

      return maps
          .map<String>((map) => map['location']?.toString() ?? '')
          .where((location) => location.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error getting member locations: $e');
      return [];
    }
  }

  Future<void> updateMember(Member member) async {
    try {
      final db = await _dbHelper.database;

      final data = <String, dynamic>{
        'full_name': member.fullName,
        'id_number': member.idNumber,
        'phone': member.phone,
        'date_of_birth': member.dateOfBirth.millisecondsSinceEpoch,
        'address': member.address,
        'position': member.position,
        'join_date': member.joinDate.millisecondsSinceEpoch,
        'profile_image': member.profileImage,
        'is_active': member.isActive ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

      // Handle additional_info
      if (member.additionalInfo != null) {
        data['additional_info'] = json.encode(member.additionalInfo);
      }

      // Handle location
      if (member.location != null) {
        data['location'] = member.location;
      }

      await db.update(
        'members',
        data,
        where: 'id = ?',
        whereArgs: [member.id],
      );
    } catch (e) {
      throw Exception('Failed to update member: $e');
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('members', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete member: $e');
    }
  }

  Member _memberFromMap(Map<String, dynamic> map) {
    try {
      // Parse additionalInfo
      Map<String, dynamic>? additionalInfo;
      if (map['additional_info'] != null && map['additional_info'].toString().isNotEmpty) {
        try {
          final additionalInfoStr = map['additional_info'].toString();
          if (additionalInfoStr.startsWith('{')) {
            additionalInfo = json.decode(additionalInfoStr) as Map<String, dynamic>;
          }
        } catch (e) {
          print('Error parsing additional info: $e');
          additionalInfo = null;
        }
      }

      // Get location from dedicated column or additionalInfo
      String? location = map['location']?.toString();
      if ((location == null || location.isEmpty) && additionalInfo != null && additionalInfo['location'] != null) {
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
      print('Error creating member from map: $e');
      print('Map data: $map');
      return Member(
        id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
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