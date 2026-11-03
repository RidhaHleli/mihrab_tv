import 'package:flutter/material.dart';

import 'mihrab_palette.dart';
import 'skyline_painter.dart';

/// Draws the scene of the active theme behind [child].
///
/// Every page wraps its Scaffold (transparent) in this widget so that route
/// transitions never show two overlapping pages through each other.
class ThemedBackground extends StatelessWidget {
  const ThemedBackground({
    super.key,
    required this.child,
    this.intensity = 1,
  });

  final Widget child;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: SkylinePainter(palette, intensity: intensity),
            size: Size.infinite,
          ),
        ),
        child,
      ],
    );
  }
}

/// Small static preview of a theme (used by the theme picker).
class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key, required this.palette});

  final MihrabPalette palette;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: RepaintBoundary(
          child: CustomPaint(
            painter: SkylinePainter(palette),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
