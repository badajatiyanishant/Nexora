import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/cart_provider.dart';

/// Animated floating bar that appears when the cart has items.
///
/// Shows item count, subtotal, and a checkout button. Slides up from the
/// bottom with a spring animation when the first item is added.
class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({
    super.key,
    required this.cart,
    required this.onTap,
    this.primaryColor,
  });

  final CartState cart;
  final VoidCallback onTap;
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = primaryColor ?? theme.colorScheme.primary;

    return AnimatedSlide(
      offset: cart.isNotEmpty ? Offset.zero : const Offset(0, 1.5),
      duration: AppMotion.normal,
      curve: AppMotion.emphasized,
      child: AnimatedOpacity(
        opacity: cart.isNotEmpty ? 1 : 0,
        duration: AppMotion.fast,
        child: cart.isEmpty
            ? const SizedBox.shrink()
            : GestureDetector(
                onTap: onTap,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: AppRadius.brLg,
                    boxShadow: [
                      ...AppShadows.glow(primary),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Item count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: AppRadius.brPill,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Label
                      const Expanded(
                        child: Text(
                          'View Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Subtotal
                      Text(
                        '₹${cart.subtotal}',
                        style: AppTypography.numeric(
                          size: 18,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
