/// Supported currencies for the app.
///
/// The user selects their preferred currency once.
class Currency {
  final String code;
  final String name;
  final String symbol;
  final String locale;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.locale,
  });

  static const List<Currency> supported = [
    Currency(code: 'UGX', name: 'Ugandan Shilling', symbol: 'UGX', locale: 'en_UG'),
    Currency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KES', locale: 'en_KE'),
    Currency(code: 'TZS', name: 'Tanzanian Shilling', symbol: 'TZS', locale: 'en_TZ'),
    Currency(code: 'RWF', name: 'Rwandan Franc', symbol: 'RWF', locale: 'en_RW'),
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', locale: 'en_US'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', locale: 'en_EU'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', locale: 'en_GB'),
    Currency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦', locale: 'en_NG'),
    Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R', locale: 'en_ZA'),
    Currency(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵', locale: 'en_GH'),
  ];

  /// Default currency.
  static const Currency defaultCurrency = Currency(
    code: 'UGX',
    name: 'Ugandan Shilling',
    symbol: 'UGX',
    locale: 'en_UG',
  );
}