import 'package:flutter/material.dart';

/// Nexora brand palette.
///
/// Warm and appetite-driven: a confident red anchors the brand, amber carries
/// highlights and calls-to-action, and a soft cream background keeps long menu
/// browsing comfortable. Cards stay pure white so food photography pops.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFD50000);
  static const Color primaryDark = Color(0xFF9B0000);
  static const Color primaryLight = Color(0xFFFF5131);
  static const Color secondary = Color(0xFFFFC107);
  static const Color secondaryDark = Color(0xFFC79100);
  static const Color secondaryLight = Color(0xFFFFF350);

  // Surfaces — light
  static const Color background = Color(0xFFFFF8E1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEADFC0);
  static const Color textPrimary = Color(0xFF1F1B16);
  static const Color textSecondary = Color(0xFF6D6255);

  // Surfaces — dark
  static const Color darkBackground = Color(0xFF15120E);
  static const Color darkSurface = Color(0xFF211C16);
  static const Color darkCard = Color(0xFF2B241C);
  static const Color darkBorder = Color(0xFF3D342A);
  static const Color darkTextPrimary = Color(0xFFF5EFE6);
  static const Color darkTextSecondary = Color(0xFFB6A995);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color danger = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);

  /// Order lifecycle colours, shared by the customer tracker and kitchen queue
  /// so a status reads identically on both screens.
  static const Color statusPending = Color(0xFFED6C02);
  static const Color statusPreparing = Color(0xFF0277BD);
  static const Color statusReady = Color(0xFF2E7D32);
  static const Color statusServed = Color(0xFF6D6255);
  static const Color statusCancelled = Color(0xFFC62828);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFD50000), Color(0xFFFF5131)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFF8F00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Chart series colours for the analytics dashboard.
  static const List<Color> chartPalette = [
    Color(0xFFD50000),
    Color(0xFFFFC107),
    Color(0xFF0277BD),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFED6C02),
  ];
}
