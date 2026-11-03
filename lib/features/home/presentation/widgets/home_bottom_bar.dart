import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/utils/date_time_utils.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({
    super.key,
    this.lastSync,
    this.isOnline = true,
    this.isSyncing = false,
  });

  /// Last time the prayer calendar was downloaded.
  final DateTime? lastSync;

  /// False when the last synchronisation attempt failed.
  final bool isOnline;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final fontSize = r.font(14, min: 12);

    final labelStyle = context.text.label.copyWith(fontSize: fontSize);

    final synced = lastSync != null && isOnline;
    final statusColor = synced ? p.success : p.textMuted;
    final statusIcon = isSyncing
        ? Icons.sync_rounded
        : (synced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined);
    final statusText = isSyncing
        ? context.tr('syncing')
        : (synced ? context.tr('online_synced') : context.tr('offline_ok'));

    final lastText = lastSync == null
        ? context.tr('never_synced')
        : '${context.tr('last_update')}: '
              '‪${DateTimeUtils.formatDate(lastSync!).substring(0, 5)} '
              '${DateTimeUtils.formatTime(lastSync!)}‬';

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: r.s(24),
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: fontSize + 3, color: statusColor),
            const SizedBox(width: 8),
            Text(statusText, style: labelStyle.copyWith(color: statusColor)),
          ],
        ),
        Text(lastText, style: labelStyle),
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
