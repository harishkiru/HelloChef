import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:src/services/db_helper.dart';

Future<void> dropAllTables(Database db) async {
  List<Map<String, dynamic>> tables = await db.rawQuery(
    'SELECT name FROM sqlite_master WHERE type = "table"',
  );

  for (var table in tables) {
    String tableName = table['name'];
    if (tableName != 'sqlite_sequence') {
      // skip the sqlite_sequence table
      await db.execute('DROP TABLE IF EXISTS $tableName');
    }
    print('Dropped table: $tableName');
  }
}

Future<void> verifyTableDeletion(Database db) async {
  List<Map<String, dynamic>> tables = await db.rawQuery(
    'SELECT name FROM sqlite_master WHERE type = "table"',
  );

  if (tables.isEmpty) {
    print('All tables have been dropped');
  }
}

void main() async {
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_API_KEY']!,
  );

  final db = DBHelper.instance();
  db.sqliteDatabase.then((database) async {
    await dropAllTables(database);
  });

  db.sqliteDatabase.then((database) async {
    await verifyTableDeletion(database);
  });
}
