import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/core/db/database.dart';
import 'package:budget_mate/core/db/database_provider.dart';
import 'package:budget_mate/features/auth/providers/auth_provider.dart';
import 'package:budget_mate/core/exceptions/budget_exception.dart';
import 'package:uuid/uuid.dart';

/// Provider that watches categories for a given period.
final categoryListProvider = AsyncNotifierProvider.family<CategoryListNotifier, List<CategoriesTableData>, String>(
  CategoryListNotifier.new,
);

class CategoryListNotifier extends FamilyAsyncNotifier<List<CategoriesTableData>, String> {
  @override
  Future<List<CategoriesTableData>> build(String arg) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      throw const BudgetException('User not authenticated', BudgetExceptionType.unauthorized);
    }

    final dao = ref.watch(categoryDaoProvider);
    return dao.watchByPeriod(arg).first;
  }

  /// Creates a new expenditure category with a planned amount.
  Future<void> create({
    required String periodId,
    required String name,
    required double plannedAmount,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw const BudgetException('User not authenticated', BudgetExceptionType.unauthorized);
    }

    final dao = ref.read(categoryDaoProvider);
    final now = DateTime.now();
    final id = const Uuid().v4();

    await dao.insert(
      CategoriesTableCompanion.insert(
        id: id,
        periodId: periodId,
        userId: userId,
        name: name,
        plannedAmount: plannedAmount,
        createdAt: now,
      ),
    );

    ref.invalidateSelf();
  }

  /// Updates a category's planned amount.
  Future<void> updatePlannedAmount(String id, double plannedAmount) async {
    final dao = ref.read(categoryDaoProvider);
    await dao.update(
      CategoriesTableCompanion(
        id: Value(id),
        plannedAmount: Value(plannedAmount),
      ),
    );
    ref.invalidateSelf();
  }

  /// Deletes a category by id.
  ///
  /// Blocks deletion if any transactions exist for this category.
  Future<void> delete(String id) async {
    // Check if any transactions exist for this category
    final transactionDao = ref.read(transactionDaoProvider);
    final transactions = await transactionDao.totalByCategory(id);

    if (transactions > 0) {
      throw const BudgetException(
        'Cannot delete category with existing transactions. Remove transactions first.',
        BudgetExceptionType.categoryNotEmpty,
      );
    }

    final dao = ref.read(categoryDaoProvider);
    await dao.delete(id);
    ref.invalidateSelf();
  }
}

/// Provider for the total planned amount of a given period.
final totalPlannedProvider = FutureProvider.family<double, String>((ref, periodId) async {
  final categories = await ref.watch(categoryListProvider(periodId).future);
  double sum = 0;
  for (final c in categories) {
    sum += c.plannedAmount;
  }
  return sum;
});