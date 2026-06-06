import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:budget_mate/features/variance/providers/variance_provider.dart';
import 'package:budget_mate/core/widgets/amount_display.dart';

/// Variance screen — planned vs actual per category, color-coded and sortable.
class VarianceScreen extends ConsumerWidget {
  final String periodId;

  const VarianceScreen({super.key, required this.periodId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sort = ref.watch(_varianceSortProvider);
    final sortedItems = ref.watch(sortedVarianceProvider((
      periodId: periodId,
      sort: sort,
    )));
    final totalAsync = ref.watch(varianceListProvider(periodId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Variance'),
        backgroundColor: colorScheme.surface,
        actions: [
          PopupMenuButton<VarianceSort>(
            icon: Icon(LucideIcons.arrowUpDown, color: colorScheme.onSurface),
            onSelected: (value) => ref.read(_varianceSortProvider.notifier).state = value,
            itemBuilder: (_) => [
              PopupMenuItem(value: VarianceSort.mostOverspent, child: const Text('Most Overspent')),
              PopupMenuItem(value: VarianceSort.mostUnderspent, child: const Text('Most Underspent')),
              PopupMenuItem(value: VarianceSort.categoryName, child: const Text('Category Name')),
            ],
          ),
        ],
      ),
      body: totalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: colorScheme.error))),
        data: (items) {
          final totalPlanned = items.fold(0.0, (sum, i) => sum + i.planned);
          final totalActual = items.fold(0.0, (sum, i) => sum + i.actual);
          final totalVariance = totalActual - totalPlanned;

          return Column(
            children: [
              // Period-level summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(LucideIcons.barChart3,
                          color: totalVariance <= 0 ? colorScheme.tertiary : colorScheme.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Planned vs Spent',
                                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                              AmountDisplay(amount: totalVariance, fontSize: 20,
                                color: totalVariance <= 0 ? colorScheme.tertiary : colorScheme.error),
                            ],
                          ),
                        ),
                        Text(
                          '${totalVariance >= 0 ? "+" : ""}${totalVariance.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: totalVariance <= 0 ? colorScheme.tertiary : colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Variance list
              Expanded(
                child: sortedItems.isEmpty
                    ? Center(child: Text('No categories to compare',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sortedItems.length,
                        itemBuilder: (_, i) {
                          final item = sortedItems[i];
                          final isUnder = item.variance <= 0;
                          final isNear = !isUnder && item.variancePercent <= 10;
                          final Color itemColor;
                          if (isUnder) {
                            itemColor = colorScheme.tertiary; // green - under budget
                          } else if (isNear) {
                            itemColor = colorScheme.secondary; // amber - within 10%
                          } else {
                            itemColor = colorScheme.error; // red - over budget
                          }

                          return Card(
                            color: colorScheme.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.categoryName, style: theme.textTheme.titleMedium),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text('Plan: ', style: theme.textTheme.labelSmall),
                                            AmountDisplay(amount: item.planned, fontSize: 12),
                                            const SizedBox(width: 12),
                                            Text('Actual: ', style: theme.textTheme.labelSmall),
                                            AmountDisplay(amount: item.actual, fontSize: 12),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      AmountDisplay(amount: item.variance, fontSize: 16, color: itemColor),
                                      Text(
                                        '${item.variancePercent.toStringAsFixed(0)}%',
                                        style: theme.textTheme.labelSmall?.copyWith(color: itemColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

final _varianceSortProvider = StateProvider<VarianceSort>((ref) => VarianceSort.mostOverspent);