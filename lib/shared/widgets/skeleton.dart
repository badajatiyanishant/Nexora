import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A shimmering placeholder block.
///
/// Skeletons that match the shape of the real content make loading feel
/// faster than a spinner, because the layout never jumps once data arrives.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadius.sm,
    this.shape = BoxShape.rectangle,
  });

  /// A circular skeleton, for avatars and icon slots.
  const Skeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        radius = 0,
        shape = BoxShape.circle;

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.onSurface.withValues(alpha: 0.06);
    final highlight = scheme.onSurface.withValues(alpha: 0.11);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Sweep the highlight from off-screen left to off-screen right.
        final t = _controller.value * 2 - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(t - 1, 0),
              end: Alignment(t + 1, 0),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton in the shape of a menu item row, shown while a menu loads.
class SkeletonMenuTile extends StatelessWidget {
  const SkeletonMenuTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(width: 88, height: 88, radius: AppRadius.md),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(width: 160, height: 18),
                const SizedBox(height: AppSpacing.xs),
                const Skeleton(height: 12),
                const SizedBox(height: AppSpacing.xxs),
                const Skeleton(width: 220, height: 12),
                const SizedBox(height: AppSpacing.sm),
                const Skeleton(width: 72, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
