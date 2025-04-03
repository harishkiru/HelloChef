import 'package:src/classes/lesson_item.dart';
import 'package:src/classes/progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:src/classes/level.dart';

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
      version: 4, // Incremented version for migration
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
          totalLessons INTEGER DEFAULT 0,
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
          imagePath TEXT,
          videoPath TEXT,
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

      // Create FirstRun table
      await db.execute('''
        CREATE TABLE FirstRun (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          isFirstRun INTEGER DEFAULT 1
        )
      ''');

      print('Credentials table created.');
    } catch (e) {
      print('Error creating credentials table: $e');
    }
  }

  // Upgrade the SQLite Database
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
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
          totalLessons INTEGER DEFAULT 0,
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
          imagePath TEXT,
          videoPath TEXT,
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

        // Create FirstRun table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS FirstRun (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          isFirstRun INTEGER DEFAULT 1
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

  // ********** Lessons SQlite Operations **********

  Future<Progress> getCurrentLevelProgress() async {
    final db = await sqliteDatabase;
    final currentLevel = await db.query(
      'Levels',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'level ASC',
      limit: 1,
    );

    Level level = Level(
      id: currentLevel.first['id'] as int,
      level: currentLevel.first['level'] as int,
      title: currentLevel.first['title'] as String,
      subtitle: currentLevel.first['subtitle'] as String,
      imagePath: currentLevel.first['imagePath'] as String,
      isCompleted: currentLevel.first['isCompleted'] == 1,
    );

    final sections = await db.query(
      'Sections',
      where: 'levelId = ?',
      whereArgs: [level.id],
    );

    int numSections = sections.length;
    int numSectionsCompleted = 0;
    double progressPercentage = 0.0;
    int numLessons = 0;
    int numLessonsCompleted = 0;

    for (final section in sections) {
      numLessons += section['totalLessons'] as int;
      numLessonsCompleted += section['completedLessons'] as int;
      if (section['completedLessons'] == section['totalLessons']) {
        numSectionsCompleted += 1;
      }
    }

    if (numLessons > 0) {
      progressPercentage = (numLessonsCompleted / numLessons);
    }
    return Progress(
      level: level,
      numSections: numSections,
      numSectionsCompleted: numSectionsCompleted,
      progressPercentage: progressPercentage,
    );
  }

  Future<LessonItem> getNextUpLesson() async {
    final db = await sqliteDatabase;
    final result = await db.query(
      'Lessons',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'id ASC',
      limit: 1,
    );

    final lesson = LessonItem(
      id: result.first['id'] as int,
      title: result.first['title'] as String,
      type: result.first['type'] as int,
      content: result.first['content'] as String?,
      videoPath: result.first['videoPath'] as String?,
      imagePath: result.first['imagePath'] as String,
      quizId: result.first['quizId'] as int?,
      isCompleted: result.first['isCompleted'] == 1,
    );

    return lesson;
  }

  Future<void> ensureTablesExist() async {
    final db = await sqliteDatabase;

    try {
      // Check if key tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='FirstRun'",
      );

      if (tables.isEmpty) {
        print('Tables not found, creating them now...');
        await _createDB(db, 4);
      } else {
        print('Database tables already exist');
      }
    } catch (e) {
      print('Error checking/creating tables: $e');
      rethrow;
    }
  }

  // Fetch all levels from SQLite
  Future<List<Map<String, dynamic>>> getAllLevels() async {
    final db = await sqliteDatabase;
    final result = await db.query('Levels');
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllSectionsFromLevel(
    int levelId,
  ) async {
    final db = await sqliteDatabase;
    final result = await db.query(
      'Sections',
      where: 'levelId = ?',
      whereArgs: [levelId],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllLessonsFromSection(
    int sectionId,
  ) async {
    final db = await sqliteDatabase;
    final result = await db.query(
      'Lessons',
      where: 'sectionId = ?',
      whereArgs: [sectionId],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getQuizQuestionsFromQuizId(
    int quizId,
  ) async {
    final db = await sqliteDatabase;
    final result = await db.query(
      'QuizQuestions',
      where: 'quizId = ?',
      whereArgs: [quizId],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getInteractiveButtonsFromLessonId(
    int lessonId,
  ) async {
    final db = await sqliteDatabase;
    final result = await db.query(
      'InteractiveButtons',
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getQuizFromQuizId(int quizId) async {
    final db = await sqliteDatabase;
    final result = await db.query(
      'Quizzes',
      where: 'id = ?',
      whereArgs: [quizId],
      limit: 1,
    );
    return result;
  }

  Future<void> completeLesson(int lessonId) async {
    final db = await sqliteDatabase;
    await db.update(
      'Lessons',
      {'isCompleted': 1},
      where: 'id = ?',
      whereArgs: [lessonId],
    );
    await addCompletedLessonToSection(lessonId);
  }

  Future<void> addCompletedLessonToSection(int lessonId) async {
    final db = await sqliteDatabase;

    // Get the sectionId of the completed lesson
    final lesson = await db.query(
      'Lessons',
      where: 'id = ?',
      whereArgs: [lessonId],
      limit: 1,
    );
    if (lesson.isNotEmpty) {
      final sectionId = lesson.first['sectionId'] as int;

      // Update the completedLessons count in the Sections table
      await db.rawUpdate(
        'UPDATE Sections SET completedLessons = completedLessons + 1 WHERE id = ?',
        [sectionId],
      );

      // Check if the level is completed
      final section = await db.query(
        'Sections',
        where: 'id = ?',
        whereArgs: [sectionId],
        limit: 1,
      );
      if (section.isNotEmpty) {
        final levelId = section.first['levelId'] as int;
        await checkIfLevelCompleted(levelId);
      }
    }
  }

  Future<void> checkIfLevelCompleted(int levelId) async {
    final db = await sqliteDatabase;

    // Get the total number of sections in the level
    final sections = await db.query(
      'Sections',
      where: 'levelId = ?',
      whereArgs: [levelId],
    );

    // Get the number of completed sections
    final completedSections = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Sections WHERE levelId = ? AND completedLessons = totalLessons',
      [levelId],
    );

    if (completedSections.isNotEmpty &&
        completedSections.first['count'] == sections.length) {
      // Update the level as completed
      await db.update(
        'Levels',
        {'isCompleted': 1},
        where: 'id = ?',
        whereArgs: [levelId],
      );
    }
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

  // ********* Supabase XP and Badge Operations **********

  Future<void> addDefaultBadge() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      final response = await supabase.from('badges').insert({
        'badge_id': 1, // Default badge ID
        'user_id': user.id,
      });
    }
  }

  Future<Map<String, dynamic>> updateUserXP(int xp) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // Fetch the current XP of the user
      final response =
          await supabase
              .from('users')
              .select('xp')
              .eq('auth_id', user.id)
              .maybeSingle();
      if (response == null) {
        throw Exception('User not found in database');
      }
      final currentXP = response['xp'] as int? ?? 0;

      // Update the XP in the database
      final newXP = currentXP + xp;
      await supabase.from('users').update({'xp': newXP}).eq('auth_id', user.id);

      //Fetch the current user rank
      final rankResponse =
          await supabase
              .from('users')
              .select('user_rank')
              .eq('auth_id', user.id)
              .maybeSingle();

      final rank = rankResponse?['user_rank'] as int? ?? 0;

      // Fetch the next rank above the current rank
      final nextRankResponse =
          await supabase
              .from('ranks')
              .select('id, xp_required')
              .gt('id', rank)
              .order('id', ascending: true)
              .limit(1)
              .maybeSingle();

      if (nextRankResponse != null) {
        final nextRankXP = nextRankResponse['xp_required'] as int? ?? 0;
        if (newXP >= nextRankXP) {
          // Update the user rank in the database
          await supabase
              .from('users')
              .update({'user_rank': nextRankResponse['id']})
              .eq('auth_id', user.id);

          return {'xp': newXP, 'rank': nextRankResponse['id']};
        } else {
          // User is not eligible for a rank up yet
          return {'xp': newXP, 'rank': -1};
        }
      } else {
        // No next rank found, user is at the highest rank
        return {'xp': newXP, 'rank': -1};
      }
    } else {
      return {'xp': -1, 'rank': -1};
    }
  }
}
