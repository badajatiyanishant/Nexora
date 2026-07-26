import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/order.dart';
import '../../../shared/providers/orders_provider.dart';
import '../../auth/providers/auth_provider.dart';

/// Owner Dashboard — mobile-first with bottom navigation.
///
/// Phone: bottom nav bar (Dashboard / Orders / Kitchen / Menu / Settings).
/// Desktop: sidebar navigation.
/// All data is mock. Designed for restaurant owners moving around the floor.
class OwnerDashboard extends ConsumerStatefulWidget {
  const OwnerDashboard({super.key});

  @override
  ConsumerState<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends ConsumerState<OwnerDashboard> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedMockOrders(ref);
    });
  }

  void _seedMockOrders(WidgetRef ref) {
    final notifier = ref.read(ordersProvider.notifier);
    if (ref.read(ordersProvider).isNotEmpty) return;

    notifier.seedMockOrder(
      tableNumber: '3',
      status: 'received',
      ago: const Duration(minutes: 2),
      lines: const [
        OrderLine(itemId: 'cm-07', name: 'Chicken Chowmein', price: 130, quantity: 2),
        OrderLine(itemId: 'mo-08', name: 'Chicken Tandoori Momo', price: 150, quantity: 1, instructions: 'Extra spicy'),
      ],
    );
    notifier.seedMockOrder(
      tableNumber: '7',
      status: 'accepted',
      ago: const Duration(minutes: 8),
      lines: const [
        OrderLine(itemId: 'st-05', name: 'Chilly Chicken', price: 130, quantity: 1),
        OrderLine(itemId: 'fr-06', name: 'Chicken Fried Rice', price: 120, quantity: 1),
      ],
    );
    notifier.seedMockOrder(
      tableNumber: '12',
      status: 'preparing',
      ago: const Duration(minutes: 14),
      lines: const [
        OrderLine(itemId: 'cb-04', name: 'Chicken Chinese Thali', price: 230, quantity: 2),
        OrderLine(itemId: 'st-07', name: 'Chilly Paneer', price: 130, quantity: 1, instructions: 'No onions'),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    final pages = [
      const _DashboardHome(),
      const _OrdersTab(),
      _OrdersTab(filter: 'kitchen'),
      const _MenuTab(),
      const _SettingsTab(),
    ];

    if (isMobile) {
      return Scaffold(
        body: pages[_selectedTab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: (i) => setState(() => _selectedTab = i),
          backgroundColor: Theme.of(context).cardTheme.color,
          indicatorColor: const Color(0xFFC8102E).withValues(alpha: 0.12),
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFFC8102E)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: Color(0xFFC8102E)),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.soup_kitchen_outlined),
              selectedIcon: Icon(Icons.soup_kitchen_rounded, color: Color(0xFFC8102E)),
              label: 'Kitchen',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu_rounded, color: Color(0xFFC8102E)),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded, color: Color(0xFFC8102E)),
              label: 'Settings',
            ),
          ],
        ),
      );
    }

    // Desktop: sidebar layout
    return Scaffold(
      body: Row(
        children: [
          _DesktopSidebar(
            selectedTab: _selectedTab,
            onTabChanged: (i) => setState(() => _selectedTab = i),
          ),
          Expanded(child: pages[_selectedTab]),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DASHBOARD HOME
// ═══════════════════════════════════════════════════════════════════════

class _DashboardHome extends ConsumerWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orders = ref.watch(ordersProvider);

    final preparing = orders.where((o) => ['accepted', 'preparing'].contains(o.status)).length;
    final ready = orders.where((o) => o.status == 'ready').length;
    final pending = orders.where((o) => o.status == 'received').length;
    final revenue = orders.where((o) => o.status != 'cancelled').fold(0, (s, o) => s + o.subtotal);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ching Chong',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Logout
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        tooltip: 'Logout',
                        onPressed: () {
                          ref.read(adminAuthProvider.notifier).logout();
                          context.go('/');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Metric cards grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _MetricTile(
                        label: 'Revenue',
                        value: '₹$revenue',
                        icon: Icons.currency_rupee_rounded,
                        color: const Color(0xFF2E7D32),
                      ),
                      _MetricTile(
                        label: 'Orders',
                        value: '${orders.length}',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFFC8102E),
                      ),
                      _MetricTile(
                        label: 'Preparing',
                        value: '$preparing',
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(0xFFED6C02),
                      ),
                      _MetricTile(
                        label: 'Ready',
                        value: '$ready',
                        icon: Icons.notifications_active_rounded,
                        color: const Color(0xFF2E7D32),
                      ),
                      _MetricTile(
                        label: 'Pending',
                        value: '$pending',
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFF0277BD),
                      ),
                      _MetricTile(
                        label: 'Tables',
                        value: '6/12',
                        icon: Icons.table_restaurant_rounded,
                        color: const Color(0xFF6D6255),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Quick action grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _QuickAction(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Menu',
                  color: const Color(0xFFC8102E),
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.soup_kitchen_rounded,
                  label: 'Kitchen',
                  color: const Color(0xFF0277BD),
                  onTap: () => context.go('/kitchen'),
                ),
                _QuickAction(
                  icon: Icons.qr_code_rounded,
                  label: 'QR Codes',
                  color: const Color(0xFF2E7D32),
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.receipt_long_rounded,
                  label: 'Orders',
                  color: const Color(0xFFED6C02),
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  color: const Color(0xFF6D6255),
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.insights_rounded,
                  label: 'Analytics',
                  color: const Color(0xFF6A1B9A),
                  onTap: () {},
                ),
              ]),
            ),
          ),

          // Popular items
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Text(
                'Popular Today',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _PopularItem(name: 'Chicken Chowmein', orders: 82, price: 130),
                _PopularItem(name: 'Chicken Steam Momo', orders: 67, price: 100),
                _PopularItem(name: 'Honey Chilli Potato', orders: 58, price: 100),
                _PopularItem(name: 'Paneer Tikka', orders: 45, price: 130),
                _PopularItem(name: 'Veg Chinese Thali', orders: 42, price: 180),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ORDERS TAB
// ═══════════════════════════════════════════════════════════════════════

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab({this.filter});

  final String? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orders = ref.watch(ordersProvider);
    final notifier = ref.read(ordersProvider.notifier);

    List<RestaurantOrder> displayOrders;
    if (filter == 'kitchen') {
      displayOrders = orders.where((o) =>
          ['received', 'accepted', 'preparing', 'ready'].contains(o.status)).toList();
    } else {
      displayOrders = orders;
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              filter == 'kitchen' ? 'Kitchen Orders' : 'All Orders',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: displayOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 48,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text('No orders yet', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: displayOrders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final order = displayOrders[index];
                      final elapsed = DateTime.now().difference(order.placedAt);
                      return _OrderCard(
                        order: order,
                        elapsed: elapsed,
                        onAdvance: () => notifier.advanceOrder(order.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// MENU TAB
// ═══════════════════════════════════════════════════════════════════════

class _MenuTab extends StatelessWidget {
  const _MenuTab();

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

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Text(
                  'Menu (${categories.length})',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC8102E),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final c = categories[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: AppRadius.brMd,
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8102E).withValues(alpha: 0.1),
                          borderRadius: AppRadius.brSm,
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 20,
                          color: Color(0xFFC8102E),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.$1, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                            Text('${c.$2} items', style: theme.textTheme.bodySmall),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// SETTINGS TAB
// ═══════════════════════════════════════════════════════════════════════

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          _SettingsGroup(
            title: 'Restaurant Info',
            children: [
              _SettingsTile(icon: Icons.restaurant_rounded, title: 'Name', subtitle: 'Ching Chong'),
              _SettingsTile(icon: Icons.phone_rounded, title: 'Phone', subtitle: '+91 97994 26648'),
              _SettingsTile(icon: Icons.location_on_rounded, title: 'Address', subtitle: 'Raja Park, Jaipur'),
              _SettingsTile(icon: Icons.access_time_rounded, title: 'Hours', subtitle: '11:00 AM – 11:00 PM'),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Security',
            children: [
              _SettingsTile(icon: Icons.lock_rounded, title: 'Kitchen PIN', subtitle: '4832'),
              _SettingsTile(icon: Icons.admin_panel_settings_rounded, title: 'Admin PIN', subtitle: '987654'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(adminAuthProvider.notifier).logout();
                context.go('/');
              },
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFC62828)),
              label: const Text('Logout', style: TextStyle(color: Color(0xFFC62828))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFC62828)),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DESKTOP SIDEBAR
// ═══════════════════════════════════════════════════════════════════════

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.selectedTab, required this.onTabChanged});

  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF1A1614),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.restaurant_rounded, color: Color(0xFFC8102E), size: 24),
                SizedBox(width: 10),
                Text('Ching Chong', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          _SideNavItem(icon: Icons.dashboard_rounded, label: 'Home', isSelected: selectedTab == 0, onTap: () => onTabChanged(0)),
          _SideNavItem(icon: Icons.receipt_long_rounded, label: 'Orders', isSelected: selectedTab == 1, onTap: () => onTabChanged(1)),
          _SideNavItem(icon: Icons.soup_kitchen_rounded, label: 'Kitchen', isSelected: selectedTab == 2, onTap: () => onTabChanged(2)),
          _SideNavItem(icon: Icons.restaurant_menu_rounded, label: 'Menu', isSelected: selectedTab == 3, onTap: () => onTabChanged(3)),
          _SideNavItem(icon: Icons.settings_rounded, label: 'Settings', isSelected: selectedTab == 4, onTap: () => onTabChanged(4)),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: AppRadius.brSm,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: isSelected ? const Color(0xFFFFC72C) : Colors.white54),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadius.brLg,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.brSm,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.numeric(size: 22, weight: FontWeight.w800, color: theme.colorScheme.onSurface),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: AppRadius.brLg,
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.brMd,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PopularItem extends StatelessWidget {
  const _PopularItem({required this.name, required this.orders, required this.price});

  final String name;
  final int orders;
  final int price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text('$orders orders today', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text('₹$price', style: AppTypography.numeric(size: 15, weight: FontWeight.w700, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.elapsed, required this.onAdvance});

  final RestaurantOrder order;
  final Duration elapsed;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsedMin = elapsed.inMinutes;
    final statusColor = _statusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadius.brLg,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.id, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8102E).withValues(alpha: 0.1),
                  borderRadius: AppRadius.brPill,
                ),
                child: Text('Table ${order.tableNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFC8102E))),
              ),
              const Spacer(),
              Text(
                '${elapsedMin}m ago',
                style: TextStyle(fontSize: 12, color: elapsedMin > 15 ? const Color(0xFFC62828) : theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...order.lines.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text('${l.quantity}× ${l.name}', style: theme.textTheme.bodySmall),
          )),
          if (order.linesWithInstructions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFFFC72C).withValues(alpha: 0.15), borderRadius: AppRadius.brSm),
              child: Text(
                order.linesWithInstructions.map((l) => l.instructions).join(' · '),
                style: const TextStyle(fontSize: 11, color: Color(0xFFD3A017), fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: AppRadius.brPill),
                child: Text(_statusLabel(order.status), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
              ),
              const Spacer(),
              if (order.status != 'delivered' && order.status != 'cancelled')
                FilledButton(
                  onPressed: onAdvance,
                  style: FilledButton.styleFrom(
                    backgroundColor: _nextButtonColor(order.status),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.brPill),
                  ),
                  child: Text(_nextButtonLabel(order.status), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) => switch (s) {
    'received' => const Color(0xFFED6C02),
    'accepted' => const Color(0xFF0277BD),
    'preparing' => const Color(0xFF0277BD),
    'ready' => const Color(0xFF2E7D32),
    'delivered' => const Color(0xFF6D6255),
    _ => const Color(0xFF6D6255),
  };

  String _statusLabel(String s) => switch (s) {
    'received' => 'New',
    'accepted' => 'Accepted',
    'preparing' => 'Preparing',
    'ready' => 'Ready',
    'delivered' => 'Done',
    _ => s,
  };

  String _nextButtonLabel(String s) => switch (s) {
    'received' => 'Accept',
    'accepted' => 'Cooking',
    'preparing' => 'Ready',
    'ready' => 'Done',
    _ => '',
  };

  Color _nextButtonColor(String s) => switch (s) {
    'received' => const Color(0xFF0277BD),
    'accepted' => const Color(0xFFED6C02),
    'preparing' => const Color(0xFF2E7D32),
    'ready' => const Color(0xFF6D6255),
    _ => const Color(0xFF6D6255),
  };
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: AppRadius.brLg,
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.subtitle});

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
