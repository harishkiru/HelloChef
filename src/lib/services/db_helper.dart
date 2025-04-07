import 'package:src/classes/lesson_item.dart';
import 'package:src/classes/progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:src/classes/level.dart';
import 'dart:async';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper.instance() => _instance;
  DBHelper._internal();

  final supabase = Supabase.instance.client;

  static Database? _sqliteDatabase;

  Map<String, dynamic>? _cachedUserDetails;

  static final StreamController<void> _profileUpdateController = StreamController<void>.broadcast();
  static Stream<void> get profileUpdates => _profileUpdateController.stream;

  Future<Database> get sqliteDatabase async {
    if (_sqliteDatabase != null) return _sqliteDatabase!;

    _sqliteDatabase = await _initSQLiteDB();
    return _sqliteDatabase!;
  }

  Future<Database> _initSQLiteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hellochef.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE credentials (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          password TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE badges (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          defaultBadge INTEGER DEFAULT 0,
          quizesCompleted INTEGER DEFAULT 0,
          perfectQuizesCompleted INTEGER DEFAULT 0,
          totalLessonsCompleted INTEGER DEFAULT 0,
          totalRecipesCreated INTEGER DEFAULT 0
        )
      ''');

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

      await db.execute('''
        CREATE TABLE Quizzes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT
        )
      ''');

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

        await db.execute('''
        CREATE TABLE IF NOT EXISTS Quizzes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT
        )
      ''');

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
  Future<void> saveCredentials(String username, String password) async {
    final db = await sqliteDatabase;

    await db.delete('credentials');

    await db.insert('credentials', {
      'username': username,
      'password': password,
    });
  }

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

  Future<void> deleteCredentials() async {
    final db = await sqliteDatabase;
    await db.delete('credentials');
  }

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

    final lesson = await db.query(
      'Lessons',
      where: 'id = ?',
      whereArgs: [lessonId],
      limit: 1,
    );
    if (lesson.isNotEmpty) {
      final sectionId = lesson.first['sectionId'] as int;

      await db.rawUpdate(
        'UPDATE Sections SET completedLessons = completedLessons + 1 WHERE id = ?',
        [sectionId],
      );

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

    final sections = await db.query(
      'Sections',
      where: 'levelId = ?',
      whereArgs: [levelId],
    );

    final completedSections = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Sections WHERE levelId = ? AND completedLessons = totalLessons',
      [levelId],
    );

    if (completedSections.isNotEmpty &&
        completedSections.first['count'] == sections.length) {
      await db.update(
        'Levels',
        {'isCompleted': 1},
        where: 'id = ?',
        whereArgs: [levelId],
      );
    }
  }

  Future<bool> checkIfGivenDefaultBadge() async {
    final db = await sqliteDatabase;
    final result = await db.query(
      'badges',
      where: 'defaultBadge = ?',
      whereArgs: [1],
    );
    return result.isNotEmpty;
  }

  Future<void> setDefaultBadgeGiven() async {
    final db = await sqliteDatabase;

    await db.insert('badges', {
      'defaultBadge': 1,
      'quizesCompleted': 0,
      'perfectQuizesCompleted': 0,
      'totalLessonsCompleted': 0,
      'totalRecipesCreated': 0,
    });
    await addBadge(1);
  }

  Future<void> addQuizToTotalQuizesCompleted() async {
    final db = await sqliteDatabase;
    await db.rawUpdate(
      'UPDATE badges SET quizesCompleted = quizesCompleted + 1 WHERE defaultBadge = ?',
      [1],
    );
  }

  Future<void> addPerfectQuizToTotalQuizesCompleted() async {
    final db = await sqliteDatabase;
    await db.rawUpdate(
      'UPDATE badges SET perfectQuizesCompleted = perfectQuizesCompleted + 1 WHERE defaultBadge = ?',
      [1],
    );
  }

  Future<void> addLessonToTotalLessonsCompleted() async {
    final db = await sqliteDatabase;
    await db.rawUpdate(
      'UPDATE badges SET totalLessonsCompleted = totalLessonsCompleted + 1 WHERE defaultBadge = ?',
      [1],
    );
  }

  Future<void> addRecipeToTotalRecipesCreated() async {
    final db = await sqliteDatabase;
    await db.rawUpdate(
      'UPDATE badges SET totalRecipesCreated = totalRecipesCreated + 1 WHERE defaultBadge = ?',
      [1],
    );
  }

  Future<bool> checkIfPerfectQuizUnlocked() async {
    final db = await sqliteDatabase;

    // get the number of perfect quizzes completed if the number of total quizzes completed is no greater then the number of perfect quizzes completed return true
    final result = await db.rawQuery(
      'SELECT quizesCompleted, perfectQuizesCompleted FROM badges WHERE defaultBadge = ?',
      [1],
    );
    if (result.isNotEmpty) {
      final quizesCompleted = result.first['quizesCompleted'] as int;
      final perfectQuizesCompleted =
          result.first['perfectQuizesCompleted'] as int;
      return quizesCompleted <= perfectQuizesCompleted &&
          perfectQuizesCompleted == 3;
    }
    return false;
  }

  Future<bool> checkIfHelloChefBadgeUnlocked() async {
    final db = await sqliteDatabase;

    // get the number of lessons completed and compare to the total number of lessons which is 34
    final result = await db.rawQuery(
      'SELECT totalLessonsCompleted FROM badges WHERE defaultBadge = ?',
      [1],
    );
    if (result.isNotEmpty) {
      final totalLessonsCompleted =
          result.first['totalLessonsCompleted'] as int;
      return totalLessonsCompleted == 34;
    }
    return false;
  }

  Future<bool> checkIfMasterChefBadgeUnlocked() async {
    final db = await sqliteDatabase;

    // get the number of recipes created and compare to the total number of recipes which is 10
    final result = await db.rawQuery(
      'SELECT totalRecipesCreated FROM badges WHERE defaultBadge = ?',
      [1],
    );
    if (result.isNotEmpty) {
      final totalRecipesCreated = result.first['totalRecipesCreated'] as int;
      return totalRecipesCreated == 6;
    }
    return false;
  }

  // ********** Supabase User Operations **********
  Future<Map<String, dynamic>?> getUserDetails({bool refresh = false}) async {
    if (refresh) {
      _cachedUserDetails = null;
    }
    
    if (_cachedUserDetails != null && !refresh) {
      return _cachedUserDetails;
    }

    final user = supabase.auth.currentUser;
    if (user != null) {
      final response =
          await supabase
              .from('users')
              .select('first_name, last_name, pfp_path')
              .eq('auth_id', user.id)
              .maybeSingle();

      _cachedUserDetails = response;
      return _cachedUserDetails;
    } else {
      throw Exception('User not authenticated');
    }
  }

  void clearCachedUserDetails() {
    _cachedUserDetails = null;
  }

  Future<void> updateUserProfilePicture(String path) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase
          .from('users')
          .update({'pfp_path': path})
          .eq('auth_id', user.id);
      
      _cachedUserDetails = null;
      
      _profileUpdateController.add(null);
    } else {
      throw Exception('User not authenticated');
    }
  }

  // ********* Supabase XP and Badge Operations **********
  Future<void> addBadge(int id) async {
    final user = supabase.auth.currentUser;

    final userResponse =
        await supabase
            .from('users')
            .select('id')
            .eq('auth_id', user!.id)
            .maybeSingle();

    await supabase.from('user_badges').insert({
      'badge_id': id,
      'user_id': userResponse!['id'],
    });
  }

  Future<Map<String, dynamic>> updateUserXP(int xp) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
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

      final newXP = currentXP + xp;
      await supabase.from('users').update({'xp': newXP}).eq('auth_id', user.id);

      final rankResponse =
          await supabase
              .from('users')
              .select('user_rank')
              .eq('auth_id', user.id)
              .maybeSingle();

      final rank = rankResponse?['user_rank'] as int? ?? 0;

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
          await supabase
              .from('users')
              .update({'user_rank': nextRankResponse['id']})
              .eq('auth_id', user.id);

          return {'xp': newXP, 'rank': nextRankResponse['id']};
        } else {
          return {'xp': newXP, 'rank': -1};
        }
      } else {
        return {'xp': newXP, 'rank': -1};
      }
    } else {
      return {'xp': -1, 'rank': -1};
    }
  }

  Future<Map<String, dynamic>> getUserXpAndRank() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final userResponse =
          await supabase
              .from('users')
              .select('xp, user_rank')
              .eq('auth_id', user.id)
              .maybeSingle();

      if (userResponse == null) {
        return {
          'currentXP': 0,
          'currentRank': 0,
          'nextRank': 1,
          'xpForNextRank': 100,
          'xpForCurrentRank': 0,
          'progress': 0.0,
        };
      }

      final currentXP = userResponse['xp'] as int? ?? 0;
      final currentRank = userResponse['user_rank'] as int? ?? 0;

      final currentRankResponse =
          await supabase
              .from('ranks')
              .select('id, xp_required')
              .eq('id', currentRank)
              .maybeSingle();

      final nextRankResponse =
          await supabase
              .from('ranks')
              .select('id, xp_required')
              .gt('id', currentRank)
              .order('id', ascending: true)
              .limit(1)
              .maybeSingle();

      final int xpForCurrentRank =
          currentRankResponse?['xp_required'] as int? ?? 0;
      final int xpForNextRank = nextRankResponse?['xp_required'] as int? ?? 100;
      final int nextRank = nextRankResponse?['id'] as int? ?? (currentRank + 1);

      double progress = 0.0;
      if (xpForNextRank > xpForCurrentRank) {
        progress =
            (currentXP - xpForCurrentRank) / (xpForNextRank - xpForCurrentRank);
        progress = progress.clamp(0.0, 1.0);
      }

      return {
        'currentXP': currentXP,
        'currentRank': currentRank,
        'nextRank': nextRank,
        'xpForNextRank': xpForNextRank,
        'xpForCurrentRank': xpForCurrentRank,
        'progress': progress,
      };
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<List<Map<String, dynamic>>> getAllBadgesWithUnlockStatus() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final allBadges = await supabase
          .from('badges')
          .select('id, badge_name, badge_image_url, badge_description')
          .order('id');

      final userResponse =
          await supabase
              .from('users')
              .select('id')
              .eq('auth_id', user.id)
              .maybeSingle();

      if (userResponse == null) {
        return allBadges.map<Map<String, dynamic>>((badge) {
          return {
            'id': badge['id'],
            'name': badge['badge_name'],
            'imageUrl': badge['badge_image_url'],
            'description': badge['badge_description'],
            'unlocked': false,
          };
        }).toList();
      }

      final userId = userResponse['id'];

      final userBadges = await supabase
          .from('user_badges')
          .select('badge_id')
          .eq('user_id', userId);
  
      final Set<int> unlockedBadgeIds =
          userBadges.map<int>((item) => item['badge_id'] as int).toSet();
  
      // map all badges with unlock status
      return allBadges.map<Map<String, dynamic>>((badge) {
        final badgeId = badge['id'] as int;
        final isUnlocked = unlockedBadgeIds.contains(badgeId);

        return {
          'id': badgeId,
          'name': badge['badge_name'],
          'imageUrl': badge['badge_image_url'],
          'description': badge['badge_description'],
          'unlocked': isUnlocked,
        };
      }).toList();
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboardData() async {
    final currentUser = supabase.auth.currentUser;

    final usersData = await supabase
        .from('users')
        .select('id, auth_id, first_name, last_name, xp, user_rank, pfp_path')
        .order('xp', ascending: false);

    final allBadges = await supabase.from('user_badges').select('user_id');

    Map<String, int> badgeCounts = {};
    for (var badge in allBadges) {
      final userId = badge['user_id'];
      badgeCounts[userId] = (badgeCounts[userId] ?? 0) + 1;
    }

    // create leaderboard data
    List<Map<String, dynamic>> leaderboardData =
        usersData.map<Map<String, dynamic>>((userData) {
          final userId = userData['id'];
          return {
            'id': userId,
            'firstName': userData['first_name'],
            'lastName': userData['last_name'],
            'xp': userData['xp'],
            'rank': userData['user_rank'],
            'pfpPath': userData['pfp_path'],
            'badgeCount': badgeCounts[userId] ?? 0,
            'isCurrentUser': currentUser != null && userData['auth_id'] == currentUser.id,
          };
        }).toList();

    return leaderboardData;
  }

  Future<List<Map<String, dynamic>>> getUserBadgesById(String userId) async {
    final allBadges = await supabase
        .from('badges')
        .select('id, badge_name, badge_image_url, badge_description')
        .order('id');

    final userBadges = await supabase
        .from('user_badges')
        .select('badge_id')
        .eq('user_id', userId);

    final Set<int> unlockedBadgeIds =
        userBadges.map<int>((item) => item['badge_id'] as int).toSet();

    // map all badges with unlock status
    return allBadges.map<Map<String, dynamic>>((badge) {
      final badgeId = badge['id'] as int;
      final isUnlocked = unlockedBadgeIds.contains(badgeId);

      return {
        'id': badgeId,
        'name': badge['badge_name'],
        'imageUrl': badge['badge_image_url'],
        'description': badge['badge_description'],
        'unlocked': isUnlocked,
      };
    }).toList();
  }
}