import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/mihrab_palette.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({super.key, this.lastUpdated});

  final String? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final fontSize = r.font(14, min: 12);

    final labelStyle = context.text.label.copyWith(fontSize: fontSize);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: r.s(24),
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: fontSize + 3,
              color: p.success,
            ),
            const SizedBox(width: 8),
            Text(
              'يعمل دون إنترنت',
              style: labelStyle.copyWith(color: p.success),
            ),
          ],
        ),
        if (lastUpdated != null && lastUpdated!.isNotEmpty)
          Text('آخر تحديث: $lastUpdated', style: labelStyle),
        Text(
          'MIHRAB  |  محراب',
          style: labelStyle.copyWith(
            color: p.accent,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
