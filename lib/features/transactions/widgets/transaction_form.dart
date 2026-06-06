import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/features/plan/providers/plan_provider.dart';

/// Result returned by the transaction form sheet.
typedef TransactionFormResult = ({String categoryId, double amount, DateTime date, String? note});

/// Bottom sheet form for recording a spend transaction.
Future<TransactionFormResult?> showTransactionFormSheet(
  BuildContext context,
  String periodId,
) {
  return showModalBottomSheet<TransactionFormResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _TransactionFormSheet(periodId: periodId),
  );
}

class _TransactionFormSheet extends ConsumerStatefulWidget {
  final String periodId;

  const _TransactionFormSheet({required this.periodId});

  @override
  ConsumerState<_TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<_TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategoryId;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoriesAsync = ref.watch(categoryListProvider(widget.periodId));

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
            Text('Record Spend', style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: categories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
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
                labelText: 'Amount',
                prefixText: 'UGX ',
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
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(colorScheme: colorScheme),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('${_date.day}/${_date.month}/${_date.year}', style: theme.textTheme.bodyMedium),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. Groceries at Shoprite',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
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
              child: const Text('Record Spend'),
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
    final note = _noteController.text.trim();

    Navigator.of(context).pop((
      categoryId: _selectedCategoryId!,
      amount: amount,
      date: _date,
      note: note.isNotEmpty ? note : null,
    ));
  }
}