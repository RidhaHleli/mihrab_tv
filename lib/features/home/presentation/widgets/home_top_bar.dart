import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/islamic_patterns.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../core/widgets/focusable_card.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.mosqueName,
    required this.location,
    required this.onSettingsPressed,
  });

  final String mosqueName;
  final String location;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final t = context.text;
    final badge = r.tap(54);

    return Row(
      children: [
        SizedBox(
          width: badge,
          height: badge,
          child: GlassSurface(
            radius: 16,
            borderColor: p.accent.withValues(alpha: 0.5),
            child: Center(
              child: StarOrnament(color: p.accent, size: badge * 0.58),
            ),
          ),
        ),
        SizedBox(width: r.gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mosqueName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.title.copyWith(
                  fontSize: r.font(23, min: 18),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: p.accent,
                    size: r.font(16, min: 14),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.label.copyWith(
                        fontSize: r.font(16, min: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: r.gap),
        FocusableCard(
          onTap: onSettingsPressed,
          semanticLabel: context.tr('settings'),
          child: SizedBox(
            width: r.tap(52),
            height: r.tap(52),
            child: Icon(
              Icons.settings_outlined,
              color: p.textSecondary,
              size: r.font(25, min: 22),
            ),
          ),
        ),
      ],
    );
  }
}
