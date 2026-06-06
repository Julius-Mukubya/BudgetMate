import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:budget_mate/features/periods/providers/period_provider.dart';
import 'package:budget_mate/features/periods/widgets/period_form.dart';

/// Screen for listing and creating budget periods.
class PeriodsScreen extends ConsumerWidget {
  const PeriodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final periodsAsync = ref.watch(periodListProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Budget Periods'),
        backgroundColor: colorScheme.surface,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () => _createPeriod(context, ref),
        child: const Icon(LucideIcons.plus),
      ),
      body: periodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
        data: (periods) {
          if (periods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.calendarPlus,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budget periods yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first period',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: periods.length,
            itemBuilder: (context, index) {
              final period = periods[index];
              return Card(
                color: colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    period.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '${period.startDate.day}/${period.startDate.month}/${period.startDate.year} — '
                    '${period.endDate.day}/${period.endDate.month}/${period.endDate.year}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      LucideIcons.trash2,
                      color: colorScheme.error,
                    ),
                    onPressed: () => _deletePeriod(context, ref, period.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _createPeriod(BuildContext context, WidgetRef ref) async {
    final result = await showPeriodFormSheet(context);
    if (result == null) return;

    try {
      await ref.read(periodListProvider.notifier).create(
        name: result.name,
        startDate: result.startDate,
        endDate: result.endDate,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create period: $e')),
        );
      }
    }
  }

  Future<void> _deletePeriod(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(periodListProvider.notifier).delete(id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete period: $e')),
        );
      }
    }
  }
}