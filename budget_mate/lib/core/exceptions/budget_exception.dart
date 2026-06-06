/// Typed exception for business logic violations.
///
/// Thrown when a validation rule is violated — never silently ignored.
class BudgetException implements Exception {
  final String message;
  final BudgetExceptionType type;

  const BudgetException(this.message, this.type);

  @override
  String toString() => 'BudgetException($type): $message';
}

enum BudgetExceptionType {
  allocationExceedsIncome,
  transactionExceedsBalance,
  invalidDateRange,
  duplicateCategory,
  categoryNotEmpty,
  notFound,
  unauthorized,
}