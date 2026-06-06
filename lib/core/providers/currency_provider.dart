import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_mate/core/models/currency.dart';

/// Provider for the selected currency.
///
/// In v1, this is a simple StateProvider hardcoded to UGX by default.
/// In future, this could be persisted per user (e.g. in shared_preferences or Firestore).
final selectedCurrencyProvider = StateProvider<Currency>((ref) {
  return Currency.defaultCurrency;
});

/// Provider that returns the currency symbol string for use in form prefixes.
final currencySymbolProvider = Provider<String>((ref) {
  return ref.watch(selectedCurrencyProvider).symbol;
});