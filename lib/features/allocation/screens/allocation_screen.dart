import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:budget_mate/features/allocation/providers/allocation_provider.dart';
import 'package:budget_mate/features/allocation/widgets/allocation_form.dart';
import 'package:budget_mate/core/widgets/amount_display.dart';

/// Screen for allocating income to categories.
class AllocationScreen extends ConsumerWidget {
  final String periodId;

  const AllocationScreen({super.key, required this.periodId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allocationsAsync = ref.watch(allocationListProvider(periodId));
    final totalAllocatedAsync = ref.watch(totalAllocatedProvider(periodId));
    final remainingAsync = ref.watch(remainingIncomeProvider(periodId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Allocations'),
        backgroundColor: colorScheme.surface,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () => _addAllocation(context, ref),
        child: const Icon(LucideIcons.plus),
      ),
      body: Column(
        children: [
          // Summary header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(LucideIcons.piggyBank, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          totalAllocatedAsync.when(
                            data: (total) => AmountDisplay(
                              amount: total,
                              fontSize: 24,
                              color: colorScheme.onSurface,
                            ),
                            loading: () => const SizedBox(height: 24, child: CircularProgressIndicator()),
                            error: (_, __) => const Text('Error'),
                          ),
                          Text(
                            'Total Allocated',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          remainingAsync.when(
                            data: (remaining) => AmountDisplay(
                              amount: remaining,
                              fontSize: 24,
                              color: remaining > 0 ? colorScheme.tertiary : colorScheme.error,
                            ),
                            loading: () => const SizedBox(height: 24, child: CircularProgressIndicator()),
                            error: (_, __) => const Text('Error'),
                          ),
                          Text(
                            'Remaining',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Allocations list
          Expanded(
            child: allocationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error: $error', style: TextStyle(color: colorScheme.error)),
              ),
              data: (allocations) {
                if (allocations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.piggyBank, size: 48, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('No allocations yet', style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        )),
                        const SizedBox(height: 8),
                        Text('Tap + to allocate funds', style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        )),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allocations.length,
                  itemBuilder: (context, index) {
                    final allocation = allocations[index];
                    return Card(
                      color: colorScheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(LucideIcons.coins, color: colorScheme.primary),
                        title: AmountDisplay(
                          amount: allocation.amount,
                          fontSize: 16,
                        ),
                        subtitle: Text('Category: ${allocation.categoryId}', style: theme.textTheme.labelSmall),
                        trailing: IconButton(
                          icon: Icon(LucideIcons.trash2, color: colorScheme.error, size: 18),
                          onPressed: () => _deleteAllocation(context, ref, allocation.id),
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

  Future<void> _addAllocation(BuildContext context, WidgetRef ref) async {
    final result = await showAllocationFormSheet(context, periodId);
    if (result == null) return;

    try {
      await ref.read(allocationListProvider(periodId).notifier).create(
        periodId: periodId,
        categoryId: result.categoryId,
        amount: result.amount,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _deleteAllocation(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(allocationListProvider(periodId).notifier).delete(id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete allocation: $e')),
        );
      }
    }
  }
}