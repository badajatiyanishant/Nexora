import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Visual weight of a [NexoraButton].
enum NexoraButtonVariant { primary, secondary, outline, ghost, danger }

enum NexoraButtonSize { small, medium, large }

/// The Nexora button.
///
/// Primary buttons carry a coloured glow and press-scale, which is what makes a
/// call-to-action feel physical. Handles its own busy state so callers never
/// have to swap in a spinner.
class NexoraButton extends StatefulWidget {
  const NexoraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = NexoraButtonVariant.primary,
    this.size = NexoraButtonSize.medium,
    this.busy = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final NexoraButtonVariant variant;
  final NexoraButtonSize size;
  final bool busy;

  /// Stretch to the full width of the parent.
  final bool expand;

  @override
  State<NexoraButton> createState() => _NexoraButtonState();
}

class _NexoraButtonState extends State<NexoraButton> {
  bool _pressed = false;
  bool _hovered = false;

  bool get _enabled => widget.onPressed != null && !widget.busy;

  double get _height => switch (widget.size) {
        NexoraButtonSize.small => 40,
        NexoraButtonSize.medium => 52,
        NexoraButtonSize.large => 60,
      };

  double get _fontSize => switch (widget.size) {
        NexoraButtonSize.small => 13,
        NexoraButtonSize.medium => 15,
        NexoraButtonSize.large => 16,
      };

  EdgeInsets get _padding => switch (widget.size) {
        NexoraButtonSize.small =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        NexoraButtonSize.medium =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        NexoraButtonSize.large =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (Color bg, Color fg, Color? borderColor, bool glow) =
        switch (widget.variant) {
      NexoraButtonVariant.primary => (
          scheme.primary,
          scheme.onPrimary,
          null,
          true
        ),
      NexoraButtonVariant.secondary => (
          scheme.secondary,
          scheme.onSecondary,
          null,
          false
        ),
      NexoraButtonVariant.outline => (
          Colors.transparent,
          scheme.onSurface,
          scheme.outline,
          false
        ),
      NexoraButtonVariant.ghost => (
          Colors.transparent,
          scheme.primary,
          null,
          false
        ),
      NexoraButtonVariant.danger => (scheme.error, Colors.white, null, true),
    };

    final effectiveBg = _enabled
        ? (_hovered && widget.variant == NexoraButtonVariant.ghost
            ? scheme.primary.withValues(alpha: 0.08)
            : bg)
        : (bg == Colors.transparent
            ? bg
            : scheme.onSurface.withValues(alpha: 0.12));
    final effectiveFg =
        _enabled ? fg : scheme.onSurface.withValues(alpha: 0.38);

    return MouseRegion(
      cursor:
          _enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _enabled ? widget.onPressed : null,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: AppMotion.instant,
          curve: AppMotion.enter,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.enter,
            height: _height,
            width: widget.expand ? double.infinity : null,
            padding: _padding,
            decoration: BoxDecoration(
              color: effectiveBg,
              borderRadius: AppRadius.brMd,
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor, width: 1.5),
              boxShadow: glow && _enabled && !_pressed
                  ? AppShadows.glow(bg)
                  : null,
            ),
            child: Row(
              mainAxisSize:
                  widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.busy)
                  SizedBox(
                    width: _fontSize + 2,
                    height: _fontSize + 2,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: effectiveFg,
                    ),
                  )
                else if (widget.icon != null)
                  Icon(widget.icon, size: _fontSize + 4, color: effectiveFg),
                if (widget.busy || widget.icon != null)
                  const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w600,
                      color: effectiveFg,
                      letterSpacing: 0.1,
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
