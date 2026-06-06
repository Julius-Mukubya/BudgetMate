import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:budget_mate/features/periods/providers/period_provider.dart';

/// History screen — lists all past budget periods with navigation to details.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final periodsAsync = ref.watch(periodListProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: colorScheme.surface,
      ),
      body: periodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: TextStyle(color: colorScheme.error)),
        ),
        data: (periods) {
          if (periods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.clock, size: 48, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No budget periods yet',
                    style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Create a period from the Periods tab',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(LucideIcons.calendar, color: colorScheme.primary),
                  title: Text(period.name, style: theme.textTheme.titleMedium),
                  subtitle: Text(
                    '${period.startDate.day}/${period.startDate.month}/${period.startDate.year} — '
                    '${period.endDate.day}/${period.endDate.month}/${period.endDate.year}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: Icon(LucideIcons.chevronRight, color: colorScheme.onSurfaceVariant),
                  onTap: () => _navigateToDetail(context, period.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String periodId) {
    // Navigate to period detail — for now just show a snackbar
    // In future: navigate to a period detail screen with full breakdown
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Period: $periodId — detail view coming soon')),
    );
  }
}