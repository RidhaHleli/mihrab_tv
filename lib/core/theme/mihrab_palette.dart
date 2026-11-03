import 'package:flutter/material.dart';

import 'mihrab_theme.dart';

/// The three selectable looks of the app.
enum AppThemeId {
  kairouan,
  makkah,
  quds;

  static AppThemeId fromName(String? name) {
    return AppThemeId.values.firstWhere(
      (id) => id.name == name,
      orElse: () => AppThemeId.kairouan,
    );
  }

  MihrabPalette get palette {
    switch (this) {
      case AppThemeId.kairouan:
        return MihrabPalette.kairouan;
      case AppThemeId.makkah:
        return MihrabPalette.makkah;
      case AppThemeId.quds:
        return MihrabPalette.quds;
    }
  }
}

/// Which landmark is drawn behind the content.
enum SkylineStyle { kairouan, makkah, quds }

/// Every colour and shape token of a theme. Read it with `context.palette`.
@immutable
class MihrabPalette extends ThemeExtension<MihrabPalette> {
  const MihrabPalette({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.skyline,
    required this.skyTop,
    required this.skyBottom,
    required this.glow,
    required this.skylineColor,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHighlight,
    required this.accent,
    required this.accentLight,
    required this.accentSurface,
    required this.accentSurfaceLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.success,
    required this.error,
    required this.heroGradient,
    required this.cardAlpha,
    required this.cardRadius,
    required this.heroRadius,
    required this.cardAccentBorder,
  });

  final AppThemeId id;
  final String label;
  final String subtitle;
  final SkylineStyle skyline;

  // Background scene
  final Color skyTop;
  final Color skyBottom;
  final Color glow;
  final Color skylineColor;

  // Surfaces
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceHighlight;

  // Accent
  final Color accent;
  final Color accentLight;
  final Color accentSurface;
  final Color accentSurfaceLight;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Lines & semantic
  final Color border;
  final Color success;
  final Color error;

  // Shape / style
  final List<Color> heroGradient;
  final double cardAlpha;
  final double cardRadius;
  final double heroRadius;

  /// 0..1: how much of the accent colour tints the border of idle cards.
  final double cardAccentBorder;

  /// Surface colour for cards drawn above the background scene.
  Color get card => surface.withValues(alpha: cardAlpha);

  Color get cardBorder =>
      Color.lerp(border, accent, cardAccentBorder) ?? border;

  // ---------------------------------------------------------------------
  // Presets
  // ---------------------------------------------------------------------

  /// Great Mosque of Kairouan (Sidi Oqba): sandstone, amber and dusk.
  static const kairouan = MihrabPalette(
    id: AppThemeId.kairouan,
    label: 'جامع عقبة بن نافع',
    subtitle: 'القيروان',
    skyline: SkylineStyle.kairouan,
    skyTop: Color(0xFF1A120B),
    skyBottom: Color(0xFF3B2814),
    glow: Color(0xFFE3A857),
    skylineColor: Color(0xFFEBC890),
    background: Color(0xFF1A120B),
    surface: Color(0xFF2A1F14),
    surfaceElevated: Color(0xFF38291A),
    surfaceHighlight: Color(0xFF4A3622),
    accent: Color(0xFFE3A857),
    accentLight: Color(0xFFF3D29C),
    accentSurface: Color(0xFF5A3D1F),
    accentSurfaceLight: Color(0xFF8A5E2E),
    textPrimary: Color(0xFFF8EFDF),
    textSecondary: Color(0xFFD2C0A4),
    textMuted: Color(0xFFA08E74),
    border: Color(0xFF4D3C29),
    success: Color(0xFF9CC48B),
    error: Color(0xFFE58A7B),
    heroGradient: [Color(0xFF6E4A26), Color(0xFF4B321A), Color(0xFF2E1E10)],
    cardAlpha: 0.66,
    cardRadius: 20,
    heroRadius: 28,
    cardAccentBorder: 0,
  );

  /// Masjid al-Haram: black kiswa, gold embroidery.
  static const makkah = MihrabPalette(
    id: AppThemeId.makkah,
    label: 'المسجد الحرام',
    subtitle: 'مكة المكرمة',
    skyline: SkylineStyle.makkah,
    skyTop: Color(0xFF020202),
    skyBottom: Color(0xFF14110A),
    glow: Color(0xFFD4AF37),
    skylineColor: Color(0xFFE6D08A),
    background: Color(0xFF050505),
    surface: Color(0xFF111111),
    surfaceElevated: Color(0xFF1B1912),
    surfaceHighlight: Color(0xFF2A261A),
    accent: Color(0xFFD4AF37),
    accentLight: Color(0xFFF0D77A),
    accentSurface: Color(0xFF2E2711),
    accentSurfaceLight: Color(0xFF6B5819),
    textPrimary: Color(0xFFFAF6EA),
    textSecondary: Color(0xFFCBC4B0),
    textMuted: Color(0xFF928B7A),
    border: Color(0xFF3A3220),
    success: Color(0xFF8FCB9B),
    error: Color(0xFFE5877A),
    heroGradient: [Color(0xFF2F2711), Color(0xFF15120A), Color(0xFF060504)],
    cardAlpha: 0.78,
    cardRadius: 8,
    heroRadius: 14,
    cardAccentBorder: 0.55,
  );

  /// Al-Quds: Dome of the Rock, golden dome over Jerusalem-blue tiles.
  static const quds = MihrabPalette(
    id: AppThemeId.quds,
    label: 'قبة الصخرة',
    subtitle: 'القدس الشريف',
    skyline: SkylineStyle.quds,
    skyTop: Color(0xFF071830),
    skyBottom: Color(0xFF0E3556),
    glow: Color(0xFFF2C14E),
    skylineColor: Color(0xFF9CC7E6),
    background: Color(0xFF06121F),
    surface: Color(0xFF0D2236),
    surfaceElevated: Color(0xFF14314D),
    surfaceHighlight: Color(0xFF1C4262),
    accent: Color(0xFFF2C14E),
    accentLight: Color(0xFFFFE3A0),
    accentSurface: Color(0xFF12507A),
    accentSurfaceLight: Color(0xFF1F7A8C),
    textPrimary: Color(0xFFF2F7FA),
    textSecondary: Color(0xFFB7CBD9),
    textMuted: Color(0xFF8099AB),
    border: Color(0xFF21435D),
    success: Color(0xFF7FD1AE),
    error: Color(0xFFF08A80),
    heroGradient: [Color(0xFF1D6A9A), Color(0xFF104569), Color(0xFF082A44)],
    cardAlpha: 0.56,
    cardRadius: 28,
    heroRadius: 36,
    cardAccentBorder: 0.15,
  );

  @override
  MihrabPalette copyWith() => this;

  @override
  MihrabPalette lerp(ThemeExtension<MihrabPalette>? other, double t) {
    if (other is! MihrabPalette) return this;

    Color c(Color a, Color b) => Color.lerp(a, b, t) ?? b;
    double d(double a, double b) => a + (b - a) * t;
    final first = t < 0.5;

    return MihrabPalette(
      id: first ? id : other.id,
      label: first ? label : other.label,
      subtitle: first ? subtitle : other.subtitle,
      skyline: first ? skyline : other.skyline,
      skyTop: c(skyTop, other.skyTop),
      skyBottom: c(skyBottom, other.skyBottom),
      glow: c(glow, other.glow),
      skylineColor: c(skylineColor, other.skylineColor),
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceElevated: c(surfaceElevated, other.surfaceElevated),
      surfaceHighlight: c(surfaceHighlight, other.surfaceHighlight),
      accent: c(accent, other.accent),
      accentLight: c(accentLight, other.accentLight),
      accentSurface: c(accentSurface, other.accentSurface),
      accentSurfaceLight: c(accentSurfaceLight, other.accentSurfaceLight),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      border: c(border, other.border),
      success: c(success, other.success),
      error: c(error, other.error),
      heroGradient: [
        for (var i = 0; i < heroGradient.length; i++)
          c(heroGradient[i], other.heroGradient[i]),
      ],
      cardAlpha: d(cardAlpha, other.cardAlpha),
      cardRadius: d(cardRadius, other.cardRadius),
      heroRadius: d(heroRadius, other.heroRadius),
      cardAccentBorder: d(cardAccentBorder, other.cardAccentBorder),
    );
  }
}

/// Text styles that follow the active palette.
class MihrabText {
  const MihrabText(this.palette);

  final MihrabPalette palette;

  TextStyle get display =>
      MihrabTypography.display.copyWith(color: palette.textPrimary);
  TextStyle get clock =>
      MihrabTypography.clock.copyWith(color: palette.textPrimary);
  TextStyle get heading =>
      MihrabTypography.heading.copyWith(color: palette.textPrimary);
  TextStyle get title =>
      MihrabTypography.title.copyWith(color: palette.textPrimary);
  TextStyle get body =>
      MihrabTypography.body.copyWith(color: palette.textSecondary);
  TextStyle get label =>
      MihrabTypography.label.copyWith(color: palette.textMuted);
}

extension MihrabThemeContext on BuildContext {
  MihrabPalette get palette =>
      Theme.of(this).extension<MihrabPalette>() ?? MihrabPalette.kairouan;

  MihrabText get text => MihrabText(palette);
}
