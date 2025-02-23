import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // Create a singleton instance of DBHelper
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper.instance() => _instance;
  DBHelper._internal();

  final supabase = Supabase.instance.client; // Supabase client instance

  // SQLite Database instance
  static Database? _sqliteDatabase;

  // Initialize SQLite Database
  Future<Database> get sqliteDatabase async {
    if (_sqliteDatabase != null) return _sqliteDatabase!;

    _sqliteDatabase = await _initSQLiteDB();
    return _sqliteDatabase!;
  }

  // Initialize SQLite Database
  Future<Database> _initSQLiteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'brainwave.db');

    return await openDatabase(
      path,
      version: 2, // Incremented version for migration
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Create the SQLite Database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Create the SQLite Database
  Future _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE credentials (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          password TEXT NOT NULL
        )
      ''');
      print('Credentials table created.');
    } catch (e) {
      print('Error creating credentials table: $e');
    }
  }

  // Upgrade the SQLite Database
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS credentials (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');
        print('Credentials table upgraded/created.');
      } catch (e) {
        print('Error upgrading/creating credentials table: $e');
      }
    }
  }

  // ********** Credentials Operations with SQLite **********
  // Save user credentials to SQLite
  Future<void> saveCredentials(String username, String password) async {
    final db = await sqliteDatabase;

    // Clear existing credentials (one user at a time)
    await db.delete('credentials');

    // Insert new credentials
    await db.insert('credentials', {'username': username, 'password': password});
  }
  
  // Fetch user credentials from SQLite
  Future<Map<String, String>?> getCredentials() async {
    final db = await sqliteDatabase;
    final result = await db.query('credentials', limit: 1);

    if (result.isNotEmpty) {
      return {
        'username': result.first['username'] as String,
        'password': result.first['password'] as String,
      };
    }
    return null;
  }

  // Delete user credentials from SQLite
  Future<void> deleteCredentials() async {
    final db = await sqliteDatabase;
    await db.delete('credentials');
  }

  // Close the database
  Future close() async {
    final db = await sqliteDatabase;
    db.close();
  }
}