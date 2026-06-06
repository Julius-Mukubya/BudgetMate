import 'package:flutter/material.dart';
import 'package:budget_mate/core/widgets/amount_display.dart';

/// A progress bar showing allocated vs spent for a budget category.
class BudgetProgressBar extends StatelessWidget {
  final String categoryName;
  final double allocated;
  final double spent;
  final Color allocatedColor;
  final Color spentColor;

  const BudgetProgressBar({
    super.key,
    required this.categoryName,
    required this.allocated,
    required this.spent,
    this.allocatedColor = const Color(0xFF4ADE80),
    this.spentColor = const Color(0xFFF87171),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ratio = allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
    final remaining = allocated - spent;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(categoryName, style: theme.textTheme.titleMedium),
                AmountDisplay(amount: remaining, fontSize: 14,
                  color: remaining >= 0 ? colorScheme.tertiary : colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(color: colorScheme.outlineVariant),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: Container(color: spentColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Allocated: ${allocated.toStringAsFixed(0)}',
                  style: theme.textTheme.labelSmall,
                ),
                Text(
                  'Spent: ${spent.toStringAsFixed(0)}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}