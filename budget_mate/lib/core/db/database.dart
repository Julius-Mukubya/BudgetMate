import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/budget_periods_table.dart';
import 'tables/income_entries_table.dart';
import 'tables/categories_table.dart';
import 'tables/allocations_table.dart';
import 'tables/transactions_table.dart';

part 'database.g.dart';

/// The root Drift database definition for BudgetMate.
///
/// All 5 tables are registered here. Do not modify this file directly
/// for schema changes — use Drift migrations instead.
@DriftDatabase(
  tables: [
    BudgetPeriodsTable,
    IncomeEntriesTable,
    CategoriesTable,
    AllocationsTable,
    TransactionsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(dir.path, 'budget_mate'));
    await dbDir.create(recursive: true);
    final dbFile = File(p.join(dbDir.path, 'budget_mate.db'));
    return NativeDatabase(dbFile);
  });
}