import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/menu.dart';

/// A premium food item card.
///
/// Shows the food image, name, description, veg/non-veg badge, rating,
/// preparation time, price, bestseller/featured badges, and an add-to-cart
/// button with an animated quantity selector.
class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onTap,
    this.primaryColor,
    this.secondaryColor,
  });

  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final Color? primaryColor;
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = primaryColor ?? scheme.primary;
    final secondary = secondaryColor ?? scheme.secondary;
    final hasImage = item.image.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.enter,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: AppRadius.brLg,
          boxShadow: quantity > 0
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  ...AppShadows.soft,
                ]
              : AppShadows.soft,
          border: quantity > 0
              ? Border.all(color: primary.withValues(alpha: 0.2), width: 1.5)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: Image + badges ────────────────────────────────
            Expanded(
              flex: 3,
              child: _FoodImage(
                item: item,
                hasImage: hasImage,
                primaryColor: primary,
                secondaryColor: secondary,
              ),
            ),
            // ── Right: Details ──────────────────────────────────────
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Veg / Non-Veg badge
                    _FoodTypeBadge(foodType: item.foodType),
                    const SizedBox(height: 6),
                    // Name
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Rating + Prep time row
                    Row(
                      children: [
                        if (item.rating > 0) ...[
                          Icon(Icons.star_rounded, size: 14, color: secondary),
                          const SizedBox(width: 3),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${item.ratingCount})',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${item.prepMinutes} min',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Description
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Price + Add button row
                    Row(
                      children: [
                        Text(
                          '₹${item.price}',
                          style: AppTypography.numeric(
                            size: 18,
                            weight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (item.portion != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            item.portion!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Add / Quantity selector
                        if (quantity == 0)
                          _AddButton(
                            onTap: onAdd,
                            primaryColor: primary,
                          )
                        else
                          _QuantitySelector(
                            quantity: quantity,
                            onAdd: onAdd,
                            onRemove: onRemove,
                            primaryColor: primary,
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
    );
  }
}

/// Displays the food image with overlay badges.
class _FoodImage extends StatelessWidget {
  const _FoodImage({
    required this.item,
    required this.hasImage,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final MenuItem item;
  final bool hasImage;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(AppRadius.lg),
        ),
        gradient: hasImage
            ? null
            : LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.1),
                  secondaryColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image.asset(
              item.image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _PlaceholderIcon(
                primaryColor: primaryColor,
              ),
            )
          else
            _PlaceholderIcon(primaryColor: primaryColor),

          // Bestseller badge
          if (item.bestseller)
            Positioned(
              top: 8,
              left: 8,
              child: _Badge(
                label: '★ Bestseller',
                color: secondaryColor,
              ),
            ),

          // Featured badge
          if (item.featured && !item.bestseller)
            Positioned(
              top: 8,
              left: 8,
              child: _Badge(
                label: 'Featured',
                color: primaryColor,
              ),
            ),

          // Unavailable overlay
          if (!item.available)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Text(
                  'Currently\nUnavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.restaurant_rounded,
        size: 36,
        color: primaryColor.withValues(alpha: 0.3),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.brPill,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Veg / Non-Veg / Egg indicator badge.
class _FoodTypeBadge extends StatelessWidget {
  const _FoodTypeBadge({required this.foodType});

  final FoodType foodType;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            border: Border.all(color: foodType.color, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: foodType.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          foodType.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: foodType.color,
          ),
        ),
      ],
    );
  }
}

/// "ADD" button that appears when quantity is 0.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap, required this.primaryColor});

  final VoidCallback onTap;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.emphasized,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: AppRadius.brPill,
          boxShadow: AppShadows.glow(primaryColor),
        ),
        child: const Text(
          'ADD',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

/// Animated quantity selector with + and - buttons.
class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.primaryColor,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      height: 36,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: AppRadius.brPill,
        boxShadow: AppShadows.glow(primaryColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.remove_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          // Quantity
          AnimatedSwitcher(
            duration: AppMotion.instant,
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: child,
            ),
            child: Text(
              '$quantity',
              key: ValueKey(quantity),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          // Plus button
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
