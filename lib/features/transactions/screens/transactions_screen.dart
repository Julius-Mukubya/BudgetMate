import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:budget_mate/features/transactions/providers/transaction_provider.dart';
import 'package:budget_mate/features/transactions/widgets/transaction_form.dart';
import 'package:budget_mate/core/widgets/amount_display.dart';

/// Screen for viewing and recording spend transactions.
class TransactionsScreen extends ConsumerWidget {
  final String periodId;

  const TransactionsScreen({super.key, required this.periodId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final transactionsAsync = ref.watch(transactionListProvider(periodId));
    final totalSpentAsync = ref.watch(totalSpentProvider(periodId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: colorScheme.surface,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () => _addTransaction(context, ref),
        child: const Icon(LucideIcons.plus),
      ),
      body: Column(
        children: [
          // Total spent header
          Padding(
            padding: const EdgeInsets.all(16),
            child: totalSpentAsync.when(
              loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
              error: (error, _) => Text('Error: $error', style: TextStyle(color: colorScheme.error)),
              data: (total) => Card(
                color: colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(LucideIcons.arrowRightLeft, color: colorScheme.error),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Spent', style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          )),
                          AmountDisplay(amount: total, fontSize: 24, color: colorScheme.error),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Transactions list
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error', style: TextStyle(color: colorScheme.error))),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.arrowRightLeft, size: 48, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('No transactions yet', style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        )),
                        const SizedBox(height: 8),
                        Text('Tap + to record a spend', style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        )),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return Card(
                      color: colorScheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(LucideIcons.shoppingCart, color: colorScheme.error),
                        title: Text(tx.note ?? 'Transaction', style: theme.textTheme.titleMedium),
                        subtitle: Text(
                          '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        trailing: AmountDisplay(amount: tx.amount, color: colorScheme.error, fontSize: 16),
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

  Future<void> _addTransaction(BuildContext context, WidgetRef ref) async {
    final result = await showTransactionFormSheet(context, periodId);
    if (result == null) return;

    try {
      await ref.read(transactionListProvider(periodId).notifier).create(
        periodId: periodId,
        categoryId: result.categoryId,
        amount: result.amount,
        date: result.date,
        note: result.note,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}