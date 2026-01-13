import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'special_squad.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Create members table
    await db.execute('''
      CREATE TABLE members (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        id_number TEXT NOT NULL,
        phone TEXT NOT NULL,
        date_of_birth INTEGER NOT NULL,
        address TEXT NOT NULL,
        position TEXT NOT NULL,
        join_date INTEGER NOT NULL,
        profile_image TEXT,
        is_active INTEGER DEFAULT 1,
        additional_info TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        member_id TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_date INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        purpose TEXT NOT NULL,
        receipt_number TEXT,
        bank_reference TEXT,
        status TEXT DEFAULT 'Completed',
        notes TEXT,
        attachment_url TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (member_id) REFERENCES members (id)
      )
    ''');

    // Create duty_posts table
    await db.execute('''
      CREATE TABLE duty_posts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        location TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create duty_rosters table
    await db.execute('''
      CREATE TABLE duty_rosters (
        id TEXT PRIMARY KEY,
        member_id TEXT NOT NULL,
        duty_post_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        shift TEXT NOT NULL,
        status TEXT DEFAULT 'Scheduled',
        notes TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (member_id) REFERENCES members (id),
        FOREIGN KEY (duty_post_id) REFERENCES duty_posts (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_members_id_number ON members(id_number)',
    );
    await db.execute(
      'CREATE INDEX idx_payments_member_id ON payments(member_id)',
    );
    await db.execute(
      'CREATE INDEX idx_duty_rosters_member_id ON duty_rosters(member_id)',
    );
    await db.execute(
      'CREATE INDEX idx_duty_rosters_date ON duty_rosters(date)',
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
