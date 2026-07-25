import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_spacing.dart';

/// A compact, tinted status badge.
///
/// Colour is derived from the status itself so an order reads identically in
/// the kitchen queue, the admin table, and the customer tracker.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.compact = false,
    this.filled = false,
  });

  /// Builds a pill straight from an order status.
  factory StatusPill.order(
    OrderStatus status, {
    bool compact = false,
    bool filled = false,
  }) =>
      StatusPill(
        label: status.label,
        color: status.color,
        icon: status.icon,
        compact: compact,
        filled: filled,
      );

  final String label;
  final Color color;
  final IconData? icon;
  final bool compact;

  /// Solid background instead of a tint — for high-emphasis contexts.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brPill,
        border: filled
            ? null
            : Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 14, color: fg),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
