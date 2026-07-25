/// Static brand and product strings.
///
/// Ching Chong's own ordering app — all customer-facing strings live here
/// and in the tenant JSON assets.
class AppConstants {
  AppConstants._();

  static const String brandName = 'Ching Chong';
  static const String productName = 'Ching Chong | Order Online';
  static const String tagline = 'Chinese Food Speciality';

  /// Query parameter carrying the table a QR code was printed for.
  static const String tableQueryParam = 'table';

  static const String defaultCurrencySymbol = '₹';
}
