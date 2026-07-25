import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// The core surface of the Nexora design system.
///
/// A soft, generously rounded card with layered shadows. When [onTap] is given
/// it becomes interactive and lifts on hover — the small motion that makes a
/// dashboard feel responsive rather than static.
class NexoraCard extends StatefulWidget {
  const NexoraCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.cardPadding,
    this.radius = AppRadius.lg,
    this.color,
    this.border,
    this.shadows,
    this.gradient,
    this.clip = false,
    this.width,
    this.height,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;

  /// Clip the child to the card's radius — needed when the card holds imagery.
  final bool clip;
  final double? width;
  final double? height;

  @override
  State<NexoraCard> createState() => _NexoraCardState();
}

class _NexoraCardState extends State<NexoraCard> {
  bool _hovered = false;

  bool get _interactive => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(widget.radius);
    final lifted = _interactive && _hovered;

    final content = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.enter,
      width: widget.width,
      height: widget.height,
      transform: lifted
          ? (Matrix4.identity()..translateByDouble(0, -3, 0, 1))
          : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.gradient == null
            ? (widget.color ?? theme.cardTheme.color)
            : null,
        gradient: widget.gradient,
        borderRadius: radius,
        border: widget.border,
        boxShadow:
            widget.shadows ?? (lifted ? AppShadows.medium : AppShadows.soft),
      ),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    final body = widget.clip
        ? ClipRRect(borderRadius: radius, child: content)
        : content;

    if (!_interactive) return body;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: body,
      ),
    );
  }
}
