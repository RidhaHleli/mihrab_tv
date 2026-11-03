import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/islamic_patterns.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/theme/mihrab_theme.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../core/widgets/mihrab_arch.dart';

class PrayerHeroSection extends StatelessWidget {
  const PrayerHeroSection({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.remainingTime,
    required this.currentTime,
    required this.date,
    this.hijriDate = '',
  });

  final String prayerName;
  final String prayerTime;
  final String remainingTime;
  final String currentTime;
  final String date;
  final String hijriDate;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : r.size.width;
        final archHeight =
            math.min(width * 0.2, r.s(120)).clamp(36.0, 120.0).toDouble();

        final horizontal = r.s(36).clamp(16, 60).toDouble();
        final vertical = r.s(30).clamp(16, 52).toDouble();

        return CustomPaint(
          foregroundPainter: MihrabArchFramePainter(
            color: p.accent,
            archHeight: archHeight,
            bottomRadius: p.heroRadius,
          ),
          child: ClipPath(
            clipper: MihrabArchClipper(
              archHeight: archHeight,
              bottomRadius: p.heroRadius,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                horizontal,
                vertical + archHeight * 0.4,
                horizontal,
                vertical,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: p.heroGradient,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: IslamicPatternPainter(
                        color: p.accentLight.withValues(alpha: 0.07),
                        hexagonal: p.skyline == SkylineStyle.quds,
                        cell: r.s(90).clamp(56, 110).toDouble(),
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, inner) {
                      final content = _buildContent(context, r);

                      // With a fixed height (TV / landscape) the content
                      // shrinks to fit instead of overflowing.
                      if (!inner.hasBoundedHeight) return content;

                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: inner.maxWidth,
                          child: content,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, Responsive r) {
    final p = context.palette;
    final t = context.text;
    final small = r.font(16, min: 13);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            context.tr('next_prayer'),
            style: t.body.copyWith(
              color: p.accentLight,
              fontSize: r.font(20, min: 15),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: r.s(10).clamp(6, 16).toDouble()),
        OrnamentDivider(color: p.accent.withValues(alpha: 0.8)),
        SizedBox(height: r.s(14).clamp(8, 22).toDouble()),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            prayerName,
            textAlign: TextAlign.center,
            style: t.display.copyWith(
              fontSize: r.font(56, min: 34),
              fontWeight: FontWeight.w700,
              color: p.accentLight,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            prayerTime,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: t.clock.copyWith(fontSize: r.font(80, min: 46)),
          ),
        ),
        SizedBox(height: r.s(22).clamp(12, 36).toDouble()),
        GlassSurface(
          radius: 18,
          color: Colors.black.withValues(alpha: 0.22),
          borderColor: p.accent.withValues(alpha: 0.25),
          padding: EdgeInsets.symmetric(
            horizontal: r.s(22).clamp(12, 36).toDouble(),
            vertical: r.s(14).clamp(8, 24).toDouble(),
          ),
          child: Column(
            children: [
              Text(
                context.tr('remaining'),
                style: t.label.copyWith(
                  color: p.textSecondary,
                  fontSize: small,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  remainingTime,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: t.heading.copyWith(
                    fontFamily: MihrabTypography.uiFamily,
                    color: p.accentLight,
                    fontSize: r.font(34, min: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: r.s(16).clamp(8, 28).toDouble()),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 4,
          children: [
            Text(
              date,
              style: t.label.copyWith(
                color: p.textSecondary,
                fontSize: small,
              ),
            ),
            if (hijriDate.isNotEmpty) ...[
              StarOrnament(color: p.accent, size: small * 0.8, filled: true),
              Text(
                hijriDate,
                style: t.label.copyWith(
                  color: p.accentLight,
                  fontSize: small,
                ),
              ),
            ],
            StarOrnament(color: p.accent, size: small * 0.8, filled: true),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${context.tr('now_label')}  '),
                  // Keep digits left-to-right inside the RTL sentence.
                  TextSpan(text: '\u202A$currentTime\u202C'),
                ],
              ),
              style: t.label.copyWith(fontSize: small),
            ),
          ],
        ),
      ],
    );
  }
}
