/// Single source of truth for route paths.
///
/// Customer routes all nest under `/r/:slug`, so the restaurant a diner is
/// ordering from is resolved once by the tenant shell and inherited by every
/// screen below it. No screen ever receives a restaurant id as a constructor
/// argument, and no restaurant slug is ever hardcoded.
class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String landing = '/welcome';

  // Staff auth
  static const String login = '/login';

  // Customer — nested under the tenant shell
  static const String restaurant = '/r/:slug';
  static const String menu = 'menu';
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String orderTracking = 'order/:orderId';

  // Kitchen
  static const String kitchen = '/kitchen';

  // Admin — nested under the admin shell
  static const String admin = '/admin';
  static const String adminDashboard = 'dashboard';
  static const String adminMenu = 'menu';
  static const String adminCategories = 'categories';
  static const String adminTables = 'tables';
  static const String adminOrders = 'orders';
  static const String adminAnalytics = 'analytics';
  static const String adminSettings = 'settings';

  // Route names, used for type-safe `goNamed` navigation.
  static const String nSplash = 'splash';
  static const String nLanding = 'landing';
  static const String nLogin = 'login';
  static const String nMenu = 'customer-menu';
  static const String nCart = 'customer-cart';
  static const String nCheckout = 'customer-checkout';
  static const String nOrderTracking = 'customer-order-tracking';
  static const String nKitchen = 'kitchen';
  static const String nAdminDashboard = 'admin-dashboard';
  static const String nAdminMenu = 'admin-menu';
  static const String nAdminCategories = 'admin-categories';
  static const String nAdminTables = 'admin-tables';
  static const String nAdminOrders = 'admin-orders';
  static const String nAdminAnalytics = 'admin-analytics';
  static const String nAdminSettings = 'admin-settings';

  /// Absolute customer paths, for QR generation and deep links.
  static String menuFor(String slug, {String? table}) {
    final base = '/r/$slug/menu';
    return table == null ? base : '$base?table=$table';
  }

  static String cartFor(String slug) => '/r/$slug/cart';

  static String checkoutFor(String slug) => '/r/$slug/checkout';

  static String orderFor(String slug, String orderId) =>
      '/r/$slug/order/$orderId';

  static String adminPath(String section) => '/admin/$section';
}
