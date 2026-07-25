import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/menu.dart';
import '../providers/theme_provider.dart';

/// Shows a full-width bottom sheet with a large image, description, details,
/// and an add-to-cart button.
void showProductDetail(
  BuildContext context, {
  required MenuItem item,
  required int quantity,
  required VoidCallback onAdd,
  required VoidCallback onRemove,
  TenantTheme? tenantTheme,
}) {
  final scheme = Theme.of(context).colorScheme;
  final primary = tenantTheme?.primary ?? scheme.primary;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProductDetailContent(
      item: item,
      quantity: quantity,
      onAdd: onAdd,
      onRemove: onRemove,
      primaryColor: primary,
    ),
  );
}

class _ProductDetailContent extends StatelessWidget {
  const _ProductDetailContent({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.primaryColor,
  });

  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = item.image.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outline,
                  borderRadius: AppRadius.brPill,
                ),
              ),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // ── Large image ──────────────────────────────────
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.32,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (hasImage)
                            Image.asset(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _ImagePlaceholder(primaryColor: primaryColor),
                            )
                          else
                            _ImagePlaceholder(primaryColor: primaryColor),

                          // Gradient at bottom
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 80,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    theme.cardTheme.color ??
                                        theme.scaffoldBackgroundColor,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Close button
                          Positioned(
                            top: MediaQuery.paddingOf(context).top + 8,
                            right: 16,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                          // Badges on image
                          if (item.bestseller)
                            Positioned(
                              top: MediaQuery.paddingOf(context).top + 8,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC72C),
                                  borderRadius: AppRadius.brPill,
                                ),
                                child: const Text(
                                  '★ Bestseller',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ── Details ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Veg / Non-veg badge
                          _DetailFoodTypeBadge(foodType: item.foodType),
                          const SizedBox(height: 8),

                          // Name
                          Text(
                            item.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Rating + Prep + Spice row
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              if (item.rating > 0)
                                _DetailStat(
                                  icon: Icons.star_rounded,
                                  text:
                                      '${item.rating.toStringAsFixed(1)} (${item.ratingCount} ratings)',
                                  color: const Color(0xFFFFC72C),
                                ),
                              _DetailStat(
                                icon: Icons.schedule_rounded,
                                text: '${item.prepMinutes} min',
                                color: scheme.onSurfaceVariant,
                              ),
                              if (item.spiceLevel > 0)
                                _DetailStat(
                                  icon: Icons.whatshot_rounded,
                                  text: _spiceLabel(item.spiceLevel),
                                  color: _spiceColor(item.spiceLevel),
                                ),
                              if (item.portion != null)
                                _DetailStat(
                                  icon: Icons.inventory_2_outlined,
                                  text: item.portion!,
                                  color: scheme.onSurfaceVariant,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'Description',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Ingredients (mock)
                          Text(
                            'Ingredients',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _ingredientsFor(item).map((ing) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest,
                                  borderRadius: AppRadius.brPill,
                                ),
                                child: Text(
                                  ing,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),

                          // Price
                          Row(
                            children: [
                              Text(
                                '₹${item.price}',
                                style: AppTypography.numeric(
                                  size: 28,
                                  weight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                              if (item.portion != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '/ ${item.portion}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom: Add to Cart ──────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.paddingOf(context).bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  border: Border(
                    top: BorderSide(
                      color: scheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                child: quantity == 0
                    ? GestureDetector(
                        onTap: () {
                          onAdd();
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: AppRadius.brMd,
                            boxShadow: AppShadows.glow(primaryColor),
                          ),
                          child: const Center(
                            child: Text(
                              'ADD TO CART',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          // Quantity selector
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: AppRadius.brMd,
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: onRemove,
                                  child: const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Icon(
                                      Icons.remove_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  child: AnimatedSwitcher(
                                    duration: AppMotion.instant,
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                      scale: anim,
                                      child: child,
                                    ),
                                    child: Text(
                                      '$quantity',
                                      key: ValueKey(quantity),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: onAdd,
                                  child: const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: AppRadius.brMd,
                                ),
                                child: Center(
                                  child: Text(
                                    '₹${item.price * quantity}  •  Added',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _spiceLabel(int level) => switch (level) {
        1 => 'Mild',
        2 => 'Medium',
        3 => 'Spicy',
        _ => '',
      };

  Color _spiceColor(int level) => switch (level) {
        1 => const Color(0xFF2E7D32),
        2 => const Color(0xFFED6C02),
        3 => const Color(0xFFC62828),
        _ => const Color(0xFF6D6255),
      };

  List<String> _ingredientsFor(MenuItem item) {
    // Mock ingredient list based on food type and category
    final base = <String>[];
    if (item.isVeg) {
      base.addAll(['Fresh Vegetables', 'Spices', 'Oil']);
    } else {
      base.addAll(['Chicken', 'Spices', 'Oil']);
    }
    if (item.spiceLevel >= 2) base.add('Red Chilli');
    if (item.spiceLevel >= 1) base.add('Green Chilli');
    base.addAll(['Salt', 'Garlic', 'Ginger']);
    return base;
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 64,
          color: primaryColor.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

class _DetailFoodTypeBadge extends StatelessWidget {
  const _DetailFoodTypeBadge({required this.foodType});

  final FoodType foodType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: foodType.color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brPill,
        border: Border.all(color: foodType.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              border: Border.all(color: foodType.color, width: 1.5),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: foodType.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            foodType.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: foodType.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
