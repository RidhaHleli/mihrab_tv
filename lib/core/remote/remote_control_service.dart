import 'dart:io';

import 'package:flutter/foundation.dart';

import '../events/app_events.dart';
import '../../features/settings/data/datasources/local_settings_data_source.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import 'remote_control_server.dart';

/// App-wide handle on the phone remote control.
class RemoteControlService extends ChangeNotifier {
  RemoteControlService._();

  static final RemoteControlService instance = RemoteControlService._();

  final LocalSettingsDataSource _store = LocalSettingsDataSource();
  RemoteControlServer? _server;

  String? _address;
  String _token = '';
  bool _failed = false;

  /// Not available on the web build (no sockets in a browser).
  static bool get isSupported => !kIsWeb;

  bool get isRunning => _server?.isRunning ?? false;
  bool get failed => _failed;

  /// "http://192.168.1.20:8484/?t=123456", or null when no network.
  String? get url {
    if (!isRunning || _address == null) return null;
    return 'http://$_address:${_server!.port}/?t=$_token';
  }

  /// Starts or stops the server so it matches [settings].
  Future<void> apply(AppSettings settings) async {
    if (!isSupported) return;

    if (!settings.remoteEnabled) {
      await _stop();
      return;
    }

    _token = settings.remoteToken;
    _server ??= RemoteControlServer(
      loadSettings: _store.getSettings,
      saveSettings: _store.saveSettings,
      onChanged: () => AppEvents.settingsChanged.value++,
    );

    final ok = await _server!.start(_token);
    _failed = !ok;
    _address = ok ? await _findLocalAddress() : null;
    notifyListeners();
  }

  Future<void> _stop() async {
    if (_server == null) return;

    await _server!.stop();
    _address = null;
    _failed = false;
    notifyListeners();
  }

  Future<String?> _findLocalAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      String? fallback;

      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          final ip = address.address;
          if (_isPrivate(ip)) return ip;
          fallback ??= ip;
        }
      }

      return fallback;
    } catch (_) {
      return null;
    }
  }

  bool _isPrivate(String ip) {
    if (ip.startsWith('192.168.') || ip.startsWith('10.')) return true;

    final parts = ip.split('.');
    if (parts.length == 4 && parts[0] == '172') {
      final second = int.tryParse(parts[1]) ?? 0;
      return second >= 16 && second <= 31;
    }

    return false;
  }
}
