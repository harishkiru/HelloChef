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

  // Cached user details
  Map<String, dynamic>? _cachedUserDetails;

  // Initialize SQLite Database
  Future<Database> get sqliteDatabase async {
    if (_sqliteDatabase != null) return _sqliteDatabase!;

    _sqliteDatabase = await _initSQLiteDB();
    return _sqliteDatabase!;
  }

  // Initialize SQLite Database
  Future<Database> _initSQLiteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hellochef.db');

    return await openDatabase(
      path,
      version: 3, // Incremented version for migration
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

      // Create Levels table
      await db.execute('''
        CREATE TABLE Levels (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          level INTEGER NOT NULL,
          title TEXT NOT NULL,
          subtitle TEXT,
          imagePath TEXT,
          isCompleted INTEGER DEFAULT 0
        )
      ''');

      // Create Sections table
      await db.execute('''
        CREATE TABLE Sections (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          levelId INTEGER NOT NULL,
          title TEXT NOT NULL,
          subtitle TEXT,
          imagePath TEXT,
          completedLessons INTEGER DEFAULT 0,
          FOREIGN KEY (levelId) REFERENCES Levels (id) ON DELETE CASCADE
        )
      ''');

      // Create Lessons table
      await db.execute('''
        CREATE TABLE Lessons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sectionId INTEGER NOT NULL,
          title TEXT NOT NULL,
          type INTEGER NOT NULL,
          imagePath TEXT,
          isCompleted INTEGER DEFAULT 0,
          content TEXT,
          videoPath TEXT,
          quizId INTEGER,
          FOREIGN KEY (sectionId) REFERENCES Sections (id) ON DELETE CASCADE,
          FOREIGN KEY (quizId) REFERENCES Quizzes (id) ON DELETE SET NULL
        )
      ''');

      // Create Quizzes table
      await db.execute('''
        CREATE TABLE Quizzes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT
        )
      ''');

      // Create QuizQuestions table
      await db.execute('''
        CREATE TABLE QuizQuestions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          quizId INTEGER NOT NULL,
          question TEXT NOT NULL,
          options TEXT NOT NULL,
          correctAnswerIndex INTEGER NOT NULL,
          FOREIGN KEY (quizId) REFERENCES Quizzes (id) ON DELETE CASCADE
        )
      ''');

      // Create InteractiveButtons table
      await db.execute('''
        CREATE TABLE InteractiveButtons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lessonId INTEGER NOT NULL,
          name TEXT NOT NULL,
          position_x REAL NOT NULL,
          position_y REAL NOT NULL,
          width REAL NOT NULL,
          height REAL NOT NULL,
          onPressed TEXT NOT NULL,
          FOREIGN KEY (lessonId) REFERENCES Lessons (id) ON DELETE CASCADE
        )
      ''');

      print('Credentials table created.');
    } catch (e) {
      print('Error creating credentials table: $e');
    }
  }

  // Upgrade the SQLite Database
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS credentials (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        // Create Levels table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS Levels (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          level INTEGER NOT NULL,
          title TEXT NOT NULL,
          subtitle TEXT,
          imagePath TEXT,
          isCompleted INTEGER DEFAULT 0
        )
      ''');

        // Create Sections table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS Sections (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          levelId INTEGER NOT NULL,
          title TEXT NOT NULL,
          subtitle TEXT,
          imagePath TEXT,
          completedLessons INTEGER DEFAULT 0,
          FOREIGN KEY (levelId) REFERENCES Levels (id) ON DELETE CASCADE
        )
      ''');

        // Create Lessons table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS Lessons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sectionId INTEGER NOT NULL,
          title TEXT NOT NULL,
          type INTEGER NOT NULL,
          imagePath TEXT,
          isCompleted INTEGER DEFAULT 0,
          content TEXT,
          videoPath TEXT,
          quizId INTEGER,
          FOREIGN KEY (sectionId) REFERENCES Sections (id) ON DELETE CASCADE,
          FOREIGN KEY (quizId) REFERENCES Quizzes (id) ON DELETE SET NULL
        )
      ''');

        // Create Quizzes table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS Quizzes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT
        )
      ''');

        // Create QuizQuestions table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS QuizQuestions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          quizId INTEGER NOT NULL,
          question TEXT NOT NULL,
          options TEXT NOT NULL,
          correctAnswerIndex INTEGER NOT NULL,
          FOREIGN KEY (quizId) REFERENCES Quizzes (id) ON DELETE CASCADE
        )
      ''');

        // Create InteractiveButtons table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS InteractiveButtons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lessonId INTEGER NOT NULL,
          name TEXT NOT NULL,
          position_x REAL NOT NULL,
          position_y REAL NOT NULL,
          width REAL NOT NULL,
          height REAL NOT NULL,
          onPressed TEXT NOT NULL,
          FOREIGN KEY (lessonId) REFERENCES Lessons (id) ON DELETE CASCADE
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
    await db.insert('credentials', {
      'username': username,
      'password': password,
    });
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

  // ********** Supabase User Operations **********
  Future<Map<String, dynamic>?> getUserDetails() async {
    // Return cached data if present.
    if (_cachedUserDetails != null) {
      return _cachedUserDetails;
    }

    final user = supabase.auth.currentUser;
    if (user != null) {
      final response =
          await supabase
              .from('users')
              .select('first_name, last_name')
              .eq('auth_id', user.id)
              .maybeSingle();

      _cachedUserDetails = response;
      return _cachedUserDetails;
    } else {
      throw Exception('User not authenticated');
    }
  }
}
