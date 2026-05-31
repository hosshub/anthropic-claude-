import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../data/database.dart';
import 'fasting_calculator.dart';

class FastingEntry {
  final String dateKey;
  final DateTime loggedAt;
  final FastingKind kind;
  final String? notes;
  const FastingEntry({
    required this.dateKey,
    required this.loggedAt,
    required this.kind,
    this.notes,
  });
}

class FastingRepository extends ChangeNotifier {
  /// يرجع تسجيلة اليوم (أو null) — قراءة سريعة بمفتاح التاريخ.
  Future<FastingEntry?> loadFor(DateTime date) async {
    final db = await TayyibatDatabase.open();
    final key = FastingCalculator.dateKey(date);
    final rows = await db.query(
      'fasting_days',
      where: 'date_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _row(rows.first);
  }

  /// يحفظ يوم صيام (أو يعدّل النوع إن وُجد).
  Future<void> markFasting({
    required DateTime date,
    required FastingKind kind,
    String? notes,
  }) async {
    final db = await TayyibatDatabase.open();
    final key = FastingCalculator.dateKey(date);
    await db.insert(
      'fasting_days',
      {
        'date_key': key,
        'logged_at': DateTime.now().millisecondsSinceEpoch,
        'kind': kind.name,
        'notes': notes,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  Future<void> unmark(DateTime date) async {
    final db = await TayyibatDatabase.open();
    final key = FastingCalculator.dateKey(date);
    await db.delete(
      'fasting_days',
      where: 'date_key = ?',
      whereArgs: [key],
    );
    notifyListeners();
  }

  Future<List<FastingEntry>> recent({int limit = 30}) async {
    final db = await TayyibatDatabase.open();
    final rows = await db.query(
      'fasting_days',
      orderBy: 'date_key DESC',
      limit: limit,
    );
    return rows.map(_row).toList();
  }

  FastingEntry _row(Map<String, Object?> row) => FastingEntry(
        dateKey: row['date_key'] as String,
        loggedAt: DateTime.fromMillisecondsSinceEpoch(row['logged_at'] as int),
        kind: FastingKind.values.firstWhere(
          (k) => k.name == (row['kind'] as String),
          orElse: () => FastingKind.general,
        ),
        notes: row['notes'] as String?,
      );
}
