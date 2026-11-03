import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../core/widgets/marquee_text.dart';
import '../../domain/home_logic.dart';

/// Compact glass strip: icon + content.
class InfoStrip extends StatelessWidget {
  const InfoStrip({
    super.key,
    required this.icon,
    required this.child,
    this.highlight = false,
  });

  final IconData icon;
  final Widget child;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;

    return GlassSurface(
      radius: 14,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: r.s(10).clamp(8, 14).toDouble(),
      ),
      color: highlight ? p.accentSurface.withValues(alpha: 0.85) : p.card,
      borderColor: highlight ? p.accent : p.cardBorder,
      child: Row(
        children: [
          Icon(icon, color: p.accent, size: r.font(20, min: 18)),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Imsak / iftar information during Ramadan.
class RamadanStrip extends StatelessWidget {
  const RamadanStrip({super.key, required this.info});

  final RamadanInfo info;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final t = context.text;
    final size = r.font(16, min: 13);

    final String headline;
    switch (info.stage) {
      case RamadanStage.untilImsak:
        headline = context.tr('imsak_in');
      case RamadanStage.fasting:
        headline = context.tr('iftar_in');
      case RamadanStage.taraweeh:
        headline = context.tr('taraweeh');
      case RamadanStage.afterIftar:
        headline = context.tr('ramadan_kareem');
    }

    final countdown = info.remaining == null
        ? null
        : DateTimeUtils.countdown(info.remaining);

    return InfoStrip(
      icon: Icons.dark_mode_rounded,
      highlight: info.stage == RamadanStage.fasting &&
          (info.remaining?.inMinutes ?? 99) < 15,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 4,
        children: [
          Text(
            context.tr('ramadan_kareem'),
            style: t.title.copyWith(fontSize: size + 2, color: p.accentLight),
          ),
          Text(
            '${context.tr('imsak')} ‪${DateTimeUtils.formatTime(info.imsak)}‬',
            style: t.label.copyWith(fontSize: size),
          ),
          Text(
            '${context.tr('iftar')} ‪${DateTimeUtils.formatTime(info.iftar)}‬',
            style: t.label.copyWith(fontSize: size),
          ),
          if (info.stage != RamadanStage.afterIftar)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$headline  '),
                  if (countdown != null)
                    TextSpan(
                      text: '‪$countdown‬',
                      style: t.title.copyWith(
                        fontSize: size + 2,
                        color: p.accentLight,
                      ),
                    ),
                ],
              ),
              style: t.label.copyWith(fontSize: size),
            ),
        ],
      ),
    );
  }
}

/// One line of text (Friday reminder, verse, hadith...).
class MessageStrip extends StatelessWidget {
  const MessageStrip({
    super.key,
    required this.icon,
    required this.text,
    this.label,
    this.source,
    this.highlight = false,
  });

  final IconData icon;
  final String text;
  final String? label;
  final String? source;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final t = context.text;
    final size = r.font(17, min: 14);
    final scaler = MediaQuery.textScalerOf(context);

    return InfoStrip(
      icon: icon,
      highlight: highlight,
      child: SizedBox(
        // Fixed height (label + two lines) so the layout does not jump
        // when the message rotates.
        height: scaler.scale(size - 3) * 1.4 + scaler.scale(size) * 1.35 * 2 + 4,
        child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Column(
          key: ValueKey('$label|$text'),
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (label != null)
              Text(
                source == null ? label! : '$label  ·  $source',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.label.copyWith(
                  fontSize: size - 3,
                  color: p.accent,
                ),
              ),
            Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.body.copyWith(
                fontSize: size,
                color: p.textPrimary,
                height: 1.35,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

/// Scrolling announcements set by the mosque.
class AnnouncementsStrip extends StatelessWidget {
  const AnnouncementsStrip({super.key, required this.announcements});

  final List<String> announcements;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final t = context.text;

    return InfoStrip(
      icon: Icons.campaign_rounded,
      child: MarqueeText(
        text: announcements.join('   ✦   '),
        style: t.title.copyWith(
          fontSize: r.font(19, min: 15),
          color: p.accentLight,
        ),
      ),
    );
  }
}
