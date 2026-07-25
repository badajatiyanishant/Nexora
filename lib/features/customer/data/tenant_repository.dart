import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../shared/models/menu.dart';
import '../../../shared/models/restaurant.dart';

/// Loads tenant data from bundled JSON assets.
///
/// In Milestone 5 this class is replaced by a Firestore-backed implementation
/// that satisfies the same interface, so every customer screen stays untouched.
class TenantRepository {
  const TenantRepository._();

  /// Tenant JSON root, e.g. "assets/tenants/ching-chong".
  static String _root(String slug) => 'assets/tenants/$slug';

  /// Loads restaurant identity and settings.
  static Future<Restaurant> restaurant(String slug) async {
    final json = await _load('${_root(slug)}/restaurant.json');
    return Restaurant.fromJson(json);
  }

  /// Loads the full menu: categories + items.
  static Future<Menu> menu(String slug) async {
    final json = await _load('${_root(slug)}/menu.json');
    return Menu.fromJson(json);
  }

  /// Loads the tenant-specific theme palette.
  static Future<Map<String, dynamic>> theme(String slug) async {
    return _load('${_root(slug)}/theme.json');
  }

  /// Loads admin dashboard mock data.
  static Future<Map<String, dynamic>> dashboard(String slug) async {
    return _load('${_root(slug)}/dashboard.json');
  }

  /// Loads operations mock data (tables, orders).
  static Future<Map<String, dynamic>> operations(String slug) async {
    return _load('${_root(slug)}/operations.json');
  }

  static Future<Map<String, dynamic>> _load(String path) async {
    final raw = await rootBundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
