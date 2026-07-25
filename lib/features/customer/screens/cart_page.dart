import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/orders_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import 'table_scanner_screen.dart';

/// Full cart view with item list, quantity controls, order summary, and
/// a checkout button.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final tenantThemeAsync = ref.watch(tenantThemeProvider);

    return tenantThemeAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (tenantTheme) {
        final primary = tenantTheme.primary;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Cart'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (cart.isNotEmpty)
                TextButton(
                  onPressed: () => cartNotifier.clear(),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          body: cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: 48,
                          color: primary.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your cart is empty',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add items from the menu to get started',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.restaurant_menu_rounded),
                        label: const Text('Browse Menu'),
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // ── Items list ────────────────────────────────
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final ci = cart.items[index];
                          return _CartItemTile(
                            cartItem: ci,
                            primaryColor: primary,
                            onAdd: () => cartNotifier.addItem(ci.item),
                            onRemove: () => cartNotifier.removeItem(ci.item),
                            onDelete: () =>
                                cartNotifier.setQuantity(ci.item, 0),
                          );
                        },
                      ),
                    ),

                    // ── Order summary + Checkout ──────────────────
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        16,
                        20,
                        MediaQuery.paddingOf(context).bottom + 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        border: Border(
                          top: BorderSide(
                            color: scheme.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        boxShadow: AppShadows.medium,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Subtotal
                          _SummaryRow(
                            label: 'Items Total (${cart.itemCount})',
                            value: '₹${cart.subtotal}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All prices are inclusive of applicable taxes.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            color: scheme.outlineVariant,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Grand Total',
                                style: theme.textTheme.titleLarge,
                              ),
                              const Spacer(),
                              Text(
                                '₹${cart.subtotal}',
                                style: AppTypography.numeric(
                                  size: 24,
                                  weight: FontWeight.w800,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: () {
                                final tableNumber =
                                    ref.read(tableNumberProvider) ?? '1';
                                final order = ref
                                    .read(ordersProvider.notifier)
                                    .placeOrder(
                                      tableNumber: tableNumber,
                                      items: cart.items,
                                    );
                                cartNotifier.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Order ${order.id} placed! 🎉 Table $tableNumber',
                                    ),
                                    backgroundColor: primary,
                                  ),
                                );
                                context.pop();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.brMd,
                                ),
                              ),
                              child: const Text(
                                'PLACE ORDER',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.cartItem,
    required this.primaryColor,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  final CartItem cartItem;
  final Color primaryColor;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food type indicator
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: cartItem.item.foodType.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.item.name,
                  style: theme.textTheme.titleSmall?.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${cartItem.item.price} each',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Quantity selector
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: AppRadius.brPill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: cartItem.quantity <= 1 ? onDelete : onRemove,
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      cartItem.quantity <= 1
                          ? Icons.delete_outline_rounded
                          : Icons.remove_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${cartItem.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Line total
          SizedBox(
            width: 60,
            child: Text(
              '₹${cartItem.lineTotal}',
              textAlign: TextAlign.end,
              style: AppTypography.numeric(
                size: 15,
                weight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
