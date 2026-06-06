import 'dart:async';
import 'package:drift/drift.dart';
import 'package:budget_mate/core/db/database.dart';

/// DAO for IncomeEntry CRUD operations.
///
/// All queries filter by userId for data isolation.
class IncomeEntryDao {
  final AppDatabase _db;

  const IncomeEntryDao(this._db);

  /// Returns all income entries for a given period, ordered by date descending.
  Stream<List<IncomeEntriesTableData>> watchByPeriod(String periodId) {
    return (_db.select(_db.incomeEntriesTable)
          ..where((t) => t.periodId.equals(periodId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Returns the total income amount for a given period.
  Future<double> totalByPeriod(String periodId) async {
    final entries = await (_db.select(_db.incomeEntriesTable)
          ..where((t) => t.periodId.equals(periodId)))
        .get();
    double sum = 0;
    for (final e in entries) {
      sum += e.amount;
    }
    return sum;
  }

  /// Inserts a new income entry.
  Future<void> insert(IncomeEntriesTableCompanion entry) async {
    await _db.into(_db.incomeEntriesTable).insert(entry);
  }

  /// Updates an existing income entry.
  Future<void> update(IncomeEntriesTableCompanion entry) async {
    await (_db.update(_db.incomeEntriesTable)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  /// Deletes an income entry by id.
  Future<void> delete(String id) async {
    await (_db.delete(_db.incomeEntriesTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}