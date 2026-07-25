import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../../features/auth/screens/landing_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/customer/screens/cart_page.dart';
import '../../features/customer/screens/customer_menu_screen.dart';
import '../../features/customer/screens/order_success_screen.dart';
import '../../features/customer/screens/order_tracking_screen.dart';
import '../../features/customer/screens/table_scanner_screen.dart';
import '../../features/kitchen/screens/kitchen_screen.dart';
import '../../features/owner/screens/owner_dashboard.dart';
import '../../shared/widgets/placeholder_screen.dart';
import '../../shared/widgets/widgets.dart';
import '../constants/app_constants.dart';
import 'restaurant_scope.dart';
import 'route_paths.dart';

/// The Nexora route tree.
///
/// Customer routes nest inside a [ShellRoute] that resolves the restaurant
/// slug once, so screens below it never handle tenant identity themselves.
/// Screens still to be built resolve to [PlaceholderScreen], which keeps deep
/// links and the QR URL shape testable from Milestone 1.
final appRouterProvider = Provider<GoRouter>((ref) {
  // GitHub Pages serves static files — PathUrlStrategy causes 404 on refresh.
  // Hash routing (#/r/ching-chong/menu) keeps every route client-side.
  if (kIsWeb) {
    setUrlStrategy(HashUrlStrategy());
  }

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => _RouteNotFound(uri: state.uri),
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RoutePaths.nSplash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.landing,
        name: RoutePaths.nLanding,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RoutePaths.nLogin,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Staff Sign In',
          milestone: 'Milestone 5',
          icon: Icons.lock_outline_rounded,
        ),
      ),
      GoRoute(
        path: RoutePaths.scanTable,
        name: RoutePaths.nScanTable,
        builder: (context, state) => const TableScannerScreen(),
      ),

      // Customer PWA — every route below inherits the resolved restaurant.
      ShellRoute(
        builder: (context, state, child) => RestaurantScope(
          slug: state.pathParameters['slug'] ?? '',
          tableId: state.uri.queryParameters[AppConstants.tableQueryParam],
          child: child,
        ),
        routes: [
          GoRoute(
            path: '${RoutePaths.restaurant}/${RoutePaths.menu}',
            name: RoutePaths.nMenu,
            builder: (context, state) => const CustomerMenuScreen(),
          ),
          GoRoute(
            path: '${RoutePaths.restaurant}/${RoutePaths.cart}',
            name: RoutePaths.nCart,
            builder: (context, state) => const CartPage(),
          ),
          GoRoute(
            path: '${RoutePaths.restaurant}/${RoutePaths.checkout}',
            name: RoutePaths.nCheckout,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Checkout',
              milestone: 'Milestone 2',
              icon: Icons.receipt_long_rounded,
            ),
          ),
          GoRoute(
            path: '${RoutePaths.restaurant}/${RoutePaths.orderTracking}',
            name: RoutePaths.nOrderTracking,
            builder: (context, state) => OrderTrackingScreen(
              orderId: state.pathParameters['orderId'] ?? '',
            ),
          ),
          GoRoute(
            path: '${RoutePaths.restaurant}/order/:orderId/success',
            name: 'order-success',
            builder: (context, state) => OrderSuccessScreen(
              orderId: state.pathParameters['orderId'] ?? '',
            ),
          ),
        ],
      ),

      GoRoute(
        path: RoutePaths.kitchen,
        name: RoutePaths.nKitchen,
        builder: (context, state) => const KitchenScreen(),
      ),

      // Admin — redirects to the dashboard so /admin is always valid.
      GoRoute(
        path: RoutePaths.admin,
        redirect: (context, state) =>
            state.fullPath == RoutePaths.admin
                ? RoutePaths.adminPath(RoutePaths.adminDashboard)
                : null,
        routes: [
          GoRoute(
            path: RoutePaths.adminDashboard,
            name: RoutePaths.nAdminDashboard,
            builder: (context, state) => const OwnerDashboard(),
          ),
          GoRoute(
            path: RoutePaths.adminMenu,
            name: RoutePaths.nAdminMenu,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Menu Management',
              milestone: 'Milestone 3',
              icon: Icons.menu_book_rounded,
            ),
          ),
          GoRoute(
            path: RoutePaths.adminCategories,
            name: RoutePaths.nAdminCategories,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Categories',
              milestone: 'Milestone 3',
              icon: Icons.category_rounded,
            ),
          ),
          GoRoute(
            path: RoutePaths.adminTables,
            name: RoutePaths.nAdminTables,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Tables',
              milestone: 'Milestone 3',
              icon: Icons.table_restaurant_rounded,
            ),
          ),
          GoRoute(
            path: RoutePaths.adminOrders,
            name: RoutePaths.nAdminOrders,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Orders',
              milestone: 'Milestone 3',
              icon: Icons.receipt_long_rounded,
            ),
          ),
          GoRoute(
            path: RoutePaths.adminAnalytics,
            name: RoutePaths.nAdminAnalytics,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Restaurant Analytics',
              milestone: 'Milestone 3',
              icon: Icons.insights_rounded,
            ),
          ),
          GoRoute(
            path: RoutePaths.adminSettings,
            name: RoutePaths.nAdminSettings,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Restaurant Settings',
              milestone: 'Milestone 3',
              icon: Icons.settings_rounded,
            ),
          ),
        ],
      ),
    ],
  );
});

class _RouteNotFound extends StatelessWidget {
  const _RouteNotFound({required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyState(
        icon: Icons.explore_off_rounded,
        title: 'Page not found',
        message: 'Nothing lives at ${uri.path}.',
        actionLabel: 'Back to start',
        onAction: () => context.go(RoutePaths.landing),
      ),
    );
  }
}
