import 'dart:async';
import 'package:drift/drift.dart';
import 'package:budget_mate/core/db/database.dart';

/// DAO for Category CRUD operations.
class CategoryDao {
  final AppDatabase _db;

  const CategoryDao(this._db);

  /// Returns all categories for a given period.
  Stream<List<CategoriesTableData>> watchByPeriod(String periodId) {
    return (_db.select(_db.categoriesTable)
          ..where((t) => t.periodId.equals(periodId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Returns a single category by id.
  Future<CategoriesTableData?> getById(String id) async {
    return await (_db.select(_db.categoriesTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserts a new category.
  Future<void> insert(CategoriesTableCompanion entry) async {
    await _db.into(_db.categoriesTable).insert(entry);
  }

  /// Updates an existing category.
  Future<void> update(CategoriesTableCompanion entry) async {
    await (_db.update(_db.categoriesTable)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  /// Deletes a category by id.
  Future<void> delete(String id) async {
    await (_db.delete(_db.categoriesTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}