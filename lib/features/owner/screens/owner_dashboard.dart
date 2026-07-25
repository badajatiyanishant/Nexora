import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/order.dart';
import '../../../shared/providers/orders_provider.dart';

/// Owner Dashboard — analytics, menu management, restaurant settings.
///
/// All data is mock. Shows today's metrics, popular dishes, and management
/// panels. Designed to look like a premium SaaS dashboard.
class OwnerDashboard extends ConsumerStatefulWidget {
  const OwnerDashboard({super.key});

  @override
  ConsumerState<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends ConsumerState<OwnerDashboard> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);
    final ordersNotifier = ref.read(ordersProvider.notifier);

    // Mock some orders if empty for demo
    if (orders.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _seedMockOrders(ref);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Row(
        children: [
          // Sidebar
          _Sidebar(
            selectedTab: _selectedTab,
            onTabChanged: (i) => setState(() => _selectedTab = i),
          ),

          // Main content
          Expanded(
            child: _selectedTab == 0
                ? _DashboardTab(ordersNotifier: ordersNotifier)
                : _selectedTab == 1
                    ? const _MenuManagementTab()
                    : _SettingsTab(),
          ),
        ],
      ),
    );
  }

  void _seedMockOrders(WidgetRef ref) {
    final notifier = ref.read(ordersProvider.notifier);

    notifier.seedMockOrder(
      tableNumber: '3',
      status: 'received',
      ago: const Duration(minutes: 2),
      lines: const [
        OrderLine(itemId: 'cm-07', name: 'Chicken Chowmein', price: 130, quantity: 2),
        OrderLine(itemId: 'mo-08', name: 'Chicken Tandoori Momo', price: 150, quantity: 1,
            instructions: 'Extra spicy please'),
      ],
    );

    notifier.seedMockOrder(
      tableNumber: '7',
      status: 'accepted',
      ago: const Duration(minutes: 8),
      lines: const [
        OrderLine(itemId: 'st-05', name: 'Chilly Chicken', price: 130, quantity: 1),
        OrderLine(itemId: 'fr-06', name: 'Chicken Fried Rice', price: 120, quantity: 1),
        OrderLine(itemId: 'pt-02', name: 'Honey Chilli Potato', price: 100, quantity: 1),
      ],
    );

    notifier.seedMockOrder(
      tableNumber: '12',
      status: 'preparing',
      ago: const Duration(minutes: 14),
      lines: const [
        OrderLine(itemId: 'cb-04', name: 'Chicken Chinese Thali', price: 230, quantity: 2),
        OrderLine(itemId: 'st-07', name: 'Chilly Paneer', price: 130, quantity: 1,
            instructions: 'No onions'),
        OrderLine(itemId: 'mg-04', name: 'Cheese Maggi', price: 100, quantity: 1),
      ],
    );

    notifier.seedMockOrder(
      tableNumber: '5',
      status: 'received',
      ago: const Duration(minutes: 1),
      lines: const [
        OrderLine(itemId: 'mo-01', name: 'Veg Steam Momo', price: 80, quantity: 1),
        OrderLine(itemId: 'mo-02', name: 'Chicken Steam Momo', price: 100, quantity: 1),
      ],
    );

    notifier.seedMockOrder(
      tableNumber: '10',
      status: 'ready',
      ago: const Duration(minutes: 20),
      lines: const [
        OrderLine(itemId: 'cb-03', name: 'Veg Chinese Thali', price: 180, quantity: 1),
        OrderLine(itemId: 'st-14', name: 'French Fries', price: 80, quantity: 1),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selectedTab, required this.onTabChanged});

  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF1A1614),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8102E),
                    borderRadius: AppRadius.brSm,
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Ching Chong',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          // Nav items
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            isSelected: selectedTab == 0,
            onTap: () => onTabChanged(0),
          ),
          _NavItem(
            icon: Icons.restaurant_menu_rounded,
            label: 'Menu',
            isSelected: selectedTab == 1,
            onTap: () => onTabChanged(1),
          ),
          _NavItem(
            icon: Icons.qr_code_rounded,
            label: 'QR Codes',
            isSelected: selectedTab == 2,
            onTap: () => onTabChanged(2),
          ),
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isSelected: selectedTab == 3,
            onTap: () => onTabChanged(3),
          ),
          const Spacer(),
          // Kitchen link
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => context.go('/kitchen'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8102E).withValues(alpha: 0.2),
                  borderRadius: AppRadius.brMd,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.soup_kitchen_rounded,
                        color: Color(0xFFC8102E), size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Open Kitchen',
                      style: TextStyle(
                        color: Color(0xFFC8102E),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: AppRadius.brSm,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brSm,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon,
                    size: 20,
                    color: isSelected
                        ? const Color(0xFFFFC72C)
                        : Colors.white54),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
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

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab({required this.ordersNotifier});

  final OrdersNotifier ordersNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome back, Chef Nepal',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Metric cards
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: crossCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.0,
                children: [
                  _MetricCard(
                    label: "Today's Orders",
                    value: '${ordersNotifier.todayOrderCount}',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFFC8102E),
                    trend: '+12%',
                  ),
                  _MetricCard(
                    label: 'Revenue',
                    value: '₹${ordersNotifier.todayRevenue}',
                    icon: Icons.currency_rupee_rounded,
                    color: const Color(0xFF2E7D32),
                    trend: '+18%',
                  ),
                  _MetricCard(
                    label: 'Active Orders',
                    value: '${ordersNotifier.allActive.length}',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFED6C02),
                  ),
                  _MetricCard(
                    label: 'Completed',
                    value: '${ordersNotifier.completed.length}',
                    icon: Icons.done_all_rounded,
                    color: const Color(0xFF0277BD),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Popular dishes (mock)
          Text(
            'Popular Today',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DishChip(name: 'Chicken Chowmein', orders: 82),
              _DishChip(name: 'Chicken Steam Momo', orders: 67),
              _DishChip(name: 'Honey Chilli Potato', orders: 58),
              _DishChip(name: 'Paneer Tikka', orders: 45),
              _DishChip(name: 'Veg Chinese Thali', orders: 42),
              _DishChip(name: 'Chicken Fried Rice', orders: 38),
            ],
          ),

          const SizedBox(height: 32),

          // Recent orders
          Text(
            'Recent Orders',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...orders.take(5).map(
                (order) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: AppRadius.brMd,
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        order.id,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: AppRadius.brPill,
                        ),
                        child: Text(
                          'Table ${order.tableNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${order.subtotal}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadius.brLg,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.brSm,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.numeric(
                    size: 26,
                    weight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (trend != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                borderRadius: AppRadius.brPill,
              ),
              child: Text(
                trend!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DishChip extends StatelessWidget {
  const _DishChip({required this.name, required this.orders});

  final String name;
  final int orders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$orders',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuManagementTab extends StatelessWidget {
  const _MenuManagementTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = [
      ('Starters', 15, true),
      ('Momos', 12, true),
      ('Chowmein', 13, true),
      ('Fried Rice', 8, true),
      ('Tikka', 6, true),
      ('Combos', 5, true),
      ('Rolls', 7, true),
      ('Pizza', 8, true),
      ('Burgers', 4, true),
      ('Sandwiches', 4, true),
      ('Maggi', 7, true),
      ('Pasta', 5, true),
      ('Chouspy', 2, true),
      ('Potato', 3, true),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Menu Management',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Category'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC8102E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Categories (${categories.length})',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...categories.map(
            (c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: AppRadius.brMd,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.$1,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${c.$2} items',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: c.$3,
                    onChanged: (_) {},
                    activeThumbColor: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant Settings',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Restaurant Info',
            children: [
              _SettingsTile(
                icon: Icons.restaurant_rounded,
                title: 'Restaurant Name',
                subtitle: 'Ching Chong',
              ),
              _SettingsTile(
                icon: Icons.description_rounded,
                title: 'Tagline',
                subtitle: 'Chinese Food Speciality',
              ),
              _SettingsTile(
                icon: Icons.location_on_rounded,
                title: 'Address',
                subtitle: 'Shop 14, Raja Park, Jaipur',
              ),
              _SettingsTile(
                icon: Icons.phone_rounded,
                title: 'Phone',
                subtitle: '+91 97994 26648',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Timings',
            children: [
              _SettingsTile(
                icon: Icons.access_time_rounded,
                title: 'Weekdays',
                subtitle: '11:00 AM – 11:00 PM',
              ),
              _SettingsTile(
                icon: Icons.access_time_rounded,
                title: 'Friday & Saturday',
                subtitle: '11:00 AM – 11:30 PM',
              ),
              _SettingsTile(
                icon: Icons.access_time_rounded,
                title: 'Sunday',
                subtitle: '12:00 PM – 11:00 PM',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: AppRadius.brLg,
            border: Border.all(
              color:
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, size: 20, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodyMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }
}
