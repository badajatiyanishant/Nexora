import 'package:flutter/material.dart';

/// Spacing scale — an 8pt rhythm with a 4pt half-step.
///
/// Every gap, inset and corner in Nexora resolves to a token here. That single
/// source of truth is what makes three separate products (customer, kitchen,
/// admin) read as one premium product rather than three Flutter apps.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  static const EdgeInsets pagePadding = EdgeInsets.all(xl);
  static const EdgeInsets pagePaddingMobile = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(xl);
}

/// Corner radii. Generous by design — nothing in Nexora is sharper than 16px,
/// and primary surfaces sit at 24-28px for the soft, premium feel of Uber Eats
/// and Stripe rather than stock Material's 4px corners.
class AppRadius {
  AppRadius._();

  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 28;
  static const double xxl = 36;
  static const double pill = 999;

  static BorderRadius get brSm => BorderRadius.circular(sm);
  static BorderRadius get brMd => BorderRadius.circular(md);
  static BorderRadius get brLg => BorderRadius.circular(lg);
  static BorderRadius get brXl => BorderRadius.circular(xl);
  static BorderRadius get brXxl => BorderRadius.circular(xxl);
  static BorderRadius get brPill => BorderRadius.circular(pill);

  /// Sheets and dialogs that rise from the bottom edge.
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
}

/// Layered shadows.
///
/// Each level pairs a wide ambient shadow with a tight contact shadow — two
/// low-opacity layers read far softer and more expensive than one hard drop
/// shadow. Tinted warm rather than pure black so they sit naturally on the
/// cream background instead of looking grey and muddy.
class AppShadows {
  AppShadows._();

  static const Color _tint = Color(0xFF3D2B1F);

  /// Resting cards.
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: _tint.withValues(alpha: 0.05),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: _tint.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Raised surfaces — hovered cards, sticky bars, floating panels.
  static List<BoxShadow> get medium => [
        BoxShadow(
          color: _tint.withValues(alpha: 0.09),
          blurRadius: 36,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: _tint.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];

  /// Modals, sheets, and the cart bar that overlays content.
  static List<BoxShadow> get large => [
        BoxShadow(
          color: _tint.withValues(alpha: 0.14),
          blurRadius: 56,
          offset: const Offset(0, 24),
        ),
        BoxShadow(
          color: _tint.withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];

  /// Coloured glow beneath primary buttons, so the brand red feels lit.
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.34),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];
}

/// Motion tokens. Durations stay short and curves stay eased — animation
/// should feel responsive, never decorative.
class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 2200);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve spring = Curves.elasticOut;
}

/// Responsive breakpoints. The customer PWA is phone-first, the kitchen runs on
/// tablets, and admin lives on desktop — layout decisions key off these widths.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// Max content width so text never stretches uncomfortably on wide screens.
  static const double maxContentWidth = 1240;
}
