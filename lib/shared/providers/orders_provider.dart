import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/customer/providers/cart_provider.dart';
import '../models/order.dart';

/// In-memory order store.
///
/// Shared by customer (place orders, track status), kitchen (view and advance
/// orders), and owner (analytics). In Milestone 5, each view syncs to
/// Firestore instead — the provider interface stays identical.
class OrdersNotifier extends StateNotifier<List<RestaurantOrder>> {
  OrdersNotifier() : super([]);

  int _sequence = 1000;

  /// Place an order from the cart for a given table.
  RestaurantOrder placeOrder({
    required String tableNumber,
    required List<CartItem> items,
  }) {
    final id = '#${_sequence++}';
    final now = DateTime.now();

    final lines = items
        .map((ci) => OrderLine(
              itemId: ci.item.id,
              name: ci.item.name,
              price: ci.item.price,
              quantity: ci.quantity,
            ))
        .toList();

    final order = RestaurantOrder(
      id: id,
      tableNumber: tableNumber,
      lines: lines,
      status: 'received',
      placedAt: now,
    );

    state = [order, ...state];
    return order;
  }

  /// Advance an order to its next status.
  void advanceOrder(String orderId) {
    state = [
      for (final o in state)
        if (o.id == orderId)
          o.copyWith(status: _nextStatus(o.status))
        else
          o,
    ];
  }

  /// Cancel an order.
  void cancelOrder(String orderId) {
    state = [
      for (final o in state)
        if (o.id == orderId) o.copyWith(status: 'cancelled') else o,
    ];
  }

  /// Orders filtered by status.
  List<RestaurantOrder> get received =>
      state.where((o) => o.status == 'received').toList();

  List<RestaurantOrder> get active =>
      state.where((o) => ['accepted', 'preparing', 'ready'].contains(o.status)).toList();

  List<RestaurantOrder> get completed =>
      state.where((o) => o.status == 'delivered').toList();

  List<RestaurantOrder> get allActive =>
      state.where((o) => o.status != 'delivered' && o.status != 'cancelled').toList();

  int get todayOrderCount => state.length;
  int get todayRevenue => state
      .where((o) => o.status != 'cancelled')
      .fold(0, (sum, o) => sum + o.subtotal);

  String _nextStatus(String current) => switch (current) {
        'received' => 'accepted',
        'accepted' => 'preparing',
        'preparing' => 'ready',
        'ready' => 'delivered',
        _ => current,
      };
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<RestaurantOrder>>((ref) {
  return OrdersNotifier();
});
