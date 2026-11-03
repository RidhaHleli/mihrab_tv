import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/islamic_patterns.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/theme/mihrab_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../domain/home_logic.dart';

/// Wraps an overlay so that tap, OK/Enter, Select or any remote key closes it.
class _DismissOnInput extends StatelessWidget {
  const _DismissOnInput({required this.onDismiss, required this.child});

  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          onDismiss();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: child,
      ),
    );
  }
}

/// Full-screen iqama countdown, then the "silence your phones" message.
class IqamaOverlay extends StatelessWidget {
  const IqamaOverlay({
    super.key,
    required this.phase,
    required this.prayerName,
    required this.onDismiss,
  });

  final PrayerPhase phase;
  final String prayerName;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final t = context.text;
    final countdown = phase.kind == PrayerPhaseKind.iqamaCountdown;

    final headline = countdown
        ? context.tr(phase.isJumuah ? 'jumuah_in' : 'iqama_in')
        : context.tr('prayer_ongoing');

    final message = countdown
        ? context.tr('iqama_msg')
        : context.tr('prayer_ongoing_msg');

    return _DismissOnInput(
      onDismiss: onDismiss,
      child: Semantics(
        liveRegion: true,
        label: '$headline $prayerName',
        child: ColoredBox(
          color: p.background.withValues(alpha: 0.97),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: IslamicPatternPainter(
                    color: p.accentLight.withValues(alpha: 0.05),
                    cell: r.s(110).clamp(70, 140).toDouble(),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(r.pagePaddingH),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: math.max(r.size.width - 32, 240),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StarOrnament(
                              color: p.accent,
                              size: r.font(54, min: 36),
                            ),
                            SizedBox(height: r.s(18).clamp(10, 28).toDouble()),
                            Text(
                              prayerName,
                              textAlign: TextAlign.center,
                              style: t.display.copyWith(
                                fontSize: r.font(64, min: 36),
                                color: p.accentLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              headline,
                              textAlign: TextAlign.center,
                              style: t.heading.copyWith(
                                fontSize: r.font(30, min: 20),
                                color: p.textSecondary,
                              ),
                            ),
                            if (countdown) ...[
                              SizedBox(
                                height: r.s(18).clamp(10, 28).toDouble(),
                              ),
                              Text(
                                DateTimeUtils.countdownShort(
                                  phase.remaining ?? Duration.zero,
                                ),
                                textDirection: TextDirection.ltr,
                                style: t.clock.copyWith(
                                  fontSize: r.font(150, min: 70),
                                  color: p.accentLight,
                                ),
                              ),
                            ],
                            SizedBox(height: r.s(24).clamp(12, 36).toDouble()),
                            OrnamentDivider(
                              color: p.accent.withValues(alpha: 0.8),
                            ),
                            SizedBox(height: r.s(24).clamp(12, 36).toDouble()),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.phone_android_rounded,
                                  color: p.accent,
                                  size: r.font(34, min: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: t.title.copyWith(
                                    fontSize: r.font(30, min: 18),
                                    fontFamily: MihrabTypography.uiFamily,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: r.s(26).clamp(14, 40).toDouble()),
                            Text(
                              context.tr('tap_to_close'),
                              style: t.label.copyWith(
                                color: p.textMuted,
                                fontSize: r.font(14, min: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark, quiet screen shown between Isha and Fajr.
class NightOverlay extends StatelessWidget {
  const NightOverlay({
    super.key,
    required this.now,
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.onWake,
  });

  final DateTime now;
  final String nextPrayerName;
  final String nextPrayerTime;
  final VoidCallback onWake;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final t = context.text;

    // Move the clock a little every minute to avoid screen burn-in.
    final shiftX = ((now.minute % 9) - 4) / 4 * 0.35;
    final shiftY = ((now.minute % 7) - 3) / 3 * 0.25;

    final dim = p.accent.withValues(alpha: 0.55);

    return _DismissOnInput(
      onDismiss: onWake,
      child: Semantics(
        label: context.tr('night_hint'),
        child: ColoredBox(
          color: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment(shiftX, shiftY),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateTimeUtils.formatTime(now),
                        textDirection: TextDirection.ltr,
                        style: t.clock.copyWith(
                          fontSize: r.font(150, min: 72),
                          color: dim,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$nextPrayerName  ‪$nextPrayerTime‬',
                        style: t.title.copyWith(
                          fontSize: r.font(26, min: 16),
                          color: dim.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      context.tr('night_hint'),
                      style: t.label.copyWith(
                        fontSize: r.font(13, min: 11),
                        color: p.textMuted.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
