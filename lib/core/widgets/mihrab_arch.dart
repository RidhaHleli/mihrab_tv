import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pointed arch on top (like a mihrab niche) and rounded corners below.
Path mihrabArchPath(
  Size size, {
  required double archHeight,
  required double bottomRadius,
}) {
  final w = size.width;
  final h = size.height;
  final ah = archHeight.clamp(0.0, h * 0.5).toDouble();
  final r = bottomRadius.clamp(0.0, math.min(w, h) / 2).toDouble();

  return Path()
    ..moveTo(0, ah)
    ..cubicTo(0, ah * 0.30, w * 0.30, ah * 0.14, w / 2, 0)
    ..cubicTo(w * 0.70, ah * 0.14, w, ah * 0.30, w, ah)
    ..lineTo(w, h - r)
    ..quadraticBezierTo(w, h, w - r, h)
    ..lineTo(r, h)
    ..quadraticBezierTo(0, h, 0, h - r)
    ..close();
}

class MihrabArchClipper extends CustomClipper<Path> {
  const MihrabArchClipper({
    required this.archHeight,
    required this.bottomRadius,
  });

  final double archHeight;
  final double bottomRadius;

  @override
  Path getClip(Size size) => mihrabArchPath(
        size,
        archHeight: archHeight,
        bottomRadius: bottomRadius,
      );

  @override
  bool shouldReclip(MihrabArchClipper old) {
    return old.archHeight != archHeight || old.bottomRadius != bottomRadius;
  }
}

/// Double golden outline (outer line + fine inner line) with a soft glow.
class MihrabArchFramePainter extends CustomPainter {
  const MihrabArchFramePainter({
    required this.color,
    required this.archHeight,
    required this.bottomRadius,
  });

  final Color color;
  final double archHeight;
  final double bottomRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 40 || size.height < 40) return;

    final outer = mihrabArchPath(
      size,
      archHeight: archHeight,
      bottomRadius: bottomRadius,
    );

    canvas.drawPath(
      outer,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawPath(
      outer,
      Paint()
        ..color = color.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    const inset = 9.0;
    final inner = mihrabArchPath(
      Size(size.width - inset * 2, size.height - inset * 2),
      archHeight: archHeight * 0.92,
      bottomRadius: math.max(0, bottomRadius - inset),
    ).shift(const Offset(inset, inset));

    canvas.drawPath(
      inner,
      Paint()
        ..color = color.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(MihrabArchFramePainter old) {
    return old.color != color ||
        old.archHeight != archHeight ||
        old.bottomRadius != bottomRadius;
  }
}
