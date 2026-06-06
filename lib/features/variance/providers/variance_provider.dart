import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/core/db/database_provider.dart';
import 'package:budget_mate/features/plan/providers/plan_provider.dart';

/// Variance data for a single category: planned vs actual.
class VarianceItem {
  final String categoryName;
  final double planned;
  final double actual;
  final double variance;
  final double variancePercent;

  VarianceItem({
    required this.categoryName,
    required this.planned,
    required this.actual,
  })  : variance = actual - planned,
        variancePercent = planned > 0 ? ((actual - planned) / planned * 100) : 0;
}

enum VarianceSort { mostOverspent, mostUnderspent, categoryName }

/// Provider that computes variance data for all categories in a period.
final varianceListProvider = FutureProvider.family<List<VarianceItem>, String>((ref, periodId) async {
  final categories = await ref.watch(categoryListProvider(periodId).future);
  final transactionDao = ref.watch(transactionDaoProvider);

  final items = <VarianceItem>[];
  for (final cat in categories) {
    final spent = await transactionDao.totalByCategory(cat.id);
    items.add(VarianceItem(
      categoryName: cat.name,
      planned: cat.plannedAmount,
      actual: spent,
    ));
  }
  return items;
});

/// Provider that returns variance data sorted by the given criterion.
final sortedVarianceProvider = Provider.family<List<VarianceItem>, ({String periodId, VarianceSort sort})>((ref, params) {
  final varianceAsync = ref.watch(varianceListProvider(params.periodId));

  return varianceAsync.when(
    loading: () => [],
    error: (_, __) => [],
    data: (items) {
      final sorted = List<VarianceItem>.from(items);
      switch (params.sort) {
        case VarianceSort.mostOverspent:
          sorted.sort((a, b) => b.variance.compareTo(a.variance));
          break;
        case VarianceSort.mostUnderspent:
          sorted.sort((a, b) => a.variance.compareTo(b.variance));
          break;
        case VarianceSort.categoryName:
          sorted.sort((a, b) => a.categoryName.compareTo(b.categoryName));
          break;
      }
      return sorted;
    },
  );
});