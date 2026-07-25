import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Animated brand reveal shown on cold start.
///
/// A single controller drives every element on a shared timeline, with each
/// piece keyed to its own interval — cheaper than several controllers and it
/// keeps the choreography readable in one place.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.splash,
  );

  /// Continuous, independent of the entrance timeline.
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  late final Animation<double> _markScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.45, curve: Curves.easeOutBack),
  );

  late final Animation<double> _markFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.3, curve: Curves.easeOut),
  );

  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
  );

  late final Animation<Offset> _titleSlide = Tween(
    begin: const Offset(0, 0.5),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
    ),
  );

  late final Animation<double> _taglineFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.5, 0.78, curve: Curves.easeOut),
  );

  late final Animation<double> _progressFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.62, 0.85, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _advanceWhenReady();
  }

  /// In Milestone 5 this is where session restore and tenant resolution will be
  /// awaited. For now the splash simply plays out and hands off to the landing
  /// screen.
  Future<void> _advanceWhenReady() async {
    await Future<void>.delayed(AppMotion.splash);
    if (mounted) context.go(RoutePaths.landing);
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E0B20), Color(0xFFC8102E), Color(0xFFE8394F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const _GlowOrb(
              alignment: Alignment(-0.85, -0.7),
              size: 320,
              color: AppColors.secondary,
            ),
            const _GlowOrb(
              alignment: Alignment(0.9, 0.75),
              size: 380,
              color: Color(0xFFFF8A65),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _markFade,
                    child: ScaleTransition(
                      scale: _markScale,
                      child: _BrandMark(shimmer: _shimmer),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        AppConstants.brandName,
                        style: AppTypography.numeric(
                          size: 46,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ).copyWith(letterSpacing: -1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Text(
                      AppConstants.tagline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.huge),
                child: FadeTransition(
                  opacity: _progressFade,
                  child: SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: AppRadius.brPill,
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Nexora mark: a rounded white tile carrying the brand glyph, with a
/// highlight sweeping across it.
class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.shimmer});

  final AnimationController shimmer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.brXxl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: AppRadius.brXxl,
            child: Image.asset(
              'assets/tenants/ching-chong/brand/logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: shimmer,
            builder: (context, _) {
              final t = shimmer.value * 2 - 1;
              return ClipRRect(
                borderRadius: AppRadius.brXxl,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                      stops: const [0.35, 0.5, 0.65],
                      begin: Alignment(t - 1, -1),
                      end: Alignment(t + 1, 1),
                    ),
                  ),
                  child: const SizedBox(width: 108, height: 108),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Soft blurred colour wash used to give the gradient depth.
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: 0.34), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}
