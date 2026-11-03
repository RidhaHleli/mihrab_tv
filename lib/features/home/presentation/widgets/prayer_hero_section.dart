import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/mihrab_palette.dart';

class PrayerHeroSection extends StatelessWidget {
  const PrayerHeroSection({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.remainingTime,
    required this.currentTime,
    required this.date,
  });

  final String prayerName;
  final String prayerTime;
  final String remainingTime;
  final String currentTime;
  final String date;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: r.s(36).clamp(16, 60).toDouble(),
        vertical: r.s(30).clamp(16, 52).toDouble(),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(p.heroRadius),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: p.heroGradient,
        ),
        border: Border.all(color: p.accent.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Icon(
              Icons.mosque_outlined,
              size: r.s(150).clamp(80, 220).toDouble(),
              color: p.accent.withValues(alpha: 0.07),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final content = _buildContent(context, r);

              // When the parent gives a fixed height (TV / landscape) the
              // content shrinks to fit instead of overflowing.
              if (!constraints.hasBoundedHeight) return content;

              return FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(width: constraints.maxWidth, child: content),
              );
            },
          ),
        ],
      ),
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
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: p.accent,
                  size: r.font(20, min: 18),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'الصلاة القادمة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.body.copyWith(
                      color: p.accentLight,
                      fontSize: r.font(19, min: 15),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              date,
              style: t.label.copyWith(
                color: p.textSecondary,
                fontSize: small,
              ),
            ),
          ],
        ),
        SizedBox(height: r.s(24).clamp(12, 40).toDouble()),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            prayerName,
            textAlign: TextAlign.center,
            style: t.display.copyWith(
              fontSize: r.font(48, min: 30),
              color: p.accentLight,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            prayerTime,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: t.clock.copyWith(
              fontSize: r.font(76, min: 44),
            ),
          ),
        ),
        SizedBox(height: r.s(24).clamp(12, 40).toDouble()),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.s(22).clamp(12, 36).toDouble(),
            vertical: r.s(14).clamp(8, 24).toDouble(),
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'الوقت المتبقي',
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
                    color: p.accentLight,
                    fontSize: r.font(34, min: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: r.s(16).clamp(8, 28).toDouble()),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'الوقت الآن  '),
              // Keep digits left-to-right inside the RTL sentence.
              TextSpan(text: '\u202A$currentTime\u202C'),
            ],
          ),
          textAlign: TextAlign.center,
          style: t.label.copyWith(fontSize: small),
        ),
      ],
    );
  }
}
