import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../constants/calculation_methods.dart';
import '../l10n/app_strings.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import 'remote_control_page.dart';

typedef LoadSettings = Future<AppSettings> Function();
typedef SaveSettings = Future<void> Function(AppSettings settings);

/// Tiny LAN-only HTTP server: the phone opens the QR code URL and edits the
/// settings. Every request needs the pairing token shown with the QR code.
class RemoteControlServer {
  RemoteControlServer({
    required this.loadSettings,
    required this.saveSettings,
    required this.onChanged,
  });

  final LoadSettings loadSettings;
  final SaveSettings saveSettings;
  final void Function() onChanged;

  static const List<int> ports = [8484, 8485, 8486, 8487, 8488, 8489];
  static const int _maxBodyBytes = 32 * 1024;
  static const int _maxFailures = 30;

  static const List<String> _labelKeys = [
    'appearance', 'display_name', 'language', 'adhan_section', 'adhan_on',
    'iqama_on', 'volume', 'calc_method', 'minutes_unit', 'iqama_delays',
    'jumuah_delay', 'announcements', 'announcements_on', 'reminders_on',
    'no_announcements', 'announcement_hint', 'add', 'delete',
    'ramadan_section', 'ramadan_mode', 'mode_auto', 'mode_on', 'mode_off',
    'hijri_adjust', 'imsak_minutes', 'screen_section', 'night_mode', 'save',
    'remote_saved', 'fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha',
    'theme_kairouan', 'theme_makkah', 'theme_quds',
  ];

  HttpServer? _server;
  String _token = '';
  int _failures = 0;

  int? get port => _server?.port;
  bool get isRunning => _server != null;

  Future<bool> start(String token) async {
    if (_server != null) {
      _token = token;
      return true;
    }

    _token = token;

    for (final candidate in ports) {
      try {
        final server = await HttpServer.bind(
          InternetAddress.anyIPv4,
          candidate,
          shared: false,
        );
        _server = server;
        server.listen(_handle, onError: (_) {});
        return true;
      } on SocketException {
        // Port busy: try the next one.
      }
    }

    return false;
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    await server?.close(force: true);
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      final response = request.response;
      response.headers
        ..set('Cache-Control', 'no-store')
        ..set('X-Content-Type-Options', 'nosniff');

      if (_failures >= _maxFailures) {
        response.statusCode = HttpStatus.tooManyRequests;
        await response.close();
        return;
      }

      final given = request.uri.queryParameters['t'] ?? '';
      if (_token.isEmpty || !_safeEquals(given, _token)) {
        _failures++;
        response.statusCode = HttpStatus.unauthorized;
        await response.close();
        return;
      }

      final path = request.uri.path;

      if (path == '/' && request.method == 'GET') {
        response.headers.contentType = ContentType.html;
        response.write(remoteControlHtml);
        await response.close();
        return;
      }

      if (path == '/api/settings') {
        if (request.method == 'GET') {
          await _sendSettings(response, await loadSettings());
          return;
        }

        if (request.method == 'POST') {
          final body = await _readBody(request);
          final decoded = jsonDecode(body);

          if (decoded is! Map<String, dynamic>) {
            response.statusCode = HttpStatus.badRequest;
            await response.close();
            return;
          }

          final updated = (await loadSettings()).applyRemoteJson(decoded);
          await saveSettings(updated);
          onChanged();
          await _sendSettings(response, updated);
          return;
        }
      }

      response.statusCode = HttpStatus.notFound;
      await response.close();
    } catch (_) {
      try {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
      } catch (_) {
        // Connection already closed.
      }
    }
  }

  Future<void> _sendSettings(HttpResponse response, AppSettings s) async {
    final lang = s.language;

    final payload = {
      'settings': s.toRemoteJson(),
      'labels': {
        for (final key in _labelKeys) key: trFor(lang, key),
        'theme': trFor(lang, 'appearance'),
      },
      'methods': {
        for (final entry in CalculationMethods.names.entries)
          entry.key.toString(): entry.value,
      },
    };

    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(payload));
    await response.close();
  }

  Future<String> _readBody(HttpRequest request) async {
    final bytes = <int>[];

    await for (final chunk in request) {
      bytes.addAll(chunk);
      if (bytes.length > _maxBodyBytes) {
        throw const FormatException('Body too large');
      }
    }

    return utf8.decode(bytes);
  }

  bool _safeEquals(String a, String b) {
    if (a.length != b.length) return false;

    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
