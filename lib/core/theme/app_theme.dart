import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the Nexora Material 3 themes.
///
/// Colour schemes are declared explicitly rather than generated from a seed:
/// `ColorScheme.fromSeed` would desaturate the brand red and drift the cream
/// background toward grey. Every component theme below is overridden so no
/// screen inherits stock Material geometry — that is what separates this from
/// a default Flutter app.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFDAD4),
      onPrimaryContainer: Color(0xFF410000),
      secondary: AppColors.secondary,
      onSecondary: Color(0xFF3E2E00),
      secondaryContainer: Color(0xFFFFECB3),
      onSecondaryContainer: Color(0xFF251A00),
      tertiary: Color(0xFF2E7D32),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFB8F5B9),
      onTertiaryContainer: Color(0xFF00210A),
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFFFFCF5),
      surfaceContainer: AppColors.background,
      surfaceContainerHigh: Color(0xFFFDF2D8),
      surfaceContainerHighest: Color(0xFFF7EBCF),
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: Color(0xFFF0E6CE),
      shadow: Color(0xFF3D2B1F),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF352F27),
      onInverseSurface: Color(0xFFFAEFE0),
      inversePrimary: Color(0xFFFFB4A6),
    );

    return _build(scheme, AppColors.background);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFF6E5B),
      onPrimary: Color(0xFF690000),
      primaryContainer: Color(0xFF930000),
      onPrimaryContainer: Color(0xFFFFDAD4),
      secondary: AppColors.secondary,
      onSecondary: Color(0xFF3E2E00),
      secondaryContainer: Color(0xFF5C4300),
      onSecondaryContainer: Color(0xFFFFECB3),
      tertiary: Color(0xFF7DDC80),
      onTertiary: Color(0xFF003912),
      tertiaryContainer: Color(0xFF00531C),
      onTertiaryContainer: Color(0xFFB8F5B9),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerLowest: Color(0xFF100D0A),
      surfaceContainerLow: AppColors.darkSurface,
      surfaceContainer: AppColors.darkCard,
      surfaceContainerHigh: Color(0xFF362E24),
      surfaceContainerHighest: Color(0xFF41382C),
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkBorder,
      outlineVariant: Color(0xFF332B22),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFF5EFE6),
      onInverseSurface: Color(0xFF352F27),
      inversePrimary: AppColors.primary,
    );

    return _build(scheme, AppColors.darkBackground);
  }

  static ThemeData _build(ColorScheme scheme, Color background) {
    final text = AppTypography.textTheme(
      scheme.onSurface,
      scheme.onSurfaceVariant,
    );
    final isLight = scheme.brightness == Brightness.light;
    final cardColor = isLight ? AppColors.card : AppColors.darkCard;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,

      // Shadows are drawn by our own tokens on custom surfaces, so Material's
      // built-in elevation shadows are suppressed everywhere.
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          textStyle: text.labelLarge?.copyWith(color: Colors.white),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          side: BorderSide(color: scheme.outline, width: 1.5),
          foregroundColor: scheme.onSurface,
          textStyle: text.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brSm),
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge?.copyWith(color: scheme.primary),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        hintStyle: text.bodyMedium,
        labelStyle: text.labelMedium,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: scheme.primary,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brPill),
        labelStyle: text.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        showCheckmark: false,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXxl),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        showDragHandle: true,
        dragHandleColor: scheme.outline,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(borderRadius: AppRadius.brPill),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? text.labelSmall?.copyWith(color: scheme.primary)
              : text.labelSmall,
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        selectedIconTheme: IconThemeData(color: scheme.primary, size: 24),
        unselectedIconTheme: IconThemeData(
          color: scheme.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle:
            text.labelMedium?.copyWith(color: scheme.primary),
        unselectedLabelTextStyle: text.labelMedium,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brSm),
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: AppRadius.brSm,
        ),
        textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: Colors.transparent,
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
      ),
    );
  }
}
