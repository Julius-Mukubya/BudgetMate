import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/core/db/database.dart';
import 'package:budget_mate/core/db/database_provider.dart';
import 'package:budget_mate/features/income/providers/income_provider.dart';
import 'package:budget_mate/features/auth/providers/auth_provider.dart';
import 'package:budget_mate/core/exceptions/budget_exception.dart';
import 'package:uuid/uuid.dart';

/// Provider that watches allocations for a given period.
final allocationListProvider = AsyncNotifierProvider.family<AllocationListNotifier, List<AllocationsTableData>, String>(
  AllocationListNotifier.new,
);

class AllocationListNotifier extends FamilyAsyncNotifier<List<AllocationsTableData>, String> {
  @override
  Future<List<AllocationsTableData>> build(String arg) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      throw const BudgetException('User not authenticated', BudgetExceptionType.unauthorized);
    }

    final dao = ref.watch(allocationDaoProvider);
    return dao.watchByPeriod(arg).first;
  }

  /// Creates a new allocation, enforcing that total allocations ≤ total income.
  Future<void> create({
    required String periodId,
    required String categoryId,
    required double amount,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw const BudgetException('User not authenticated', BudgetExceptionType.unauthorized);
    }

    if (amount <= 0) {
      throw const BudgetException(
        'Allocation amount must be positive',
        BudgetExceptionType.allocationExceedsIncome,
      );
    }

    // Enforce invariant: total allocations ≤ total income
    final totalIncome = await ref.read(totalIncomeProvider(periodId).future);
    final currentTotalAllocated = await ref.read(allocationDaoProvider).totalByPeriod(periodId);
    final newTotal = currentTotalAllocated + amount;

    if (newTotal > totalIncome) {
      throw BudgetException(
        'Total allocations ($newTotal) would exceed total income ($totalIncome)',
        BudgetExceptionType.allocationExceedsIncome,
      );
    }

    final dao = ref.read(allocationDaoProvider);
    final now = DateTime.now();
    final id = const Uuid().v4();

    await dao.insert(
      AllocationsTableCompanion.insert(
        id: id,
        categoryId: categoryId,
        periodId: periodId,
        userId: userId,
        amount: amount,
        createdAt: now,
      ),
    );

    ref.invalidateSelf();
  }

  /// Deletes an allocation by id.
  Future<void> delete(String id) async {
    final dao = ref.read(allocationDaoProvider);
    await dao.delete(id);
    ref.invalidateSelf();
  }
}

/// Provider for the total allocated amount in a given period.
final totalAllocatedProvider = FutureProvider.family<double, String>((ref, periodId) async {
  final dao = ref.watch(allocationDaoProvider);
  return dao.totalByPeriod(periodId);
});

/// Provider for the remaining unallocated income in a given period.
final remainingIncomeProvider = FutureProvider.family<double, String>((ref, periodId) async {
  final totalIncome = await ref.watch(totalIncomeProvider(periodId).future);
  final totalAllocated = await ref.watch(totalAllocatedProvider(periodId).future);
  return totalIncome - totalAllocated;
});