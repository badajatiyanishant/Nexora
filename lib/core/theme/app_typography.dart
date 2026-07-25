import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nexora type system.
///
/// Two families, deliberately paired:
/// * **Plus Jakarta Sans** for display and headings — geometric, slightly
///   quirky, and distinctly premium. It carries the brand.
/// * **Inter** for body and UI — engineered for small sizes and dense
///   dashboards, so admin tables and kitchen tickets stay legible.
///
/// Display sizes use tight negative tracking, which is the single biggest
/// difference between a stock Material screen and a designed one.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle display(double size, FontWeight weight, double spacing) =>
        GoogleFonts.plusJakartaSans(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          height: 1.15,
          color: primary,
        );

    TextStyle body(double size, FontWeight weight, Color color) =>
        GoogleFonts.inter(
          fontSize: size,
          fontWeight: weight,
          height: 1.5,
          letterSpacing: 0,
          color: color,
        );

    return TextTheme(
      displayLarge: display(57, FontWeight.w800, -1.5),
      displayMedium: display(45, FontWeight.w800, -1.2),
      displaySmall: display(36, FontWeight.w700, -1),
      headlineLarge: display(32, FontWeight.w700, -0.8),
      headlineMedium: display(28, FontWeight.w700, -0.6),
      headlineSmall: display(24, FontWeight.w700, -0.4),
      titleLarge: display(20, FontWeight.w700, -0.2),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primary,
      ),
      bodyLarge: body(16, FontWeight.w400, primary),
      bodyMedium: body(14, FontWeight.w400, secondary),
      bodySmall: body(12, FontWeight.w400, secondary),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: secondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: secondary,
      ),
    );
  }

  /// Tabular figures for money and counts, so digits never jitter as values
  /// change in the live kitchen queue or analytics cards.
  static TextStyle numeric({
    required double size,
    required FontWeight weight,
    required Color color,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: -0.5,
        height: 1.1,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
