import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/restaurant.dart';
import '../providers/theme_provider.dart';

/// Full-bleed hero section at the top of the customer menu.
///
/// Displays the restaurant cover, logo, name, rating, cuisines, highlights,
/// and open/closed status. Uses the tenant theme for all colours.
class RestaurantHero extends StatelessWidget {
  const RestaurantHero({
    super.key,
    required this.restaurant,
    required this.tenantTheme,
    required this.onSearchTap,
  });

  final Restaurant restaurant;
  final TenantTheme tenantTheme;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover image + gradient overlay ───────────────────────────
          SizedBox(
            height: MediaQuery.sizeOf(context).height * (isMobile ? 0.38 : 0.42),
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Cover: use the first category image as cover, or gradient
                Image.asset(
                  'assets/tenants/ching-chong/menu/chowmein.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => DecoratedBox(
                    decoration: BoxDecoration(gradient: tenantTheme.heroGradient),
                  ),
                ),
                // Dark gradient overlay for readability
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  left: 12,
                  child: _CircleIcon(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.go(RoutePaths.landing),
                  ),
                ),
                // Search icon
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  right: 12,
                  child: _CircleIcon(
                    icon: Icons.search_rounded,
                    onTap: onSearchTap,
                  ),
                ),
                // Bottom info overlay
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 16 : 32,
                      0,
                      isMobile ? 16 : 32,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo + Name
                        Row(
                          children: [
                            // Restaurant logo
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: tenantTheme.logoBackdrop,
                                borderRadius: AppRadius.brMd,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                restaurant.logo,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.restaurant_rounded,
                                  color: tenantTheme.primary,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant.name,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    restaurant.tagline,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Rating + Prep time + Price row
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _InfoChip(
                              icon: Icons.star_rounded,
                              text:
                                  '${restaurant.rating} (${_formatCount(restaurant.ratingCount)})',
                              color: tenantTheme.secondary,
                              dark: true,
                            ),
                            _InfoChip(
                              icon: Icons.schedule_rounded,
                              text: '${restaurant.service.averagePrepMinutes} min prep',
                              color: Colors.white,
                              dark: true,
                            ),
                            _InfoChip(
                              icon: Icons.currency_rupee_rounded,
                              text: '₹${restaurant.priceForTwo} for two',
                              color: Colors.white,
                              dark: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Open/Closed status + Cuisines
                        Row(
                          children: [
                            _OpenBadge(isOpen: restaurant.isOpenAt(DateTime.now())),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                restaurant.cuisines.join(' • '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Description + Highlights ─────────────────────────────────
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: EdgeInsets.fromLTRB(
              isMobile ? 16 : 32,
              20,
              isMobile ? 16 : 32,
              8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Highlights row
                if (restaurant.highlights.isNotEmpty)
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: restaurant.highlights.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final h = restaurant.highlights[index];
                        return _HighlightTile(
                          highlight: h,
                          tenantTheme: tenantTheme,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
    required this.dark,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen
            ? const Color(0xFF2E7D32).withValues(alpha: 0.9)
            : const Color(0xFFC62828).withValues(alpha: 0.9),
        borderRadius: AppRadius.brPill,
      ),
      child: Text(
        isOpen ? 'OPEN NOW' : 'CLOSED',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.highlight,
    required this.tenantTheme,
  });

  final RestaurantHighlight highlight;
  final TenantTheme tenantTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _iconFor(highlight.icon),
            size: 20,
            color: tenantTheme.primary,
          ),
          const SizedBox(height: 6),
          Text(
            highlight.value,
            style: theme.textTheme.titleSmall?.copyWith(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            highlight.label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String key) => switch (key) {
        'delivery' => Icons.location_on_outlined,
        'timer' => Icons.timer_outlined,
        'star' => Icons.star_rounded,
        'menu' => Icons.restaurant_menu_rounded,
        _ => Icons.info_outline_rounded,
      };
}
