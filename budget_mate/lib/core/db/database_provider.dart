import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/core/db/database.dart';
import 'package:budget_mate/core/db/daos/budget_period_dao.dart';
import 'package:budget_mate/core/db/daos/income_entry_dao.dart';
import 'package:budget_mate/core/db/daos/category_dao.dart';
import 'package:budget_mate/core/db/daos/allocation_dao.dart';
import 'package:budget_mate/core/db/daos/transaction_dao.dart';

/// Provider for the AppDatabase instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider for BudgetPeriodDao.
final budgetPeriodDaoProvider = Provider<BudgetPeriodDao>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetPeriodDao(db);
});

/// Provider for IncomeEntryDao.
final incomeEntryDaoProvider = Provider<IncomeEntryDao>((ref) {
  final db = ref.watch(databaseProvider);
  return IncomeEntryDao(db);
});

/// Provider for CategoryDao.
final categoryDaoProvider = Provider<CategoryDao>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryDao(db);
});

/// Provider for AllocationDao.
final allocationDaoProvider = Provider<AllocationDao>((ref) {
  final db = ref.watch(databaseProvider);
  return AllocationDao(db);
});

/// Provider for TransactionDao.
final transactionDaoProvider = Provider<TransactionDao>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionDao(db);
});