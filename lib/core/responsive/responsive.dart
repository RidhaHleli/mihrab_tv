import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Adaptive sizing shared by every screen.
///
/// * **Wide** layouts (TV, tablets and phones in landscape) are designed on a
///   1080 px tall canvas and scale with the screen height, so the UI keeps the
///   same proportions on a 960x540 TV buffer and on a 1920x1080 one.
/// * **Stacked** layouts (portrait phones and tablets) scale with the width.
@immutable
class Responsive {
  const Responsive._({
    required this.size,
    required this.isWide,
    required this.scale,
  });

  factory Responsive.of(BuildContext context) =>
      Responsive.fromSize(MediaQuery.sizeOf(context));

  factory Responsive.fromSize(Size size) {
    final isWide = size.width >= 760 && size.width >= size.height * 1.2;
    final raw = isWide ? size.height / 1080 : size.width / 600;
    final scale = isWide
        ? raw.clamp(0.5, 1.6).toDouble()
        : raw.clamp(0.75, 1.3).toDouble();

    return Responsive._(size: size, isWide: isWide, scale: scale);
  }

  /// Minimum comfortable touch target (Material guideline).
  static const double minTapTarget = 48;

  final Size size;

  /// Side-by-side layout (hero + schedule) instead of a scrolling column.
  final bool isWide;

  final double scale;

  /// Scales a layout dimension.
  double s(double value) => value * scale;

  /// Scales a font size without ever going below [min] (readability).
  double font(double base, {double min = 12}) =>
      math.max(base * scale, min);

  /// Scales an interactive size but keeps it above [minTapTarget].
  double tap(double base) => math.max(base * scale, minTapTarget);

  double get pagePaddingH => isWide ? s(48) : math.max(s(20), 16);

  double get pagePaddingV => isWide ? s(28) : math.max(s(20), 16);

  double get gap => math.max(s(14), 8);
}
