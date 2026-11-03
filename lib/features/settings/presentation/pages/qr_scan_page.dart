import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/mihrab_palette.dart';

/// Scans the QR code shown by a MIHRAB TV and opens its remote control page
/// in the phone browser.
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  /// Only addresses of the local network are accepted (the TV never exposes
  /// its remote control on the Internet).
  @visibleForTesting
  static Uri? parseRemoteUrl(String? raw) {
    if (raw == null) return null;

    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != 'http' || !uri.hasAuthority) return null;
    if (!uri.queryParameters.containsKey('t')) return null;

    final parts = uri.host.split('.');
    if (parts.length != 4) return null;

    final n = parts.map(int.tryParse).toList();
    if (n.any((v) => v == null || v < 0 || v > 255)) return null;

    final a = n[0]!;
    final b = n[1]!;
    final private =
        a == 10 || (a == 192 && b == 168) || (a == 172 && b >= 16 && b <= 31);

    return private ? uri : null;
  }

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _handled = false;
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;

    for (final barcode in capture.barcodes) {
      final uri = QrScanPage.parseRemoteUrl(barcode.rawValue);

      if (uri != null) {
        _handled = true;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) Navigator.of(context).pop();
        return;
      }
    }

    if (!_invalid && mounted) setState(() => _invalid = true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('scan_title'))),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: p.accent, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                context.tr(_invalid ? 'scan_invalid' : 'scan_hint'),
                textAlign: TextAlign.center,
                style: t.body.copyWith(
                  color: _invalid ? p.error : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
