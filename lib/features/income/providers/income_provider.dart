import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/core/db/database.dart';
import 'package:budget_mate/core/db/database_provider.dart';
import 'package:budget_mate/features/auth/providers/auth_provider.dart';
import 'package:budget_mate/core/exceptions/budget_exception.dart';
import 'package:uuid/uuid.dart';

/// Provider that watches income entries for a given period.
final incomeListProvider = AsyncNotifierProvider.family<IncomeListNotifier, List<IncomeEntriesTableData>, String>(
  IncomeListNotifier.new,
);

class IncomeListNotifier extends FamilyAsyncNotifier<List<IncomeEntriesTableData>, String> {
  @override
  Future<List<IncomeEntriesTableData>> build(String arg) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      throw const BudgetException('User not authenticated', BudgetExceptionType.unauthorized);
    }

    final dao = ref.watch(incomeEntryDaoProvider);
    return dao.watchByPeriod(arg).first;
  }

  /// Creates a new income entry for the given period.
  Future<void> create({
    required String periodId,
    required String label,
    required double amount,
    required DateTime date,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw const BudgetException('User not authenticated', BudgetExceptionType.unauthorized);
    }

    final dao = ref.read(incomeEntryDaoProvider);
    final now = DateTime.now();
    final id = const Uuid().v4();

    await dao.insert(
      IncomeEntriesTableCompanion.insert(
        id: id,
        periodId: periodId,
        userId: userId,
        label: label,
        amount: amount,
        date: date,
        createdAt: now,
      ),
    );

    ref.invalidateSelf();
  }

  /// Deletes an income entry by id.
  Future<void> delete(String id) async {
    final dao = ref.read(incomeEntryDaoProvider);
    await dao.delete(id);
    ref.invalidateSelf();
  }
}

/// Provider for the total income of a given period.
final totalIncomeProvider = FutureProvider.family<double, String>((ref, periodId) async {
  final dao = ref.watch(incomeEntryDaoProvider);
  return dao.totalByPeriod(periodId);
});