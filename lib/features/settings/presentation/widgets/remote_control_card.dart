import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/remote/remote_control_service.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../domain/entities/app_settings.dart';

/// QR code + link to control the app from a phone on the same Wi-Fi.
class RemoteControlCard extends StatelessWidget {
  const RemoteControlCard({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;

    if (!RemoteControlService.isSupported) {
      return Text(context.tr('remote_unavailable'), style: t.label);
    }

    if (!settings.remoteEnabled) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: RemoteControlService.instance,
      builder: (context, _) {
        final service = RemoteControlService.instance;

        if (service.failed) {
          return Text(
            context.tr('remote_error'),
            style: t.label.copyWith(color: p.error),
          );
        }

        final url = service.url;

        if (url == null) {
          return Text(
            service.isRunning
                ? context.tr('remote_no_network')
                : '...',
            style: t.label,
          );
        }

        return Wrap(
          spacing: 24,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: QrImageView(
                data: url,
                size: 170,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('remote_url'), style: t.label),
                  const SizedBox(height: 4),
                  SelectableText(
                    url,
                    textDirection: TextDirection.ltr,
                    style: t.title.copyWith(fontSize: 16, color: p.accentLight),
                  ),
                  const SizedBox(height: 12),
                  Text(context.tr('remote_code'), style: t.label),
                  const SizedBox(height: 4),
                  Text(
                    settings.remoteToken,
                    textDirection: TextDirection.ltr,
                    style: t.title.copyWith(fontSize: 22, letterSpacing: 4),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
