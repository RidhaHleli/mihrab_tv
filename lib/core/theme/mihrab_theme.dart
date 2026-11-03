import 'package:flutter/material.dart';

import 'mihrab_palette.dart';

abstract final class MihrabSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double tvPadding = 64;
}

abstract final class MihrabRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
}

/// Sizes and weights only: colours come from [MihrabText] (palette aware).
abstract final class MihrabTypography {
  /// Interface font (clean, modern Arabic) and calligraphic font for titles.
  static const uiFamily = 'Tajawal';
  static const calligraphyFamily = 'Amiri';

  static const display = TextStyle(
    fontFamily: calligraphyFamily,
    fontSize: 64,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const clock = TextStyle(
    fontSize: 76,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
    height: 1.1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const heading = TextStyle(
    fontFamily: calligraphyFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const title = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const body = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const label = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}

abstract final class MihrabTheme {
  static ThemeData of(AppThemeId id) => build(id.palette);

  static ThemeData build(MihrabPalette p) {
    final text = MihrabText(p);

    final colors = ColorScheme.dark(
      primary: p.accent,
      onPrimary: p.background,
      secondary: p.accentSurfaceLight,
      onSecondary: p.textPrimary,
      surface: p.surface,
      onSurface: p.textPrimary,
      error: p.error,
      onError: p.background,
      outline: p.border,
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(MihrabRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      fontFamily: MihrabTypography.uiFamily,
      brightness: Brightness.dark,
      colorScheme: colors,
      extensions: [p],
      // Pages draw their own themed background scene.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: p.surfaceElevated,
      dividerColor: p.border,
      focusColor: p.accent.withValues(alpha: 0.22),
      splashColor: p.accent.withValues(alpha: 0.10),
      highlightColor: p.accent.withValues(alpha: 0.08),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: p.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.title,
      ),
      textTheme: TextTheme(
        displayLarge: text.display,
        displayMedium: text.heading,
        headlineMedium: text.heading,
        titleLarge: text.title,
        titleMedium: text.body.copyWith(color: p.textPrimary),
        bodyLarge: text.body,
        bodyMedium: text.label,
      ),
      iconTheme: IconThemeData(color: p.textSecondary, size: 24),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
        subtitleTextStyle: text.label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surfaceElevated,
        contentTextStyle: text.body.copyWith(color: p.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MihrabRadius.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        labelStyle: TextStyle(color: p.textSecondary, fontSize: 18),
        hintStyle: TextStyle(color: p.textMuted, fontSize: 17),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: inputBorder(p.border),
        enabledBorder: inputBorder(p.border),
        focusedBorder: inputBorder(p.accent, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(p.accent),
          foregroundColor: WidgetStatePropertyAll(p.background),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MihrabRadius.md),
            ),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.accent,
        inactiveTrackColor: p.border,
        thumbColor: p.accentLight,
        overlayColor: p.accent.withValues(alpha: 0.15),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? p.accent
              : p.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? p.accentSurfaceLight
              : p.surfaceHighlight;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
    );
  }
}
