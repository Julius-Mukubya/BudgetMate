import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:budget_mate/features/plan/providers/plan_provider.dart';
import 'package:budget_mate/features/plan/widgets/category_form.dart';
import 'package:budget_mate/core/widgets/amount_display.dart';

/// Screen for managing budget categories and planned amounts.
///
/// Takes a periodId to scope all data to the current budget period.
class PlanScreen extends ConsumerWidget {
  final String periodId;

  const PlanScreen({super.key, required this.periodId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoriesAsync = ref.watch(categoryListProvider(periodId));
    final totalPlannedAsync = ref.watch(totalPlannedProvider(periodId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Budget Plan'),
        backgroundColor: colorScheme.surface,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () => _addCategory(context, ref),
        child: const Icon(LucideIcons.plus),
      ),
      body: Column(
        children: [
          // Total planned header
          Padding(
            padding: const EdgeInsets.all(16),
            child: totalPlannedAsync.when(
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
                      Icon(LucideIcons.fileSpreadsheet, color: colorScheme.secondary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Planned',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          AmountDisplay(
                            amount: total,
                            fontSize: 24,
                            color: colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Categories list
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
              data: (categories) {
                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.fileSpreadsheet,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No categories yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to plan your budget categories',
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
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      color: colorScheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          LucideIcons.tags,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          category.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AmountDisplay(
                              amount: category.plannedAmount,
                              fontSize: 16,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                LucideIcons.trash2,
                                color: colorScheme.error,
                                size: 18,
                              ),
                              onPressed: () => _deleteCategory(context, ref, category.id),
                            ),
                          ],
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

  Future<void> _addCategory(BuildContext context, WidgetRef ref) async {
    final result = await showCategoryFormSheet(context);
    if (result == null) return;

    try {
      await ref.read(categoryListProvider(periodId).notifier).create(
        periodId: periodId,
        name: result.name,
        plannedAmount: result.plannedAmount,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add category: $e')),
        );
      }
    }
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(categoryListProvider(periodId).notifier).delete(id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete category: $e')),
        );
      }
    }
  }
}