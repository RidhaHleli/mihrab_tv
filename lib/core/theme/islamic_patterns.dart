import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Regular star polygon (e.g. 8 points = Khatam, 6 points = Star of Solomon).
Path starPath(
  Offset center,
  double radius, {
  int points = 8,
  double innerRatio = 0.765,
}) {
  final path = Path();

  for (var i = 0; i < points * 2; i++) {
    final r = i.isEven ? radius : radius * innerRatio;
    final angle = -math.pi / 2 + i * math.pi / points;
    final x = center.dx + r * math.cos(angle);
    final y = center.dy + r * math.sin(angle);

    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }

  return path..close();
}

/// Tiling of interlocking stars, the classic geometric Islamic pattern.
///
/// Square grid of 8-pointed stars, or a triangular lattice of 6-pointed stars
/// when [hexagonal] is true.
class IslamicPatternPainter extends CustomPainter {
  const IslamicPatternPainter({
    required this.color,
    this.hexagonal = false,
    this.cell = 90,
    this.strokeWidth = 1.2,
  });

  final Color color;
  final bool hexagonal;
  final double cell;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || cell <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (hexagonal) {
      _paintHexagonal(canvas, size, paint);
    } else {
      _paintSquare(canvas, size, paint);
    }
  }

  void _paintSquare(Canvas canvas, Size size, Paint paint) {
    final cols = (size.width / cell).ceil() + 1;
    final rows = (size.height / cell).ceil() + 1;

    for (var row = 0; row <= rows; row++) {
      for (var col = 0; col <= cols; col++) {
        final center = Offset(col * cell, row * cell);

        canvas.drawPath(starPath(center, cell * 0.5), paint);
        canvas.drawPath(
          starPath(
            center.translate(cell / 2, cell / 2),
            cell * 0.2,
            points: 4,
            innerRatio: 1,
          ),
          paint,
        );
      }
    }
  }

  void _paintHexagonal(Canvas canvas, Size size, Paint paint) {
    final rowHeight = cell * math.sqrt(3) / 2;
    final cols = (size.width / cell).ceil() + 1;
    final rows = (size.height / rowHeight).ceil() + 1;

    for (var row = 0; row <= rows; row++) {
      final offset = row.isOdd ? cell / 2 : 0.0;

      for (var col = 0; col <= cols; col++) {
        final center = Offset(col * cell + offset, row * rowHeight);

        canvas.drawPath(
          starPath(center, cell * 0.5, points: 6, innerRatio: 0.577),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(IslamicPatternPainter old) {
    return old.color != color ||
        old.hexagonal != hexagonal ||
        old.cell != cell ||
        old.strokeWidth != strokeWidth;
  }
}

/// Small eight-pointed star used as a bullet / logo mark.
class StarOrnament extends StatelessWidget {
  const StarOrnament({
    super.key,
    required this.color,
    this.size = 16,
    this.filled = false,
  });

  final Color color;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StarOrnamentPainter(color: color, filled: filled),
    );
  }
}

class _StarOrnamentPainter extends CustomPainter {
  const _StarOrnamentPainter({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final outer = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, size.shortestSide / 14)
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(starPath(center, radius * 0.96), outer);

    if (!filled) {
      canvas.drawCircle(center, radius * 0.22, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_StarOrnamentPainter old) {
    return old.color != color || old.filled != filled;
  }
}

/// Thin line, star, thin line: a classic section separator.
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key, required this.color, this.starSize = 14});

  final Color color;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    Widget line(bool towardsStar) {
      return Expanded(
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: towardsStar
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              end: towardsStar
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              colors: [color.withValues(alpha: 0), color],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        line(true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: StarOrnament(color: color, size: starSize, filled: true),
        ),
        line(false),
      ],
    );
  }
}
