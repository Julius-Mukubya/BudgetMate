import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/core/db/database.dart';
import 'package:budget_mate/core/db/database_provider.dart';
import 'package:budget_mate/features/auth/providers/auth_provider.dart';
import 'package:budget_mate/core/exceptions/budget_exception.dart';
import 'package:uuid/uuid.dart';

/// Provider that watches all budget periods for the current user.
final periodListProvider = AsyncNotifierProvider<PeriodListNotifier, List<BudgetPeriodsTableData>>(
  PeriodListNotifier.new,
);

class PeriodListNotifier extends AsyncNotifier<List<BudgetPeriodsTableData>> {
  @override
  Future<List<BudgetPeriodsTableData>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      throw const BudgetException('User not authenticated', BudgetExceptionType.unauthorized);
    }

    final dao = ref.watch(budgetPeriodDaoProvider);
    return dao.watchAll(userId).first;
  }

  /// Creates a new budget period.
  Future<void> create({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
      throw const BudgetException(
        'End date must be after start date',
        BudgetExceptionType.invalidDateRange,
      );
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw const BudgetException('User not authenticated', BudgetExceptionType.unauthorized);
    }

    final dao = ref.read(budgetPeriodDaoProvider);
    final now = DateTime.now();
    final id = const Uuid().v4();

    await dao.insert(
      BudgetPeriodsTableCompanion.insert(
        id: id,
        userId: userId,
        name: name,
        startDate: startDate,
        endDate: endDate,
        createdAt: now,
      ),
    );

    ref.invalidateSelf();
  }

  /// Deletes a budget period by id.
  Future<void> delete(String id) async {
    final dao = ref.read(budgetPeriodDaoProvider);
    await dao.delete(id);
    ref.invalidateSelf();
  }
}