import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/providers/orders_provider.dart';
import 'table_scanner_screen.dart';

/// Shown after a successful order placement.
///
/// Displays a large success animation, order number, table, prep time,
/// and buttons to track or return to menu.
class OrderSuccessScreen extends ConsumerStatefulWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderSuccessScreen> createState() =>
      _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends ConsumerState<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _checkController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tableNumber = ref.watch(tableNumberProvider) ?? '8';
    final orders = ref.watch(ordersProvider);
    final order = orders.where((o) => o.id == widget.orderId).firstOrNull;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success circle with check animation
                AnimatedBuilder(
                  animation: _checkController,
                  builder: (context, _) {
                    return ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _checkController,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                Text(
                  'Order Placed!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Your order has been sent to the kitchen',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                // Order info card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: AppRadius.brXl,
                    boxShadow: AppShadows.soft,
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.receipt_long_rounded,
                        label: 'Order',
                        value: widget.orderId,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.table_restaurant_rounded,
                        label: 'Table',
                        value: 'Table $tableNumber',
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        label: 'Est. Prep Time',
                        value: '${order?.itemCount ?? 0} items · ~22 min',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Track Order button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => context.push(
                      '/r/ching-chong/order/${widget.orderId}',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC8102E),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.brMd,
                      ),
                    ),
                    child: const Text(
                      'TRACK ORDER',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Back to menu
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => context.go(
                      RoutePaths.menuFor('ching-chong', table: tableNumber),
                    ),
                    child: Text(
                      'Back to Menu',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: AppRadius.brSm,
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
