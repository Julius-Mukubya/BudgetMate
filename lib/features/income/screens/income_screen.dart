import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:budget_mate/features/income/providers/income_provider.dart';
import 'package:budget_mate/features/income/widgets/income_form.dart';
import 'package:budget_mate/core/widgets/amount_display.dart';

/// Screen for viewing and recording income entries for a budget period.
class IncomeScreen extends ConsumerWidget {
  final String periodId;

  const IncomeScreen({super.key, required this.periodId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final incomeAsync = ref.watch(incomeListProvider(periodId));
    final totalIncomeAsync = ref.watch(totalIncomeProvider(periodId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Income'),
        backgroundColor: colorScheme.surface,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () => _addIncome(context, ref),
        child: const Icon(LucideIcons.plus),
      ),
      body: Column(
        children: [
          // Total income header
          Padding(
            padding: const EdgeInsets.all(16),
            child: totalIncomeAsync.when(
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text(
                'Error: $error',
                style: TextStyle(color: colorScheme.error),
              ),
              data: (total) => Card(
                color: colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(LucideIcons.wallet, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Income',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          AmountDisplay(
                            amount: total,
                            fontSize: 24,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Income entries list
          Expanded(
            child: incomeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.wallet,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No income recorded yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your income',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Card(
                      color: colorScheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          LucideIcons.banknote,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          entry.label,
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: AmountDisplay(
                          amount: entry.amount,
                          color: colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addIncome(BuildContext context, WidgetRef ref) async {
    final result = await showIncomeFormSheet(context);
    if (result == null) return;

    try {
      await ref.read(incomeListProvider(periodId).notifier).create(
        periodId: periodId,
        label: result.label,
        amount: result.amount,
        date: result.date,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add income: $e')),
        );
      }
    }
  }
}