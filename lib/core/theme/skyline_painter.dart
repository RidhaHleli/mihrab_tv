import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'mihrab_palette.dart';

/// Night scene behind the UI: sky, glow, stars and the silhouette of the
/// landmark of the selected theme (drawn in code, no image assets).
class SkylinePainter extends CustomPainter {
  const SkylinePainter(this.palette, {this.intensity = 1});

  final MihrabPalette palette;

  /// 1 = full scene, lower values calm it down (e.g. behind forms).
  final double intensity;

  // The monument is designed on a 1000 x 500 canvas, baseline at y = 500.
  static const double _designWidth = 1000;
  static const double _designHeight = 500;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Offset.zero & size;

    _paintSky(canvas, rect);
    _paintStars(canvas, size);
    _paintMoon(canvas, size);

    final skylineHeight = math.min(size.height * 0.5, size.width * 0.52);
    final scale = skylineHeight / _designHeight;
    final extra = math.max(0.0, (size.width / scale - _designWidth) / 2);

    canvas.save();
    canvas.translate(
      size.width / 2 - _designWidth / 2 * scale,
      size.height - skylineHeight,
    );
    canvas.scale(scale);

    switch (palette.skyline) {
      case SkylineStyle.kairouan:
        _paintKairouan(canvas, extra);
      case SkylineStyle.makkah:
        _paintMakkah(canvas, extra);
      case SkylineStyle.quds:
        _paintQuds(canvas, extra);
    }

    canvas.restore();
  }

  // ---------------------------------------------------------------------
  // Sky
  // ---------------------------------------------------------------------

  void _paintSky(Canvas canvas, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.skyTop, palette.skyBottom],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.65),
          radius: 0.85,
          colors: [
            palette.glow.withValues(alpha: 0.30 * intensity),
            palette.glow.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  void _paintStars(Canvas canvas, Size size) {
    final count = switch (palette.skyline) {
      SkylineStyle.kairouan => 14,
      SkylineStyle.makkah => 42,
      SkylineStyle.quds => 30,
    };

    final random = math.Random(palette.skyline.index + 11);
    final paint = Paint();

    for (var i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height * 0.55;
      final radius = 0.6 + random.nextDouble() * 1.3;
      final alpha = (0.25 + random.nextDouble() * 0.5) * intensity;

      paint.color = palette.textPrimary.withValues(alpha: alpha);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  void _paintMoon(Canvas canvas, Size size) {
    if (palette.skyline == SkylineStyle.kairouan) return;

    final radius = math.min(size.width, size.height) * 0.05;
    final center = Offset(size.width * 0.14, size.height * 0.16);

    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      Path()
        ..addOval(
          Rect.fromCircle(
            center: center.translate(radius * 0.45, -radius * 0.2),
            radius: radius * 0.9,
          ),
        ),
    );

    canvas.drawPath(
      moon,
      Paint()..color = palette.accentLight.withValues(alpha: 0.8 * intensity),
    );
  }

  // ---------------------------------------------------------------------
  // Drawing helpers (design space)
  // ---------------------------------------------------------------------

  Paint get _silhouette =>
      Paint()..color = palette.skylineColor.withValues(alpha: 0.2 * intensity);

  Paint get _cutout => Paint()..blendMode = BlendMode.clear;

  Paint _accent(double alpha) =>
      Paint()..color = palette.accent.withValues(alpha: alpha * intensity);

  Paint _accentStroke(double alpha, [double width = 2]) => Paint()
    ..color = palette.accent.withValues(alpha: alpha * intensity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = width;

  Rect _bounds(double extra) =>
      Rect.fromLTRB(-extra - 30, -40, _designWidth + extra + 30, 540);

  void _rect(Canvas c, Paint p, double l, double t, double r, double b) =>
      c.drawRect(Rect.fromLTRB(l, t, r, b), p);

  /// Semi-ellipse resting on [baseY].
  Path _domePath(double cx, double baseY, double rx, double ry) {
    return Path()
      ..moveTo(cx - rx, baseY)
      ..arcToPoint(
        Offset(cx + rx, baseY),
        radius: Radius.elliptical(rx, ry),
        clockwise: true,
      )
      ..close();
  }

  /// Arch opening: rectangle topped by a half circle.
  void _arch(Canvas c, Paint p, double cx, double baseY, double w, double h) {
    final r = w / 2;
    final top = baseY - h + r;

    c.drawPath(
      Path()
        ..moveTo(cx - r, baseY)
        ..lineTo(cx - r, top)
        ..arcToPoint(
          Offset(cx + r, top),
          radius: Radius.circular(r),
          clockwise: true,
        )
        ..lineTo(cx + r, baseY)
        ..close(),
      p,
    );
  }

  void _merlons(
    Canvas c,
    Paint p,
    double from,
    double to,
    double y, {
    double width = 18,
    double height = 14,
    double step = 36,
  }) {
    for (var x = from; x < to; x += step) {
      c.drawRect(Rect.fromLTWH(x, y - height, width, height), p);
    }
  }

  void _triangle(Canvas c, Paint p, Offset a, Offset b, Offset d) {
    c.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(d.dx, d.dy)
        ..close(),
      p,
    );
  }

  void _crescent(Canvas c, Paint p, Offset center, double r) {
    c.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: center, radius: r)),
        Path()
          ..addOval(
            Rect.fromCircle(
              center: center.translate(r * 0.45, -r * 0.1),
              radius: r * 0.82,
            ),
          ),
      ),
      p,
    );
  }

  // ---------------------------------------------------------------------
  // Great Mosque of Kairouan: square tiered minaret, ribbed domes,
  // crenellated walls and horseshoe arcades.
  // ---------------------------------------------------------------------

  void _paintKairouan(Canvas canvas, double extra) {
    canvas.saveLayer(_bounds(extra), Paint());

    final f = _silhouette;
    final cut = _cutout;

    // Enclosure wall
    _rect(canvas, f, -extra - 20, 440, _designWidth + extra + 20, 500);
    _merlons(canvas, f, -extra - 20, _designWidth + extra + 20, 440);

    // Prayer hall
    _rect(canvas, f, 60, 372, 560, 440);
    _merlons(canvas, f, 64, 556, 372, width: 14, height: 10, step: 30);

    // Large ribbed dome
    _rect(canvas, f, 232, 350, 368, 372);
    canvas.drawPath(_domePath(300, 350, 70, 58), f);
    _rect(canvas, f, 298, 284, 302, 296);
    canvas.drawCircle(const Offset(300, 280), 5, f);

    // Small domes
    for (final cx in [150.0, 450.0]) {
      _rect(canvas, f, cx - 22, 356, cx + 22, 372);
      canvas.drawPath(_domePath(cx, 356, 26, 22), f);
      _rect(canvas, f, cx - 1.5, 328, cx + 1.5, 338);
    }

    // Minaret: three tapering tiers
    _rect(canvas, f, 612, 262, 728, 440);
    _merlons(canvas, f, 614, 726, 262, width: 12, height: 10, step: 20);
    _rect(canvas, f, 634, 182, 706, 262);
    _merlons(canvas, f, 636, 704, 182, width: 10, height: 8, step: 16);
    _rect(canvas, f, 652, 140, 688, 182);
    canvas.drawPath(_domePath(670, 140, 22, 20), f);
    _rect(canvas, f, 668.5, 100, 671.5, 122);
    canvas.drawCircle(const Offset(670, 98), 5, f);

    // Openings
    for (var cx = 90.0; cx < 550; cx += 40) {
      _arch(canvas, cut, cx, 440, 22, 40);
    }
    _arch(canvas, cut, 670, 380, 26, 56);
    _arch(canvas, cut, 640, 330, 14, 30);
    _arch(canvas, cut, 700, 330, 14, 30);
    _arch(canvas, cut, 670, 246, 16, 36);
    _arch(canvas, cut, 670, 176, 10, 22);

    // East arcade
    _rect(canvas, f, 740, 400, 1000 + extra, 440);
    for (var cx = 770.0; cx < 1000 + extra; cx += 44) {
      _arch(canvas, cut, cx, 440, 26, 40);
    }
    for (var cx = 770.0; cx > -extra; cx -= 44) {
      if (cx < 560) _arch(canvas, cut, cx, 500, 22, 36);
    }

    canvas.restore();

    // Gold details: dome ribs and minaret bands
    final ribs = _accentStroke(0.28);
    for (var i = -3; i <= 3; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(300 + i * 17.5, 350)
          ..quadraticBezierTo(300 + i * 11, 316, 300, 292),
        ribs,
      );
    }
    final bands = _accent(0.32);
    _rect(canvas, bands, 612, 262, 728, 270);
    _rect(canvas, bands, 634, 182, 706, 188);
    _rect(canvas, bands, 652, 140, 688, 144);
  }

  // ---------------------------------------------------------------------
  // Masjid al-Haram: the Kaaba, slender minarets and the clock tower.
  // ---------------------------------------------------------------------

  void _paintMakkah(Canvas canvas, double extra) {
    canvas.saveLayer(_bounds(extra), Paint());

    final f = _silhouette;
    final cut = _cutout;

    // Ground arcade
    _rect(canvas, f, -extra - 20, 455, _designWidth + extra + 20, 500);
    for (var cx = -extra; cx < _designWidth + extra; cx += 36) {
      _arch(canvas, cut, cx, 500, 20, 30);
    }

    // Colonnade
    _rect(canvas, f, 70, 420, 420, 455);
    _rect(canvas, f, 560, 420, 700, 455);
    for (var cx = 90.0; cx < 420; cx += 30) {
      _arch(canvas, cut, cx, 455, 16, 26);
    }
    for (var cx = 580.0; cx < 700; cx += 30) {
      _arch(canvas, cut, cx, 455, 16, 26);
    }

    // The Kaaba
    canvas.drawPath(
      Path()
        ..moveTo(420, 500)
        ..lineTo(420, 372)
        ..lineTo(462, 360)
        ..lineTo(552, 374)
        ..lineTo(552, 500)
        ..close(),
      f,
    );

    // Minarets
    void minaret(double cx, double top) {
      _rect(canvas, f, cx - 7, top + 34, cx + 7, 455);
      _rect(canvas, f, cx - 12, top + 62, cx + 12, top + 70);
      _rect(canvas, f, cx - 10, top + 112, cx + 10, top + 118);
      _triangle(
        canvas,
        f,
        Offset(cx - 9, top + 34),
        Offset(cx, top),
        Offset(cx + 9, top + 34),
      );
      canvas.drawCircle(Offset(cx, top - 6), 4, f);
    }

    for (final m in const [
      [110.0, 170.0],
      [190.0, 205.0],
      [330.0, 255.0],
      [640.0, 250.0],
      [930.0, 215.0],
    ]) {
      minaret(m[0], m[1]);
    }

    // Clock tower
    _rect(canvas, f, 690, 300, 722, 455);
    _rect(canvas, f, 798, 300, 830, 455);
    _rect(canvas, f, 722, 250, 798, 455);
    _rect(canvas, f, 738, 150, 782, 250);
    _rect(canvas, f, 722, 170, 798, 250);
    _rect(canvas, f, 742, 120, 778, 170);
    _triangle(
      canvas,
      f,
      const Offset(746, 120),
      const Offset(760, 44),
      const Offset(774, 120),
    );
    canvas.drawCircle(const Offset(760, 210), 28, cut);

    canvas.restore();

    // Gold details: kiswa belt, door, clock ring and crescent
    _rect(canvas, _accent(0.4), 420, 396, 552, 408);
    _rect(canvas, _accent(0.3), 450, 436, 484, 500);
    canvas.drawCircle(const Offset(760, 210), 28, _accentStroke(0.45, 3));
    canvas.drawCircle(const Offset(760, 210), 20, _accentStroke(0.25, 2));
    _crescent(canvas, _accent(0.6), const Offset(760, 34), 9);
  }

  // ---------------------------------------------------------------------
  // Al-Quds: Dome of the Rock, Al-Aqsa, the old city wall and cypresses.
  // ---------------------------------------------------------------------

  void _paintQuds(Canvas canvas, double extra) {
    canvas.saveLayer(_bounds(extra), Paint());

    final f = _silhouette;
    final cut = _cutout;

    // City wall
    _rect(canvas, f, -extra - 20, 455, _designWidth + extra + 20, 500);
    _merlons(canvas, f, -extra - 20, _designWidth + extra + 20, 455);
    for (var cx = -extra; cx < _designWidth + extra; cx += 40) {
      _arch(canvas, cut, cx, 500, 20, 34);
    }

    // Dome of the Rock: platform, octagonal body, drum
    _rect(canvas, f, 330, 430, 670, 455);
    _rect(canvas, f, 380, 345, 620, 430);
    _rect(canvas, f, 425, 300, 575, 345);
    canvas.drawPath(_domePath(500, 300, 82, 92), f);
    _rect(canvas, f, 498.5, 196, 501.5, 212);
    canvas.drawCircle(const Offset(500, 190), 6, f);

    for (var cx = 410.0; cx <= 590; cx += 30) {
      _arch(canvas, cut, cx, 430, 16, 50);
    }
    for (final cx in [450.0, 475.0, 500.0, 525.0, 550.0]) {
      _rect(canvas, cut, cx - 5, 312, cx + 5, 336);
    }

    // Dome of the Chain
    _rect(canvas, f, 250, 410, 310, 455);
    _rect(canvas, f, 266, 396, 294, 410);
    canvas.drawPath(_domePath(280, 396, 22, 20), f);
    for (var cx = 262.0; cx <= 298; cx += 18) {
      _arch(canvas, cut, cx, 455, 10, 30);
    }

    // Al-Aqsa and its minaret
    _rect(canvas, f, 690, 400, 900, 455);
    canvas.drawPath(_domePath(780, 400, 44, 34), f);
    _rect(canvas, f, 925, 310, 945, 455);
    _rect(canvas, f, 920, 316, 950, 324);
    _triangle(
      canvas,
      f,
      const Offset(925, 310),
      const Offset(935, 276),
      const Offset(945, 310),
    );
    for (var cx = 712.0; cx < 890; cx += 30) {
      _arch(canvas, cut, cx, 455, 14, 28);
    }

    // Cypress trees
    for (final tree in const [
      [205.0, 46.0],
      [232.0, 38.0],
      [352.0, 30.0],
      [650.0, 34.0],
      [962.0, 40.0],
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(tree[0], 455 - tree[1]),
          width: 20,
          height: tree[1] * 2,
        ),
        f,
      );
    }

    canvas.restore();

    // The golden dome and the blue tile band
    canvas.drawPath(_domePath(500, 300, 82, 92), _accent(0.55));
    _rect(canvas, _accent(0.55), 498.5, 196, 501.5, 212);
    canvas.drawCircle(const Offset(500, 190), 6, _accent(0.6));
    _rect(
      canvas,
      Paint()
        ..color = palette.accentSurfaceLight.withValues(alpha: 0.5 * intensity),
      380,
      345,
      620,
      360,
    );
  }

  @override
  bool shouldRepaint(SkylinePainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.intensity != intensity;
  }
}
