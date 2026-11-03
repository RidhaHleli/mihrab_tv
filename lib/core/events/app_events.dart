import 'package:flutter/foundation.dart';

/// Tiny in-app event bus.
abstract final class AppEvents {
  /// Incremented every time the saved settings change (from the settings
  /// screen or from the phone remote control).
  static final ValueNotifier<int> settingsChanged = ValueNotifier<int>(0);
}
