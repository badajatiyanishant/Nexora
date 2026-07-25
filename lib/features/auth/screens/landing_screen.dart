import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';

/// Ching Chong's welcome screen.
///
/// Shown briefly when diners arrive via QR code or direct link, then
/// auto-navigates to the menu. Provides a warm, branded first impression.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const String restaurantSlug = 'ching-chong';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E0B20), Color(0xFFC8102E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 32 : 64,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  FadeInUp(
                    child: Container(
                      width: isMobile ? 100 : 140,
                      height: isMobile ? 100 : 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/tenants/ching-chong/brand/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 54,
                          color: Color(0xFFC8102E),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Restaurant name
                  FadeInUp(
                    delay: const Duration(milliseconds: 120),
                    child: Text(
                      'Ching Chong',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Tagline
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Chinese Food Speciality',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Description
                  FadeInUp(
                    delay: const Duration(milliseconds: 280),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Text(
                        'Authentic Indo-Chinese cuisine prepared fresh every day. '
                        'Famous for momos, noodles, fried rice and signature sauces.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Scan QR button (primary)
                  FadeInUp(
                    delay: const Duration(milliseconds: 360),
                    child: GestureDetector(
                      onTap: () => context.go(RoutePaths.scanTable),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC72C),
                          borderRadius: AppRadius.brMd,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC72C)
                                  .withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.qr_code_scanner_rounded,
                              color: Color(0xFF1A1614),
                              size: 22,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'SCAN TABLE QR',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: const Color(0xFF1A1614),
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Browse menu (secondary)
                  FadeInUp(
                    delay: const Duration(milliseconds: 420),
                    child: GestureDetector(
                      onTap: () =>
                          context.go(RoutePaths.menuFor(restaurantSlug)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppRadius.brMd,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'BROWSE MENU',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Info chips
                  FadeInUp(
                    delay: const Duration(milliseconds: 440),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _InfoChip(
                          icon: Icons.schedule_rounded,
                          label: 'Open 11 AM – 11 PM',
                        ),
                        _InfoChip(
                          icon: Icons.location_on_outlined,
                          label: 'Raja Park, Jaipur',
                        ),
                        _InfoChip(
                          icon: Icons.star_rounded,
                          label: '4.6 Rating',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppRadius.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
