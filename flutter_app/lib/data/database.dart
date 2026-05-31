import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// قاعدة بيانات SQLite محلية لوجبات الطيبات.
class TayyibatDatabase {
  TayyibatDatabase._();
  static const _schemaVersion = 2;
  static Database? _db;

  /// يفتح قاعدة البيانات (مرة واحدة) ويعيد نفس الكائن في كل استدعاء لاحق.
  static Future<Database> open() async {
    if (_db != null) return _db!;
    final docs = await getApplicationDocumentsDirectory();
    final path = p.join(docs.path, 'tayyibat.db');
    _db = await openDatabase(
      path,
      version: _schemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  static Future<void> _onUpgrade(Database db, int from, int to) async {
    if (from < 2) await _createFastingTable(db);
  }

  static Future<void> _createFastingTable(Database db) async {
    await db.execute('''
      CREATE TABLE fasting_days (
        date_key   TEXT PRIMARY KEY,
        logged_at  INTEGER NOT NULL,
        kind       TEXT NOT NULL,
        notes      TEXT
      );
    ''');
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  static Future<void> _onCreate(Database db, int _) async {
    await db.execute('''
      CREATE TABLE meals (
        id                    TEXT PRIMARY KEY,
        captured_at           INTEGER NOT NULL,
        image_path            TEXT,
        overall_score         INTEGER NOT NULL,
        score_label_ar        TEXT NOT NULL,
        score_explanation_ar  TEXT NOT NULL,
        suggestions           TEXT NOT NULL,
        warnings              TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE food_items (
        id                 TEXT PRIMARY KEY,
        meal_id            TEXT NOT NULL,
        name_ar            TEXT NOT NULL,
        verdict            TEXT NOT NULL,
        zone               TEXT,
        caution_ar         TEXT,
        category           TEXT NOT NULL,
        reasoning          TEXT NOT NULL,
        confidence         REAL NOT NULL,
        estimated_portion  TEXT NOT NULL,
        rule_violated      TEXT,
        item_order         INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(meal_id) REFERENCES meals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE body_responses (
        id                   TEXT PRIMARY KEY,
        meal_id              TEXT NOT NULL UNIQUE,
        logged_at            INTEGER NOT NULL,
        hours_after_meal     INTEGER NOT NULL,
        satisfying_fullness  INTEGER NOT NULL,
        bloating             INTEGER NOT NULL,
        energy_level         INTEGER NOT NULL,
        sleep_impact         TEXT NOT NULL,
        worth_repeating      TEXT NOT NULL,
        notes                TEXT,
        FOREIGN KEY(meal_id) REFERENCES meals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute(
      'CREATE INDEX idx_meals_captured_at ON meals(captured_at DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_food_items_meal ON food_items(meal_id, item_order)',
    );
    await _createFastingTable(db);
  }
}
