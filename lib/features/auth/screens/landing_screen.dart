import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

/// Demo launcher.
///
/// Nexora ships three products from one binary, and in production each is
/// reached by its own entry point (a QR code, a staff login, a kitchen
/// bookmark). This screen exists so all three can be shown back-to-back in a
/// single demo without retyping URLs.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  /// Demo tenant slug. Real slugs arrive from Firestore in Milestone 5;
  /// nothing downstream depends on this value.
  static const String demoSlug = 'ching-chong';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = Responsive.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: ContentContainer(
          maxWidth: 1000,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.value(mobile: AppSpacing.xxl, desktop: 72.0)),
              const FadeInUp(child: _BrandLockup()),
              SizedBox(height: r.value(mobile: AppSpacing.xl, desktop: 56.0)),
              FadeInUp(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  'Choose a product to preview',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FadeInUp(
                delay: const Duration(milliseconds: 180),
                child: _ProductGrid(columns: r.gridColumns(desktop: 3)),
              ),
              const SizedBox(height: AppSpacing.xxl),
              FadeInUp(
                delay: const Duration(milliseconds: 320),
                child: const _QrHint(),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.brMd,
                boxShadow: AppShadows.glow(AppColors.primary),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              AppConstants.brandName,
              style: AppTypography.numeric(
                size: 34,
                weight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ).copyWith(letterSpacing: -1.2),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            AppConstants.tagline,
            style: theme.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'One platform for QR ordering, kitchen operations, and everything '
            'the owner needs to run the floor.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    const products = [
      (
        icon: Icons.qr_code_scanner_rounded,
        title: 'Customer Ordering',
        body: 'Scan, browse the menu, add to cart, and track the order live.',
        color: AppColors.primary,
        route: null,
      ),
      (
        icon: Icons.soup_kitchen_rounded,
        title: 'Kitchen Display',
        body: 'A live queue of incoming tickets, advanced with one tap.',
        color: AppColors.info,
        route: RoutePaths.kitchen,
      ),
      (
        icon: Icons.insights_rounded,
        title: 'Admin Dashboard',
        body: 'Menu, categories, tables, orders, and revenue analytics.',
        color: AppColors.secondaryDark,
        route: RoutePaths.admin,
      ),
    ];

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: columns == 1 ? 2.6 : 0.98,
      children: [
        for (final p in products)
          _ProductCard(
            icon: p.icon,
            title: p.title,
            body: p.body,
            color: p.color,
            onTap: () => p.route == null
                ? context.go(RoutePaths.menuFor(LandingScreen.demoSlug))
                : context.go(p.route!),
          ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NexoraCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.brSm,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Flexible(
            child: Text(
              body,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Open',
                style: theme.textTheme.labelLarge?.copyWith(color: color),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Icon(Icons.arrow_forward_rounded, size: 16, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

class _QrHint extends StatelessWidget {
  const _QrHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NexoraCard(
      color: theme.colorScheme.surfaceContainerHigh,
      shadows: const [],
      border: Border.all(color: theme.colorScheme.outlineVariant),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How diners actually arrive',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'A QR code on each table opens '
                  '/r/{restaurant}/menu?table={table} — the restaurant and '
                  'table are read straight from the link, so no one has to '
                  'log in or pick a location.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
