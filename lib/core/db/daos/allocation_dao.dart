import 'dart:async';
import 'package:budget_mate/core/db/database.dart';

/// DAO for Allocation CRUD operations.
class AllocationDao {
  final AppDatabase _db;

  const AllocationDao(this._db);

  /// Returns all allocations for a given period.
  Stream<List<AllocationsTableData>> watchByPeriod(String periodId) {
    return (_db.select(_db.allocationsTable)
          ..where((t) => t.periodId.equals(periodId)))
        .watch();
  }

  /// Returns all allocations for a given category.
  Stream<List<AllocationsTableData>> watchByCategory(String categoryId) {
    return (_db.select(_db.allocationsTable)
          ..where((t) => t.categoryId.equals(categoryId)))
        .watch();
  }

  /// Returns the total allocated amount for a given period.
  Future<double> totalByPeriod(String periodId) async {
    final allocations = await (_db.select(_db.allocationsTable)
          ..where((t) => t.periodId.equals(periodId)))
        .get();
    double sum = 0;
    for (final a in allocations) {
      sum += a.amount;
    }
    return sum;
  }

  /// Returns the total allocated amount for a given category.
  Future<double> totalByCategory(String categoryId) async {
    final allocations = await (_db.select(_db.allocationsTable)
          ..where((t) => t.categoryId.equals(categoryId)))
        .get();
    double sum = 0;
    for (final a in allocations) {
      sum += a.amount;
    }
    return sum;
  }

  /// Inserts a new allocation.
  Future<void> insert(AllocationsTableCompanion entry) async {
    await _db.into(_db.allocationsTable).insert(entry);
  }

  /// Updates an existing allocation.
  Future<void> update(AllocationsTableCompanion entry) async {
    await (_db.update(_db.allocationsTable)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  /// Deletes an allocation by id.
  Future<void> delete(String id) async {
    await (_db.delete(_db.allocationsTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}