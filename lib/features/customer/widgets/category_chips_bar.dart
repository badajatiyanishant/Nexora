import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/menu.dart';
import '../providers/theme_provider.dart';

/// Horizontal scrolling category chips that sit below the hero.
///
/// The selected chip is filled with the tenant primary colour; tapping a chip
/// scrolls the menu to that category section.
class CategoryChipsBar extends StatefulWidget {
  const CategoryChipsBar({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    required this.tenantTheme,
    this.itemCounts = const {},
  });

  final List<MenuCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final TenantTheme tenantTheme;

  /// Per-category item counts, keyed by category id.
  final Map<String, int> itemCounts;

  @override
  State<CategoryChipsBar> createState() => _CategoryChipsBarState();
}

class _CategoryChipsBarState extends State<CategoryChipsBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CategoryChipsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    final index =
        widget.categories.indexWhere((c) => c.id == widget.selectedId);
    if (index < 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final targetOffset = index * 100.0; // approximate chip width
      final maxOffset =
          _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, maxOffset),
        duration: AppMotion.normal,
        curve: AppMotion.emphasized,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = widget.tenantTheme.primary;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: widget.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = widget.categories[index];
          final isSelected = cat.id == widget.selectedId;
          final count = widget.itemCounts[cat.id];

          return GestureDetector(
            onTap: () => widget.onSelected(cat.id),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.emphasized,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? primary : theme.cardTheme.color,
                borderRadius: AppRadius.brPill,
                border: Border.all(
                  color: isSelected
                      ? primary
                      : theme.colorScheme.outline.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category icon
                  Icon(
                    _iconFor(cat.icon),
                    size: 16,
                    color: isSelected ? Colors.white : primary,
                  ),
                  const SizedBox(width: 6),
                  // Category name
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  // Item count
                  if (count != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: AppRadius.brPill,
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _iconFor(String key) => switch (key) {
        'starter' => Icons.local_fire_department_rounded,
        'momo' => Icons.dining_rounded,
        'noodles' => Icons.ramen_dining_rounded,
        'rice' => Icons.rice_bowl_rounded,
        'tikka' => Icons.outdoor_grill_rounded,
        'combo' => Icons.lunch_dining_rounded,
        'roll' => Icons.wrap_text_rounded,
        'pizza' => Icons.local_pizza_rounded,
        'burger' => Icons.lunch_dining_rounded,
        'sandwich' => Icons.bakery_dining_rounded,
        'maggi' => Icons.coffee_rounded,
        'pasta' => Icons.dining_rounded,
        'soup' => Icons.soup_kitchen_rounded,
        'fries' => Icons.fastfood_rounded,
        _ => Icons.restaurant_rounded,
      };
}
