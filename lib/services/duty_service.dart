import '../models/duty_post.dart';
import '../models/duty_roster.dart';
import 'database_helper.dart';

class DutyService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Duty Post methods
  Future<void> addDutyPost(DutyPost dutyPost) async {
    try {
      final db = await _dbHelper.database;

      await db.insert('duty_posts', {
        'id': dutyPost.id,
        'name': dutyPost.name,
        'description': dutyPost.description,
        'location': dutyPost.location,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to add duty post: $e');
    }
  }

  Future<List<DutyPost>> getDutyPosts() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'duty_posts',
        orderBy: 'name ASC',
      );

      return maps.map((map) => _dutyPostFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<DutyPost?> getDutyPostById(String id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'duty_posts',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return _dutyPostFromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateDutyPost(DutyPost dutyPost) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        'duty_posts',
        {
          'name': dutyPost.name,
          'description': dutyPost.description,
          'location': dutyPost.location,
        },
        where: 'id = ?',
        whereArgs: [dutyPost.id],
      );
    } catch (e) {
      throw Exception('Failed to update duty post: $e');
    }
  }

  Future<void> deleteDutyPost(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('duty_posts', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete duty post: $e');
    }
  }

  // Duty Roster methods
  Future<void> addDutyRoster(DutyRoster dutyRoster) async {
    try {
      final db = await _dbHelper.database;

      await db.insert('duty_rosters', {
        'id': dutyRoster.id,
        'member_id': dutyRoster.memberId,
        'duty_post_id': dutyRoster.dutyPostId,
        'date': dutyRoster.date.millisecondsSinceEpoch,
        'shift': dutyRoster.shift,
        'status': dutyRoster.status,
        'notes': dutyRoster.notes,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to add duty roster: $e');
    }
  }

  Stream<List<DutyRoster>> getDutyRosters() async* {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'duty_rosters',
        orderBy: 'date DESC',
      );

      final rosters = maps.map((map) => _dutyRosterFromMap(map)).toList();
      yield rosters;
    } catch (e) {
      yield [];
    }
  }

  Future<List<DutyRoster>> getDutyRostersSync() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'duty_rosters',
        orderBy: 'date DESC',
      );

      return maps.map((map) => _dutyRosterFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DutyRoster>> getDutyRostersByMember(String memberId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'duty_rosters',
        where: 'member_id = ?',
        whereArgs: [memberId],
        orderBy: 'date DESC',
      );

      return maps.map((map) => _dutyRosterFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DutyRoster>> getDutyRostersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'duty_rosters',
        where: 'date >= ? AND date <= ?',
        whereArgs: [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'date ASC',
      );

      return maps.map((map) => _dutyRosterFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DutyRoster>> getDutyRostersByPost(String dutyPostId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'duty_rosters',
        where: 'duty_post_id = ?',
        whereArgs: [dutyPostId],
        orderBy: 'date DESC',
      );

      return maps.map((map) => _dutyRosterFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateDutyRoster(DutyRoster dutyRoster) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        'duty_rosters',
        {
          'member_id': dutyRoster.memberId,
          'duty_post_id': dutyRoster.dutyPostId,
          'date': dutyRoster.date.millisecondsSinceEpoch,
          'shift': dutyRoster.shift,
          'status': dutyRoster.status,
          'notes': dutyRoster.notes,
        },
        where: 'id = ?',
        whereArgs: [dutyRoster.id],
      );
    } catch (e) {
      throw Exception('Failed to update duty roster: $e');
    }
  }

  Future<void> deleteDutyRoster(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('duty_rosters', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete duty roster: $e');
    }
  }

  Future<void> updateDutyStatus(String rosterId, String status) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        'duty_rosters',
        {'status': status},
        where: 'id = ?',
        whereArgs: [rosterId],
      );
    } catch (e) {
      throw Exception('Failed to update duty status: $e');
    }
  }

  DutyPost _dutyPostFromMap(Map<String, dynamic> map) {
    return DutyPost(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      location: map['location'],
    );
  }

  DutyRoster _dutyRosterFromMap(Map<String, dynamic> map) {
    return DutyRoster(
      id: map['id'],
      memberId: map['member_id'],
      dutyPostId: map['duty_post_id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      shift: map['shift'],
      status: map['status'],
      notes: map['notes'],
    );
  }
}
