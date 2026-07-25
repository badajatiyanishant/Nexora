import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/menu.dart';

/// A single line in the cart.
class CartItem {
  const CartItem({required this.item, required this.quantity});

  final MenuItem item;
  final int quantity;

  int get lineTotal => item.price * quantity;
}

/// In-memory cart state for one customer session.
///
/// Milestone 5 will persist cart state to local storage or Firestore; for the
/// demo, an in-memory notifier is all that is needed.
class CartState {
  const CartState({this.items = const []});

  final List<CartItem> items;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  int get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);

  int quantityOf(String itemId) {
    for (final ci in items) {
      if (ci.item.id == itemId) return ci.quantity;
    }
    return 0;
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(MenuItem item) {
    final existing = state.quantityOf(item.id);
    _setQuantity(item, existing + 1);
  }

  void removeItem(MenuItem item) {
    final existing = state.quantityOf(item.id);
    if (existing <= 1) {
      _remove(item.id);
    } else {
      _setQuantity(item, existing - 1);
    }
  }

  void setQuantity(MenuItem item, int qty) {
    if (qty <= 0) {
      _remove(item.id);
    } else {
      _setQuantity(item, qty);
    }
  }

  void clear() => state = const CartState();

  void _setQuantity(MenuItem item, int qty) {
    final updated = <CartItem>[];
    bool found = false;
    for (final ci in state.items) {
      if (ci.item.id == item.id) {
        updated.add(CartItem(item: item, quantity: qty));
        found = true;
      } else {
        updated.add(ci);
      }
    }
    if (!found) updated.add(CartItem(item: item, quantity: qty));
    state = CartState(items: updated);
  }

  void _remove(String itemId) {
    state = CartState(
      items: state.items.where((ci) => ci.item.id != itemId).toList(),
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
