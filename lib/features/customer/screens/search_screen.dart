import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/food_card.dart';
import '../widgets/product_detail_sheet.dart';

/// Full-screen search experience with instant filtering.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedCategoryId;
  bool _vegOnly = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuAsync = ref.watch(menuProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final tenantThemeAsync = ref.watch(tenantThemeProvider);

    return Scaffold(
      body: menuAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (menu) {
          final results = menu.search(
            query: _searchController.text,
            categoryId: _selectedCategoryId,
            vegOnly: _vegOnly,
          );

          return tenantThemeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (tenantTheme) {
              return Column(
                children: [
                  // ── Search header ────────────────────────────────
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      MediaQuery.paddingOf(context).top + 8,
                      16,
                      12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: AppRadius.brMd,
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                onChanged: (_) => setState(() {}),
                                style: theme.textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: 'Search dishes...',
                                  hintStyle: theme.textTheme.bodyLarge
                                      ?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 20,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: theme.cardTheme.color,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.brMd,
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppRadius.brMd,
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: AppRadius.brMd,
                                    borderSide: BorderSide(
                                      color: tenantTheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Category filter chips + Veg toggle
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              // Veg only toggle
                              GestureDetector(
                                onTap: () => setState(() => _vegOnly = !_vegOnly),
                                child: AnimatedContainer(
                                  duration: AppMotion.fast,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _vegOnly
                                        ? const Color(0xFF2E7D32)
                                        : theme.cardTheme.color,
                                    borderRadius: AppRadius.brPill,
                                    border: Border.all(
                                      color: _vegOnly
                                          ? const Color(0xFF2E7D32)
                                          : theme.colorScheme.outline,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _vegOnly
                                                ? Colors.white
                                                : const Color(0xFF2E7D32),
                                            width: 1.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: _vegOnly
                                                  ? Colors.white
                                                  : const Color(0xFF2E7D32),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Veg Only',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _vegOnly
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // All categories chip
                              _FilterChip(
                                label: 'All',
                                isSelected: _selectedCategoryId == null,
                                onTap: () =>
                                    setState(() => _selectedCategoryId = null),
                                primaryColor: tenantTheme.primary,
                              ),
                              const SizedBox(width: 8),
                              // Category chips
                              for (final cat in menu.categories) ...[
                                _FilterChip(
                                  label: cat.name,
                                  isSelected: _selectedCategoryId == cat.id,
                                  onTap: () => setState(() =>
                                      _selectedCategoryId = cat.id),
                                  primaryColor: tenantTheme.primary,
                                ),
                                const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Results ──────────────────────────────────────
                  Expanded(
                    child: results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No dishes found',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try a different search or filter',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final item = results[index];
                              final qty = cart.quantityOf(item.id);
                              return FoodCard(
                                item: item,
                                quantity: qty,
                                primaryColor: tenantTheme.primary,
                                secondaryColor: tenantTheme.secondary,
                                onAdd: () => cartNotifier.addItem(item),
                                onRemove: () => cartNotifier.removeItem(item),
                                onTap: () => showProductDetail(
                                  context,
                                  item: item,
                                  quantity: qty,
                                  onAdd: () => cartNotifier.addItem(item),
                                  onRemove: () => cartNotifier.removeItem(item),
                                  tenantTheme: tenantTheme,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : theme.cardTheme.color,
          borderRadius: AppRadius.brPill,
          border: Border.all(
            color: isSelected ? primaryColor : theme.colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
