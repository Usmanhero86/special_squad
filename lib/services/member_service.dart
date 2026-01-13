import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/member.dart';
import 'database_helper.dart';

class MemberService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> addMember(Member member, File? profileImage) async {
    try {
      String? imageUrl;

      if (profileImage != null) {
        imageUrl = await _saveProfileImage(profileImage, member.id);
      }

      final db = await _dbHelper.database;

      // Convert additionalInfo to JSON string for storage
      String? additionalInfoJson;
      if (member.additionalInfo != null) {
        additionalInfoJson = member.additionalInfo.toString();
      }

      await db.insert('members', {
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
      });

      print('Member added successfully: ${member.fullName}');
    } catch (e) {
      print('Error adding member: $e');
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

      // Yield initial data
      final List<Map<String, dynamic>> maps = await db.query(
        'members',
        orderBy: 'join_date DESC',
      );

      final members = maps.map((map) => _memberFromMap(map)).toList();
      yield members;

      // For real-time updates, you could listen to database changes here
      // For now, we'll just yield the current data
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

  Future<void> updateMember(Member member) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        'members',
        {
          'full_name': member.fullName,
          'id_number': member.idNumber,
          'phone': member.phone,
          'date_of_birth': member.dateOfBirth.millisecondsSinceEpoch,
          'address': member.address,
          'position': member.position,
          'join_date': member.joinDate.millisecondsSinceEpoch,
          'profile_image': member.profileImage,
          'is_active': member.isActive ? 1 : 0,
          'additional_info': member.additionalInfo?.toString(),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
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
      // Handle additionalInfo parsing more safely
      Map<String, dynamic>? additionalInfo;
      if (map['additional_info'] != null &&
          map['additional_info'].toString().isNotEmpty) {
        try {
          // For now, just store as a simple map since we're storing it as string
          additionalInfo = {'rawData': map['additional_info']};
        } catch (e) {
          print('Error parsing additional info: $e');
          additionalInfo = null;
        }
      }

      return Member(
        id: map['id'] ?? '',
        fullName: map['full_name'] ?? 'Unknown',
        idNumber: map['id_number'] ?? '',
        phone: map['phone'] ?? '',
        dateOfBirth: DateTime.fromMillisecondsSinceEpoch(
          map['date_of_birth'] ?? 0,
        ),
        address: map['address'] ?? '',
        position: map['position'] ?? 'Member',
        joinDate: DateTime.fromMillisecondsSinceEpoch(
          map['join_date'] ?? DateTime.now().millisecondsSinceEpoch,
        ),
        profileImage: map['profile_image'],
        isActive: (map['is_active'] ?? 1) == 1,
        additionalInfo: additionalInfo,
      );
    } catch (e) {
      print('Error creating member from map: $e');
      // Return a default member if there's an error
      return Member(
        id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: map['full_name'] ?? 'Unknown Member',
        idNumber: map['id_number'] ?? '',
        phone: map['phone'] ?? '',
        dateOfBirth: DateTime.now(),
        address: map['address'] ?? '',
        position: map['position'] ?? 'Member',
        joinDate: DateTime.now(),
        isActive: true,
      );
    }
  }
}
