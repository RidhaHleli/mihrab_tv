import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Small bridge to Android-only features (overlay permission for auto-start).
abstract final class SystemService {
  static const MethodChannel _channel = MethodChannel('mihrab/system');

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool? _isTv;

  /// True on Android TV / boxes (leanback), false on phones and tablets.
  static Future<bool> isTv() async {
    if (_isTv != null) return _isTv!;
    if (!isAndroid) return _isTv = false;

    try {
      _isTv = await _channel.invokeMethod<bool>('isTv') ?? false;
    } catch (_) {
      _isTv = false;
    }
    return _isTv!;
  }

  /// Whether the app may start itself in the background after a reboot.
  static Future<bool> canDrawOverlays() async {
    if (!isAndroid) return true;

    try {
      return await _channel.invokeMethod<bool>('canDrawOverlays') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens the Android "display over other apps" screen for this app.
  static Future<void> openOverlaySettings() async {
    if (!isAndroid) return;

    try {
      await _channel.invokeMethod<bool>('openOverlaySettings');
    } catch (_) {
      // Not available on this device.
    }
  }
}
