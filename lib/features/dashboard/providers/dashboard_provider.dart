import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/features/income/providers/income_provider.dart';
import 'package:budget_mate/features/plan/providers/plan_provider.dart';
import 'package:budget_mate/features/allocation/providers/allocation_provider.dart';
import 'package:budget_mate/features/transactions/providers/transaction_provider.dart';
import 'package:budget_mate/core/db/database_provider.dart';

/// Aggregated dashboard data for a budget period.
class DashboardData {
  final double totalIncome;
  final double totalAllocated;
  final double totalSpent;
  final double remainingIncome;
  final double unallocatedIncome;

  DashboardData({
    required this.totalIncome,
    required this.totalAllocated,
    required this.totalSpent,
    required this.remainingIncome,
    required this.unallocatedIncome,
  });
}

/// Provider that aggregates all financial data for a period's dashboard.
final dashboardDataProvider = FutureProvider.family<DashboardData, String>((ref, periodId) async {
  final totalIncome = await ref.watch(totalIncomeProvider(periodId).future);
  final totalAllocated = await ref.watch(totalAllocatedProvider(periodId).future);
  final totalSpent = await ref.watch(totalSpentProvider(periodId).future);

  return DashboardData(
    totalIncome: totalIncome,
    totalAllocated: totalAllocated,
    totalSpent: totalSpent,
    remainingIncome: totalIncome - totalSpent,
    unallocatedIncome: totalIncome - totalAllocated,
  );
});

/// Per-category breakdown for the dashboard.
class CategoryBreakdown {
  final String id;
  final String name;
  final double planned;
  final double allocated;
  final double spent;
  final double remaining;

  CategoryBreakdown({
    required this.id,
    required this.name,
    required this.planned,
    required this.allocated,
    required this.spent,
    required this.remaining,
  });
}

/// Provider that returns per-category breakdown data.
final categoryBreakdownsProvider = FutureProvider.family<List<CategoryBreakdown>, String>((ref, periodId) async {
  final categories = await ref.watch(categoryListProvider(periodId).future);
  final allocationDao = ref.watch(allocationDaoProvider);
  final transactionDao = ref.watch(transactionDaoProvider);

  final breakdowns = <CategoryBreakdown>[];
  for (final cat in categories) {
    final allocated = await allocationDao.totalByCategory(cat.id);
    final spent = await transactionDao.totalByCategory(cat.id);
    breakdowns.add(CategoryBreakdown(
      id: cat.id,
      name: cat.name,
      planned: cat.plannedAmount,
      allocated: allocated,
      spent: spent,
      remaining: allocated - spent,
    ));
  }
  return breakdowns;
});