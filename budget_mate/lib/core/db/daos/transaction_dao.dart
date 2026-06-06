import 'dart:async';
import 'package:drift/drift.dart';
import 'package:budget_mate/core/db/database.dart';

/// DAO for Transaction CRUD operations.
class TransactionDao {
  final AppDatabase _db;

  const TransactionDao(this._db);

  /// Returns all transactions for a given period, ordered by date descending.
  Stream<List<TransactionsTableData>> watchByPeriod(String periodId) {
    return (_db.select(_db.transactionsTable)
          ..where((t) => t.periodId.equals(periodId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Returns all transactions for a given category, ordered by date descending.
  Stream<List<TransactionsTableData>> watchByCategory(String categoryId) {
    return (_db.select(_db.transactionsTable)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Returns the total spent amount for a given period.
  Future<double> totalByPeriod(String periodId) async {
    final transactions = await (_db.select(_db.transactionsTable)
          ..where((t) => t.periodId.equals(periodId)))
        .get();
    double sum = 0;
    for (final t in transactions) {
      sum += t.amount;
    }
    return sum;
  }

  /// Returns the total spent amount for a given category.
  Future<double> totalByCategory(String categoryId) async {
    final transactions = await (_db.select(_db.transactionsTable)
          ..where((t) => t.categoryId.equals(categoryId)))
        .get();
    double sum = 0;
    for (final t in transactions) {
      sum += t.amount;
    }
    return sum;
  }

  /// Inserts a new transaction.
  Future<void> insert(TransactionsTableCompanion entry) async {
    await _db.into(_db.transactionsTable).insert(entry);
  }

  /// Updates an existing transaction.
  Future<void> update(TransactionsTableCompanion entry) async {
    await (_db.update(_db.transactionsTable)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  /// Deletes a transaction by id.
  Future<void> delete(String id) async {
    await (_db.delete(_db.transactionsTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}