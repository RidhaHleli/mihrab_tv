import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/mihrab_palette.dart';

/// Frosted-glass panel: blurred background, soft top highlight, fine border.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.blur = 14,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double? radius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double blur;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final borderRadius = BorderRadius.circular(radius ?? p.cardRadius);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? p.card,
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor ?? p.cardBorder,
              width: borderWidth,
            ),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.07),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
