import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/rock.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String dbPath = path.join(await getDatabasesPath(), 'rocks_database.db');
    return await openDatabase(dbPath, version: 1,
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE rocks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          description TEXT,
          imagePath TEXT,
          dangerLevel TEXT,
          geologicalProperties TEXT,
          commonUses TEXT
        )
      ''');
    });
  }

  Future<int> insertRock(Rock rock) async {
    final db = await database;
    return await db.insert('rocks', rock.toMap());
  }

  Future<List<Rock>> getRocks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('rocks');
    return List.generate(maps.length, (i) => Rock.fromMap(maps[i]));
  }
}
