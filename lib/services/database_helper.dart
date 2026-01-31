import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Add this getter to check if database is initialized
  bool get isInitialized => _database != null;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'special_squad.db');

    return await openDatabase(
      path,
      version: 4, // Increment to 4 to force recreation with payments table
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
  }

  Future<void> _createTables(Database db) async {
    // Drop existing tables and recreate to ensure clean schema
    await db.execute('DROP TABLE IF EXISTS duty_rosters');
    await db.execute('DROP TABLE IF EXISTS duty_posts');
    await db.execute('DROP TABLE IF EXISTS members');
    await db.execute('DROP TABLE IF EXISTS payments');

    // Create members table with ALL columns
    await db.execute('''
      CREATE TABLE members(
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
        location TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create duty_posts table
    await db.execute('''
      CREATE TABLE duty_posts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        location TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create duty_rosters table
    await db.execute('''
      CREATE TABLE duty_rosters(
        id TEXT PRIMARY KEY,
        member_id TEXT NOT NULL,
        duty_post_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        shift TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
        FOREIGN KEY (duty_post_id) REFERENCES duty_posts(id) ON DELETE CASCADE
      )
    ''');

    // Create payments table
    await db.execute('''
      CREATE TABLE payments(
        id TEXT PRIMARY KEY,
        member_id TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_date INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        purpose TEXT NOT NULL,
        receipt_number TEXT,
        bank_reference TEXT,
        status TEXT NOT NULL DEFAULT 'Pending',
        notes TEXT,
        attachment_url TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_members_location ON members(location)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_members_is_active ON members(is_active)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_duty_rosters_date ON duty_rosters(date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_members_join_date ON members(join_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_payments_member_id ON payments(member_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // If old version is less than 2, add location column
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE members ADD COLUMN location TEXT');
        print('Added location column to members table');
      } catch (e) {
        print('Error adding location column: $e');
        // Column might already exist, continue
      }
    }

    // If old version is less than 3, recreate tables to fix any schema issues
    if (oldVersion < 3) {
      print('Recreating tables for version 3');
      await _createTables(db);
      await _createIndexes(db);
    }

    // If old version is less than 4, add payments table
    if (oldVersion < 4) {
      print('Adding payments table for version 4');
      await _createTables(db);
      await _createIndexes(db);
    }
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // Handle database downgrade if needed
    await _onUpgrade(db, oldVersion, newVersion);
  }

  // Method to completely reset database (for development only)
  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    final path = join(await getDatabasesPath(), 'special_squad.db');
    await deleteDatabase(path);
    print('Database reset complete');
  }

  // Add a method to check if location column exists
  Future<bool> hasLocationColumn() async {
    try {
      final db = await database;
      final columns = await db.rawQuery("PRAGMA table_info(members)");
      return columns.any((column) => column['name'] == 'location');
    } catch (e) {
      print('Error checking location column: $e');
      return false;
    }
  }

  // Method to manually add location column if needed
  Future<void> addLocationColumnIfNotExists() async {
    final hasColumn = await hasLocationColumn();

    if (!hasColumn) {
      try {
        final db = await database;
        await db.execute('ALTER TABLE members ADD COLUMN location TEXT');
        print('Added location column to members table');
      } catch (e) {
        print('Error adding location column: $e');
      }
    } else {
      print('Location column already exists');
    }
  }

  // Method to check if payments table exists
  Future<bool> hasPaymentsTable() async {
    try {
      final db = await database;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='payments'",
      );
      return tables.isNotEmpty;
    } catch (e) {
      print('Error checking payments table: $e');
      return false;
    }
  }

  // Method to create payments table if it doesn't exist
  Future<void> createPaymentsTableIfNotExists() async {
    final hasTable = await hasPaymentsTable();

    if (!hasTable) {
      try {
        final db = await database;
        await db.execute('''
          CREATE TABLE payments(
            id TEXT PRIMARY KEY,
            member_id TEXT NOT NULL,
            amount REAL NOT NULL,
            payment_date INTEGER NOT NULL,
            payment_method TEXT NOT NULL,
            purpose TEXT NOT NULL,
            receipt_number TEXT,
            bank_reference TEXT,
            status TEXT NOT NULL DEFAULT 'Pending',
            notes TEXT,
            attachment_url TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
          )
        ''');

        // Create indexes for payments table
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_payments_member_id ON payments(member_id)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status)',
        );

        print('Created payments table successfully');
      } catch (e) {
        print('Error creating payments table: $e');
      }
    } else {
      print('Payments table already exists');
    }
  }

  Future<List<String>> getMemberTableColumns() async {
    try {
      final db = await database;
      final columns = await db.rawQuery("PRAGMA table_info(members)");
      return columns.map<String>((column) => column['name'] as String).toList();
    } catch (e) {
      print('Error getting columns: $e');
      return [];
    }
  }
}
