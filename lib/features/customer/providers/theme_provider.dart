import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/restaurant_scope.dart';
import '../data/tenant_repository.dart';

/// Parsed tenant theme data from theme.json.
class TenantTheme {
  const TenantTheme({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryDark,
    required this.secondaryLight,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.heroGradientColors,
    required this.accentGradientColors,
    required this.logoBackdrop,
    required this.brandName,
  });

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color onPrimary;
  final Color secondary;
  final Color secondaryDark;
  final Color secondaryLight;
  final Color onSecondary;
  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final List<Color> heroGradientColors;
  final List<Color> accentGradientColors;
  final Color logoBackdrop;
  final String brandName;

  LinearGradient get heroGradient => LinearGradient(
        colors: heroGradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get accentGradient => LinearGradient(
        colors: accentGradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static Color _hex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static List<Color> _hexList(List<dynamic> list) =>
      list.map((e) => _hex(e as String)).toList();

  factory TenantTheme.fromMap(Map<String, dynamic> json) {
    final light = json['light'] as Map<String, dynamic>;
    return TenantTheme(
      brandName: json['brandName'] as String? ?? '',
      primary: _hex(light['primary'] as String),
      primaryDark: _hex(light['primaryDark'] as String),
      primaryLight: _hex(light['primaryLight'] as String),
      onPrimary: _hex(light['onPrimary'] as String),
      secondary: _hex(light['secondary'] as String),
      secondaryDark: _hex(light['secondaryDark'] as String),
      secondaryLight: _hex(light['secondaryLight'] as String),
      onSecondary: _hex(light['onSecondary'] as String),
      background: _hex(light['background'] as String),
      surface: _hex(light['surface'] as String),
      card: _hex(light['card'] as String),
      border: _hex(light['border'] as String),
      textPrimary: _hex(light['textPrimary'] as String),
      textSecondary: _hex(light['textSecondary'] as String),
      heroGradientColors:
          _hexList(json['heroGradient'] as List<dynamic>? ?? ['#C8102E', '#8E0B20']),
      accentGradientColors:
          _hexList(json['accentGradient'] as List<dynamic>? ?? ['#FFC72C', '#FF8F00']),
      logoBackdrop: _hex(json['logoBackdrop'] as String? ?? '#1F1B18'),
    );
  }
}

/// Async provider that loads and parses the tenant theme.
final tenantThemeProvider = FutureProvider<TenantTheme>(
  dependencies: [restaurantSlugProvider],
  (ref) async {
  final slug = ref.watch(restaurantSlugProvider);
  final json = await TenantRepository.theme(slug);
  return TenantTheme.fromMap(json);
});
