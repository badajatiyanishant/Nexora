/// Static brand and product strings. No restaurant-specific value ever appears
/// here — tenant data always comes from the repository layer.
class AppConstants {
  AppConstants._();

  static const String brandName = 'Nexora';
  static const String productName = 'Nexora Orders';
  static const String tagline = 'Smart Ordering for Modern Restaurants';

  /// Query parameter carrying the table a QR code was printed for.
  static const String tableQueryParam = 'table';

  static const String defaultCurrencySymbol = '₹';
}
