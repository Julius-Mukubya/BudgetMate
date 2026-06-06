import 'dart:async';
import 'package:drift/drift.dart';
import 'package:budget_mate/core/db/database.dart';

/// DAO for BudgetPeriod CRUD operations.
///
/// All queries filter by userId for data isolation.
class BudgetPeriodDao {
  final AppDatabase _db;

  const BudgetPeriodDao(this._db);

  /// Returns all budget periods for the given user, ordered by creation date descending.
  Stream<List<BudgetPeriodsTableData>> watchAll(String userId) {
    return (_db.select(_db.budgetPeriodsTable)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Returns a single budget period by id.
  Future<BudgetPeriodsTableData?> getById(String id) async {
    return await (_db.select(_db.budgetPeriodsTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserts a new budget period.
  Future<void> insert(BudgetPeriodsTableCompanion entry) async {
    await _db.into(_db.budgetPeriodsTable).insert(entry);
  }

  /// Updates an existing budget period.
  Future<void> update(BudgetPeriodsTableCompanion entry) async {
    await (_db.update(_db.budgetPeriodsTable)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  /// Deletes a budget period by id.
  Future<void> delete(String id) async {
    await (_db.delete(_db.budgetPeriodsTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}