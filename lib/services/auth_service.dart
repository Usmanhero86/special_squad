import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.createdAt,
    this.isActive = true,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      fullName: map['full_name'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }
}

class AuthService {
  static const String _currentUserKey = 'current_user';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Stream controller for auth state changes
  Stream<User?> get userStream async* {
    User? currentUser = await getCurrentUser();
    yield currentUser;
  }

  User? _currentUser;
  User? get currentUser => _currentUser;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final db = await _dbHelper.database;
      final hashedPassword = _hashPassword(password);

      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'email = ? AND password_hash = ? AND is_active = 1',
        whereArgs: [email, hashedPassword],
      );

      if (result.isNotEmpty) {
        final user = User.fromMap(result.first);
        await _saveCurrentUser(user);
        _currentUser = user;
        return user;
      }
      throw Exception('Invalid email or password');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final db = await _dbHelper.database;

      // Check if user already exists
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        throw Exception('Email already in use');
      }

      // Validate password strength
      if (password.length < 6) {
        throw Exception('Password is too weak');
      }

      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final hashedPassword = _hashPassword(password);
      final now = DateTime.now();

      final user = User(
        id: userId,
        email: email,
        fullName: fullName,
        createdAt: now,
      );

      await db.insert('users', {
        ...user.toMap(),
        'password_hash': hashedPassword,
      });

      await _saveCurrentUser(user);
      _currentUser = user;
      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    _currentUser = null;
  }

  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        _currentUser = User.fromMap(userMap);
        return _currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // For local implementation, you might want to implement this differently
    // For now, we'll just throw an exception indicating it's not implemented
    throw Exception('Password reset not implemented for local authentication');
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    try {
      final db = await _dbHelper.database;

      if (displayName != null) {
        await db.update(
          'users',
          {'full_name': displayName},
          where: 'id = ?',
          whereArgs: [_currentUser!.id],
        );

        // Update current user object
        _currentUser = User(
          id: _currentUser!.id,
          email: _currentUser!.email,
          fullName: displayName,
          createdAt: _currentUser!.createdAt,
          isActive: _currentUser!.isActive,
        );

        await _saveCurrentUser(_currentUser!);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changePassword(String newPassword) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    if (newPassword.length < 6) {
      throw Exception('Password is too weak');
    }

    try {
      final db = await _dbHelper.database;
      final hashedPassword = _hashPassword(newPassword);

      await db.update(
        'users',
        {'password_hash': hashedPassword},
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
