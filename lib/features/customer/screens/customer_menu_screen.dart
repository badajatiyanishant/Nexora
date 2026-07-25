import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/restaurant_scope.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/menu.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/category_chips_bar.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/food_card.dart';
import '../widgets/product_detail_sheet.dart';
import '../widgets/restaurant_hero.dart';
import 'search_screen.dart';

/// The full customer ordering screen.
///
/// Combines restaurant hero, promotional banners, offer cards, category chips,
/// food cards organised by category, and a floating cart bar into a single
/// scrollable experience. This is the main screen diners land on after scanning
/// a QR code.
class CustomerMenuScreen extends ConsumerStatefulWidget {
  const CustomerMenuScreen({super.key});

  @override
  ConsumerState<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends ConsumerState<CustomerMenuScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategoryId = '';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls to the category section in the list.
  void _scrollToCategory(String categoryId) {
    // We use a global key approach — each section is keyed by category id.
    // For simplicity, we approximate scroll position by category index.
    final menuAsync = ref.read(menuProvider);
    menuAsync.whenData((menu) {
      final index = menu.categories.indexWhere((c) => c.id == categoryId);
      if (index < 0) return;

      // Rough estimate: hero (~400) + offers (~120) + chips (56) + each section (~400)
      final offset = 400.0 + 120.0 + 56.0 + (index * 400.0);
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: AppMotion.normal,
        curve: AppMotion.emphasized,
      );
    });
  }

  void _onSearchTap() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: AppMotion.normal,
        reverseTransitionDuration: AppMotion.fast,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: AppMotion.emphasized,
                    reverseCurve: AppMotion.exit,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuAsync = ref.watch(menuProvider);
    final restaurantAsync = ref.watch(restaurantProvider);
    final tenantThemeAsync = ref.watch(tenantThemeProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: menuAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (menu) {
          return restaurantAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (restaurant) {
              return tenantThemeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (tenantTheme) {
                  // Set initial selected category
                  if (_selectedCategoryId.isEmpty &&
                      menu.categories.isNotEmpty) {
                    _selectedCategoryId = menu.categories.first.id;
                  }

                  // Build category item counts
                  final itemCounts = <String, int>{};
                  for (final cat in menu.categories) {
                    itemCounts[cat.id] = menu.countIn(cat.id);
                  }

                  return Stack(
                    children: [
                      // ── Main scrollable content ─────────────────
                      CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // Restaurant hero
                          RestaurantHero(
                            restaurant: restaurant,
                            tenantTheme: tenantTheme,
                            onSearchTap: _onSearchTap,
                          ),

                          // ── Promotional banner ─────────────────
                          SliverToBoxAdapter(
                            child: _PromotionalBanner(
                              tenantTheme: tenantTheme,
                              restaurant: restaurant,
                            ),
                          ),

                          // ── Offer cards ────────────────────────
                          SliverToBoxAdapter(
                            child: _OfferCards(tenantTheme: tenantTheme),
                          ),

                          // ── Sticky category chips ──────────────
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StickyChipsDelegate(
                              child: CategoryChipsBar(
                                categories: menu.categories,
                                selectedId: _selectedCategoryId,
                                onSelected: (id) {
                                  setState(() => _selectedCategoryId = id);
                                  _scrollToCategory(id);
                                },
                                tenantTheme: tenantTheme,
                                itemCounts: itemCounts,
                              ),
                            ),
                          ),

                          // ── Food sections by category ──────────
                          for (final cat in menu.categories)
                            _CategorySection(
                              category: cat,
                              items: menu.itemsIn(cat.id),
                              cart: cart,
                              cartNotifier: cartNotifier,
                              tenantTheme: tenantTheme,
                              onCategoryVisible: (id) {
                                if (_selectedCategoryId != id) {
                                  setState(() => _selectedCategoryId = id);
                                }
                              },
                            ),

                          // Bottom padding for floating cart
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
                          ),
                        ],
                      ),

                      // ── Floating cart bar ─────────────────────
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: FloatingCartBar(
                          cart: cart,
                          primaryColor: tenantTheme.primary,
                          onTap: () => context.push(
                            RoutePaths.cartFor(
                              ref.read(restaurantSlugProvider),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PROMOTIONAL BANNER
// ═══════════════════════════════════════════════════════════════════════

class _PromotionalBanner extends StatelessWidget {
  const _PromotionalBanner({
    required this.tenantTheme,
    required this.restaurant,
  });

  final TenantTheme tenantTheme;
  final dynamic restaurant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: tenantTheme.heroGradient,
          borderRadius: AppRadius.brLg,
          boxShadow: [
            BoxShadow(
              color: tenantTheme.primary.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎉 Welcome to Ching Chong',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '20% OFF on dine-in orders above ₹300',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppRadius.brPill,
                    ),
                    child: Text(
                      'Use code: CHING20',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.local_offer_rounded,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// OFFER CARDS (horizontal scroll)
// ═══════════════════════════════════════════════════════════════════════

class _OfferCards extends StatelessWidget {
  const _OfferCards({required this.tenantTheme});

  final TenantTheme tenantTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offers = [
      (
        icon: Icons.schedule_rounded,
        title: '22 min avg',
        subtitle: 'Fast preparation',
        color: tenantTheme.secondary,
      ),
      (
        icon: Icons.star_rounded,
        title: '4.6 rated',
        subtitle: '1,200+ reviews',
        color: const Color(0xFF2E7D32),
      ),
      (
        icon: Icons.eco_rounded,
        title: 'Fresh Food',
        subtitle: 'Made to order',
        color: tenantTheme.primary,
      ),
      (
        icon: Icons.location_on_outlined,
        title: 'Raja Park',
        subtitle: 'Jaipur, Rajasthan',
        color: tenantTheme.primary,
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        itemCount: offers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final o = offers[index];
          return Container(
            width: 160,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: AppRadius.brMd,
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(o.icon, size: 22, color: o.color),
                const SizedBox(height: 8),
                Text(
                  o.title,
                  style: theme.textTheme.titleSmall?.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  o.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// CATEGORY SECTION (used inside CustomScrollView)
// ═══════════════════════════════════════════════════════════════════════

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.items,
    required this.cart,
    required this.cartNotifier,
    required this.tenantTheme,
    required this.onCategoryVisible,
  });

  final MenuCategory category;
  final List<MenuItem> items;
  final CartState cart;
  final CartNotifier cartNotifier;
  final TenantTheme tenantTheme;
  final ValueChanged<String> onCategoryVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Category image thumbnail
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.brSm,
                      color: tenantTheme.primary.withValues(alpha: 0.08),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      category.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.restaurant_rounded,
                        size: 20,
                        color: tenantTheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        if (category.description.isNotEmpty)
                          Text(
                            category.description,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.06),
                      borderRadius: AppRadius.brPill,
                    ),
                    child: Text(
                      '${items.length} items',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Food cards
            for (final item in items)
              FoodCard(
                item: item,
                quantity: cart.quantityOf(item.id),
                primaryColor: tenantTheme.primary,
                secondaryColor: tenantTheme.secondary,
                onAdd: () => cartNotifier.addItem(item),
                onRemove: () => cartNotifier.removeItem(item),
                onTap: () => showProductDetail(
                  context,
                  item: item,
                  quantity: cart.quantityOf(item.id),
                  onAdd: () => cartNotifier.addItem(item),
                  onRemove: () => cartNotifier.removeItem(item),
                  tenantTheme: tenantTheme,
                ),
              ),

            // Bottom divider
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// STICKY CHIPS DELEGATE
// ═══════════════════════════════════════════════════════════════════════

class _StickyChipsDelegate extends SliverPersistentHeaderDelegate {
  _StickyChipsDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyChipsDelegate oldDelegate) => true;
}
