import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';

/// A menu section, e.g. Momos or Chowmein.
@immutable
class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.icon,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String description;

  /// Asset path for the category tile. May point at a missing file — the
  /// presentation layer falls back to a branded gradient placeholder.
  final String image;

  /// Semantic icon key, resolved to an [IconData] by the presentation layer.
  final String icon;
  final int sortOrder;

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        image: json['image'] as String? ?? '',
        icon: json['icon'] as String? ?? 'dish',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      );
}

/// A single dish.
@immutable
class MenuItem {
  const MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.foodType,
    required this.image,
    required this.portion,
    required this.prepMinutes,
    required this.spiceLevel,
    required this.available,
    required this.featured,
    required this.bestseller,
    required this.rating,
    required this.ratingCount,
  });

  final String id;
  final String categoryId;
  final String name;
  final String description;
  final int price;
  final FoodType foodType;

  /// Item art. Items inherit their category's image unless they override it,
  /// which keeps per-item photography optional.
  final String image;

  /// e.g. "8 Pcs" — omitted for single servings.
  final String? portion;
  final int prepMinutes;

  /// 0-3, rendered as chilli icons.
  final int spiceLevel;
  final bool available;
  final bool featured;
  final bool bestseller;
  final double rating;
  final int ratingCount;

  factory MenuItem.fromJson(
    Map<String, dynamic> json, {
    String categoryImage = '',
  }) {
    final own = json['image'] as String?;
    return MenuItem(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toInt(),
      foodType: _foodType(json['foodType'] as String?),
      image: (own == null || own.isEmpty) ? categoryImage : own,
      portion: json['portion'] as String?,
      prepMinutes: (json['prepMinutes'] as num?)?.toInt() ?? 15,
      spiceLevel: (json['spiceLevel'] as num?)?.toInt() ?? 0,
      available: json['available'] as bool? ?? true,
      featured: json['featured'] as bool? ?? false,
      bestseller: json['bestseller'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }

  static FoodType _foodType(String? value) => FoodType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => FoodType.vegetarian,
      );

  bool get isVeg =>
      foodType == FoodType.vegetarian || foodType == FoodType.vegan;

  MenuItem copyWith({bool? available, int? price, bool? featured}) => MenuItem(
        id: id,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price ?? this.price,
        foodType: foodType,
        image: image,
        portion: portion,
        prepMinutes: prepMinutes,
        spiceLevel: spiceLevel,
        available: available ?? this.available,
        featured: featured ?? this.featured,
        bestseller: bestseller,
        rating: rating,
        ratingCount: ratingCount,
      );

  /// Case-insensitive match across name, description and portion, used by the
  /// customer search field.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        (portion?.toLowerCase().contains(q) ?? false);
  }
}

/// The full menu for one tenant, with lookups the UI needs.
@immutable
class Menu {
  const Menu({required this.categories, required this.items});

  final List<MenuCategory> categories;
  final List<MenuItem> items;

  factory Menu.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List<dynamic>? ?? const [])
        .map((e) => MenuCategory.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final imageByCategory = {for (final c in categories) c.id: c.image};

    final items = (json['items'] as List<dynamic>? ?? const [])
        .map(
          (e) => MenuItem.fromJson(
            e as Map<String, dynamic>,
            categoryImage:
                imageByCategory[(e)['categoryId'] as String? ?? ''] ?? '',
          ),
        )
        .toList();

    return Menu(categories: categories, items: items);
  }

  static const Menu empty = Menu(categories: [], items: []);

  List<MenuItem> itemsIn(String categoryId) =>
      items.where((i) => i.categoryId == categoryId).toList();

  int countIn(String categoryId) =>
      items.where((i) => i.categoryId == categoryId).length;

  List<MenuItem> get featured => items.where((i) => i.featured).toList();

  List<MenuItem> get bestsellers => items.where((i) => i.bestseller).toList();

  MenuItem? itemById(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  MenuCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// Search across the whole menu, optionally narrowed to one category and to
  /// vegetarian dishes only.
  List<MenuItem> search({
    String query = '',
    String? categoryId,
    bool vegOnly = false,
  }) {
    return items.where((item) {
      if (categoryId != null && item.categoryId != categoryId) return false;
      if (vegOnly && !item.isVeg) return false;
      return item.matches(query);
    }).toList();
  }
}
