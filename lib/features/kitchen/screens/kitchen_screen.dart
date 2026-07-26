import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/order.dart';
import '../../../shared/providers/orders_provider.dart';

/// Kitchen Display System — tablet-optimised order queue.
///
/// Shows orders in columns: New / Preparing / Ready.
/// Kitchen staff tap buttons to advance order status.
class KitchenScreen extends ConsumerWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orders = ref.watch(ordersProvider);
    final ordersNotifier = ref.read(ordersProvider.notifier);

    final newOrders = orders
        .where((o) => o.status == 'received')
        .toList();
    final preparingOrders = orders
        .where((o) => ['accepted', 'preparing'].contains(o.status))
        .toList();
    final readyOrders = orders
        .where((o) => o.status == 'ready')
        .toList();
    final completedOrders = orders
        .where((o) => o.status == 'delivered')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1614),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.soup_kitchen_rounded, size: 24),
            SizedBox(width: 10),
            Text(
              'Kitchen Display',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(kitchenAuthProvider.notifier).logout();
              context.go('/');
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
              borderRadius: AppRadius.brPill,
            ),
            child: Text(
              '${orders.where((o) => o.status != 'delivered' && o.status != 'cancelled').length} Active',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.kitchen_rounded,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No orders yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Orders will appear here when customers place them',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OrderColumn(
                    title: 'New',
                    icon: Icons.fiber_new_rounded,
                    color: const Color(0xFFED6C02),
                    orders: newOrders,
                    onAccept: (id) => ordersNotifier.advanceOrder(id),
                    buttonLabel: 'Accept',
                    buttonColor: const Color(0xFF0277BD),
                  ),
                  const SizedBox(width: 16),
                  _OrderColumn(
                    title: 'Preparing',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFF0277BD),
                    orders: preparingOrders,
                    onAccept: (id) => ordersNotifier.advanceOrder(id),
                    buttonLabel: 'Ready',
                    buttonColor: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 16),
                  _OrderColumn(
                    title: 'Ready',
                    icon: Icons.notifications_active_rounded,
                    color: const Color(0xFF2E7D32),
                    orders: readyOrders,
                    onAccept: (id) => ordersNotifier.advanceOrder(id),
                    buttonLabel: 'Completed',
                    buttonColor: const Color(0xFF6D6255),
                  ),
                  if (completedOrders.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    _OrderColumn(
                      title: 'Completed',
                      icon: Icons.done_all_rounded,
                      color: const Color(0xFF6D6255),
                      orders: completedOrders,
                      onAccept: null,
                      buttonLabel: '',
                      buttonColor: const Color(0xFF6D6255),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _OrderColumn extends StatelessWidget {
  const _OrderColumn({
    required this.title,
    required this.icon,
    required this.color,
    required this.orders,
    required this.onAccept,
    required this.buttonLabel,
    required this.buttonColor,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<RestaurantOrder> orders;
  final ValueChanged<String>? onAccept;
  final String buttonLabel;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.sm),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: AppRadius.brPill,
                  ),
                  child: Text(
                    '${orders.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order cards
          Container(
            constraints: const BoxConstraints(minHeight: 200),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.sm),
              ),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: orders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No orders',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _KitchenOrderCard(
                          order: orders[index],
                          onAction: onAccept,
                          buttonLabel: buttonLabel,
                          buttonColor: buttonColor,
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _KitchenOrderCard extends StatelessWidget {
  const _KitchenOrderCard({
    required this.order,
    required this.onAction,
    required this.buttonLabel,
    required this.buttonColor,
  });

  final RestaurantOrder order;
  final ValueChanged<String>? onAction;
  final String buttonLabel;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed = DateTime.now().difference(order.placedAt);
    final elapsedMin = elapsed.inMinutes;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order# + Table + Time
          Row(
            children: [
              Text(
                order.id,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.brPill,
                ),
                child: Text(
                  'Table ${order.tableNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${elapsedMin}m ago',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: elapsedMin > 15
                      ? const Color(0xFFC62828)
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      elapsedMin > 15 ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Items
          ...order.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '${line.quantity}×',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Special instructions
          if (order.linesWithInstructions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC72C).withValues(alpha: 0.15),
                borderRadius: AppRadius.brSm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFFD3A017),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.linesWithInstructions
                          .map((l) => '${l.name}: ${l.instructions}')
                          .join(' · '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD3A017),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action button
          if (onAction != null && buttonLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton(
                onPressed: () => onAction!(order.id),
                style: FilledButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.brSm,
                  ),
                ),
                child: Text(
                  buttonLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
