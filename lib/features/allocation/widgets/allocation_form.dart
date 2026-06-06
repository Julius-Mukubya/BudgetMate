import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/core/providers/currency_provider.dart';
import 'package:budget_mate/features/plan/providers/plan_provider.dart';
import 'package:budget_mate/features/allocation/providers/allocation_provider.dart';

/// Result returned by the allocation form sheet.
typedef AllocationFormResult = ({String categoryId, double amount});

/// Bottom sheet form for allocating funds to a category.
Future<AllocationFormResult?> showAllocationFormSheet(
  BuildContext context,
  String periodId,
) {
  return showModalBottomSheet<AllocationFormResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _AllocationFormSheet(periodId: periodId),
  );
}

class _AllocationFormSheet extends ConsumerStatefulWidget {
  final String periodId;

  const _AllocationFormSheet({required this.periodId});

  @override
  ConsumerState<_AllocationFormSheet> createState() => _AllocationFormSheetState();
}

class _AllocationFormSheetState extends ConsumerState<_AllocationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencySymbol = ref.watch(currencySymbolProvider);
    final categoriesAsync = ref.watch(categoryListProvider(widget.periodId));
    final remainingAsync = ref.watch(remainingIncomeProvider(widget.periodId));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Allocate Funds', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            remainingAsync.when(
              data: (remaining) => Text(
                'Remaining to allocate: $currencySymbol ${remaining.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: remaining > 0 ? colorScheme.primary : colorScheme.error,
                ),
              ),
              error: (error, _) => const Text('Error loading remaining'),
              loading: () => const SizedBox(),
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: categories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text('${c.name} (planned: ${c.plannedAmount.toStringAsFixed(0)})'),
                )).toList(),
                onChanged: (value) => setState(() => _selectedCategoryId = value),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              error: (error, _) => Text('Error: $error', style: TextStyle(color: colorScheme.error)),
              loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount to Allocate',
                prefixText: '$currencySymbol ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Please enter an amount';
                final amount = double.tryParse(value.trim());
                if (amount == null || amount <= 0) return 'Please enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Allocate'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());

    Navigator.of(context).pop((
      categoryId: _selectedCategoryId!,
      amount: amount,
    ));
  }
}