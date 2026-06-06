import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:budget_mate/features/dashboard/providers/dashboard_provider.dart';
import 'package:budget_mate/core/widgets/amount_display.dart';
import 'package:budget_mate/core/widgets/budget_progress_bar.dart';

/// Dashboard screen — aggregated period view with per-category progress bars.
class DashboardScreen extends ConsumerWidget {
  final String periodId;

  const DashboardScreen({super.key, required this.periodId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardAsync = ref.watch(dashboardDataProvider(periodId));
    final breakdownsAsync = ref.watch(categoryBreakdownsProvider(periodId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: colorScheme.surface,
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: TextStyle(color: colorScheme.error)),
        ),
        data: (dashboard) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards row
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: LucideIcons.wallet,
                      label: 'Income',
                      amount: dashboard.totalIncome,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SummaryCard(
                      icon: LucideIcons.piggyBank,
                      label: 'Allocated',
                      amount: dashboard.totalAllocated,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: LucideIcons.arrowRightLeft,
                      label: 'Spent',
                      amount: dashboard.totalSpent,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SummaryCard(
                      icon: LucideIcons.banknote,
                      label: 'Remaining',
                      amount: dashboard.remainingIncome,
                      color: dashboard.remainingIncome >= 0
                          ? colorScheme.tertiary
                          : colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Category Breakdown', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              // Per-category progress bars
              breakdownsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e', style: TextStyle(color: colorScheme.error)),
                data: (breakdowns) {
                  if (breakdowns.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(LucideIcons.tags, size: 48, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              'No categories set up yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: breakdowns
                        .map((b) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: BudgetProgressBar(
                                categoryName: b.name,
                                allocated: b.allocated,
                                spent: b.spent,
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            AmountDisplay(amount: amount, fontSize: 18, color: color),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}