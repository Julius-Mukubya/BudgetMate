import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/core/db/database.dart';
import 'package:budget_mate/core/db/database_provider.dart';
import 'package:budget_mate/features/auth/providers/auth_provider.dart';
import 'package:budget_mate/core/exceptions/budget_exception.dart';
import 'package:uuid/uuid.dart';

/// Provider that watches transactions for a given period.
final transactionListProvider = AsyncNotifierProvider.family<TransactionListNotifier, List<TransactionsTableData>, String>(
  TransactionListNotifier.new,
);

class TransactionListNotifier extends FamilyAsyncNotifier<List<TransactionsTableData>, String> {
  @override
  Future<List<TransactionsTableData>> build(String arg) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      throw const BudgetException('User not authenticated', BudgetExceptionType.unauthorized);
    }

    final dao = ref.watch(transactionDaoProvider);
    return dao.watchByPeriod(arg).first;
  }

  /// Creates a new spend transaction, enforcing amount ≤ remaining category balance.
  Future<void> create({
    required String periodId,
    required String categoryId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw const BudgetException('User not authenticated', BudgetExceptionType.unauthorized);
    }

    if (amount <= 0) {
      throw const BudgetException(
        'Transaction amount must be positive',
        BudgetExceptionType.transactionExceedsBalance,
      );
    }

    // Enforce invariant: transaction amount ≤ remaining category balance
    final allocatedTotal = await ref.read(allocationDaoProvider).totalByCategory(categoryId);
    final spentTotal = await ref.read(transactionDaoProvider).totalByCategory(categoryId);
    final remaining = allocatedTotal - spentTotal;

    if (amount > remaining) {
      throw BudgetException(
        'Transaction amount ($amount) exceeds remaining balance ($remaining) for this category',
        BudgetExceptionType.transactionExceedsBalance,
      );
    }

    final dao = ref.read(transactionDaoProvider);
    final now = DateTime.now();
    final id = const Uuid().v4();

    await dao.insert(
      TransactionsTableCompanion.insert(
        id: id,
        categoryId: categoryId,
        periodId: periodId,
        userId: userId,
        amount: amount,
        date: date,
        createdAt: now,
        note: note != null ? Value(note) : const Value.absent(),
      ),
    );

    ref.invalidateSelf();
  }

  /// Deletes a transaction by id.
  Future<void> delete(String id) async {
    final dao = ref.read(transactionDaoProvider);
    await dao.delete(id);
    ref.invalidateSelf();
  }
}

/// Provider for the total spent amount in a given period.
final totalSpentProvider = FutureProvider.family<double, String>((ref, periodId) async {
  final dao = ref.watch(transactionDaoProvider);
  return dao.totalByPeriod(periodId);
});