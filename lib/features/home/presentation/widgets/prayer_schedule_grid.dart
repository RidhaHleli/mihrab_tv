import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/islamic_patterns.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/theme/mihrab_theme.dart';
import '../../../../core/widgets/glass_surface.dart';

class PrayerScheduleItem {
  const PrayerScheduleItem({
    required this.name,
    required this.time,
    required this.icon,
    this.isNext = false,
    this.isPassed = false,
  });

  final String name;
  final String time;
  final IconData icon;
  final bool isNext;
  final bool isPassed;
}

/// Six prayer cards laid out in 3 or 2 columns depending on the width.
///
/// With [fillHeight] (TV / landscape) the cards share the available height;
/// otherwise each row has a height derived from the screen scale.
class PrayerScheduleGrid extends StatelessWidget {
  const PrayerScheduleGrid({
    super.key,
    required this.prayers,
    this.fillHeight = false,
  });

  final List<PrayerScheduleItem> prayers;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 3 : 2;
        final gap = r.gap;

        final rows = <Widget>[];

        for (var i = 0; i < prayers.length; i += columns) {
          final cells = <Widget>[];

          for (var j = 0; j < columns; j++) {
            if (j > 0) cells.add(SizedBox(width: gap));

            final index = i + j;
            cells.add(
              Expanded(
                child: index < prayers.length
                    ? _PrayerCard(prayer: prayers[index], r: r)
                    : const SizedBox.shrink(),
              ),
            );
          }

          final row = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          );

          if (rows.isNotEmpty) rows.add(SizedBox(height: gap));

          rows.add(
            fillHeight
                ? Expanded(child: row)
                : SizedBox(height: r.s(104).clamp(88, 150).toDouble(), child: row),
          );
        }

        return Column(
          mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(r: r),
            SizedBox(height: r.s(20).clamp(12, 28).toDouble()),
            if (fillHeight)
              Expanded(child: Column(children: rows))
            else
              Column(mainAxisSize: MainAxisSize.min, children: rows),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.r});

  final Responsive r;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;

    return Row(
      children: [
        StarOrnament(color: p.accent, size: r.font(24, min: 20)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            context.tr('prayer_times'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.heading.copyWith(
              fontSize: r.font(25, min: 19),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Spacer(),
        Text(
          context.tr('today'),
          style: t.label.copyWith(
            fontSize: r.font(16, min: 13),
          ),
        ),
      ],
    );
  }
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({required this.prayer, required this.r});

  final PrayerScheduleItem prayer;
  final Responsive r;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    final isNext = prayer.isNext;

    final textColor = isNext
        ? p.accentLight
        : prayer.isPassed
            ? p.textMuted
            : p.textPrimary;

    return Semantics(
      label: '${prayer.name} ${prayer.time}',
      child: GlassSurface(
        radius: p.cardRadius,
        color: isNext ? p.accentSurface.withValues(alpha: 0.82) : p.card,
        borderColor: isNext ? p.accent : p.cardBorder,
        borderWidth: isNext ? 2 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            prayer.icon,
                            color: isNext ? p.accent : p.textMuted,
                            size: r.font(21, min: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            prayer.name,
                            maxLines: 1,
                            style: t.body.copyWith(
                              fontFamily: MihrabTypography.calligraphyFamily,
                              color: textColor,
                              fontSize: r.font(22, min: 17),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prayer.time,
                        textDirection: TextDirection.ltr,
                        style: t.title.copyWith(
                          fontSize: r.font(26, min: 20),
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isNext)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: StarOrnament(
                  color: p.accent,
                  size: r.font(14, min: 12),
                  filled: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
