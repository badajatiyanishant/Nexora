import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/providers/orders_provider.dart';
import 'table_scanner_screen.dart';

/// Customer-facing order tracking screen.
///
/// Shows a vertical timeline of order statuses with animations.
/// Polls the in-memory orders provider for status updates.
class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  static const _steps = [
    ('received', 'Order Received', 'Your order has been placed'),
    ('accepted', 'Accepted', 'Kitchen has acknowledged your order'),
    ('preparing', 'Preparing', 'Your food is being cooked'),
    ('ready', 'Ready', 'Pick up at the counter'),
    ('delivered', 'Served', 'Enjoy your meal!'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orders = ref.watch(ordersProvider);
    final tableNumber = ref.watch(tableNumberProvider) ?? '8';
    final order =
        orders.where((o) => o.id == orderId).firstOrNull;

    final currentStatus = order?.status ?? 'received';
    final currentIndex =
        _steps.indexWhere((s) => s.$1 == currentStatus).clamp(0, 4);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order $orderId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(
            RoutePaths.menuFor('ching-chong', table: tableNumber),
          ),
        ),
      ),
      body: order == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('Order not found',
                      style: theme.textTheme.titleMedium),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order info card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: AppRadius.brXl,
                      boxShadow: AppShadows.soft,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: AppRadius.brMd,
                          ),
                          child: Icon(
                            Icons.table_restaurant_rounded,
                            size: 28,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Table $tableNumber',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${order.itemCount} items · ₹${order.subtotal}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(currentStatus)
                                .withValues(alpha: 0.12),
                            borderRadius: AppRadius.brPill,
                          ),
                          child: Text(
                            _statusLabel(currentStatus),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _statusColor(currentStatus),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Order Status',
                    style: theme.textTheme.titleLarge,
                  ),

                  const SizedBox(height: 20),

                  // Timeline
                  ...List.generate(_steps.length, (index) {
                    final (statusKey, title, subtitle) = _steps[index];
                    final isActive = index <= currentIndex;
                    final isCurrent = index == currentIndex;
                    final isLast = index == _steps.length - 1;

                    return _TimelineStep(
                      title: title,
                      subtitle: subtitle,
                      isActive: isActive,
                      isCurrent: isCurrent,
                      isLast: isLast,
                      color: _statusColor(statusKey),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Order items list
                  Text(
                    'Your Order',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...order.lines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: AppRadius.brSm,
                            ),
                            child: Center(
                              child: Text(
                                '${line.quantity}×',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              line.name,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '₹${line.lineTotal}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Back to menu
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.go(
                        RoutePaths.menuFor('ching-chong',
                            table: tableNumber),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.brMd,
                        ),
                      ),
                      child: Text(
                        'Back to Menu',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'received' => const Color(0xFFED6C02),
        'accepted' => const Color(0xFF0277BD),
        'preparing' => const Color(0xFF0277BD),
        'ready' => const Color(0xFF2E7D32),
        'delivered' => const Color(0xFF6D6255),
        _ => const Color(0xFF6D6255),
      };

  String _statusLabel(String status) => switch (status) {
        'received' => 'Received',
        'accepted' => 'Accepted',
        'preparing' => 'Preparing',
        'ready' => 'Ready',
        'delivered' => 'Served',
        _ => status,
      };
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isCurrent,
    required this.isLast,
    required this.color,
  });

  final String title;
  final String subtitle;
  final bool isActive;
  final bool isCurrent;
  final bool isLast;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: isCurrent ? 20 : 14,
              height: isCurrent ? 20 : 14,
              decoration: BoxDecoration(
                color: isActive ? color : theme.colorScheme.outlineVariant,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: color, width: 3)
                    : null,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: isActive && !isCurrent
                  ? const Icon(Icons.check_rounded,
                      size: 10, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive
                    ? color.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant,
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: isLast ? 0 : 22),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
