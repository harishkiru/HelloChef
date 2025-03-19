import 'package:sqflite/sqflite.dart';
import 'package:src/services/db_helper.dart';

Future<void> dropAllTables(Database db) async {
  // Get the list of all tables
  List<Map<String, dynamic>> tables = await db.rawQuery(
    'SELECT name FROM sqlite_master WHERE type = "table"',
  );

  // Drop each table
  for (var table in tables) {
    String tableName = table['name'];
    if (tableName != 'sqlite_sequence') {
      // Skip the sqlite_sequence table
      await db.execute('DROP TABLE IF EXISTS $tableName');
    }
  }
}

Future<void> verifyTableDeletion(Database db) async {
  // Get the list of all tables
  List<Map<String, dynamic>> tables = await db.rawQuery(
    'SELECT name FROM sqlite_master WHERE type = "table"',
  );

  if (tables.isEmpty) {
    print('All tables have been dropped');
  } else {
    print('Failed to drop all tables');
  }
}

void main() {
  final db = DBHelper.instance();
  db.sqliteDatabase.then((database) async {
    await dropAllTables(database!);
  });

  db.sqliteDatabase.then((database) async {
    await verifyTableDeletion(database!);
  });
}
