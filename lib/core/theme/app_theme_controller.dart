import 'package:flutter/foundation.dart';

import 'mihrab_palette.dart';

/// Holds the active theme so the whole app can react to a change at once.
class AppThemeController extends ValueNotifier<AppThemeId> {
  AppThemeController._() : super(AppThemeId.kairouan);

  static final AppThemeController instance = AppThemeController._();
}
