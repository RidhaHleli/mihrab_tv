import 'package:flutter/material.dart';

import '../../../../core/constants/calculation_methods.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme_controller.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../locations/domain/entities/tunisia_location.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_app_settings.dart';
import '../../domain/usecases/save_app_settings.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    required this._getAppSettings,
    required this._saveAppSettings,
  });

  final GetAppSettings _getAppSettings;
  final SaveAppSettings _saveAppSettings;

  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _getAppSettings();
      _applyGlobals(_settings);
    } catch (e) {
      _error = 'Unable to load settings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Theme and language are app-wide: apply them as soon as they change.
  void _applyGlobals(AppSettings s) {
    AppThemeController.instance.value = AppThemeId.fromName(s.themeId);
    AppLocaleController.instance.value = s.language;
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    _applyGlobals(newSettings);
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _saveAppSettings(newSettings);
    } catch (e) {
      _error = 'Unable to save settings.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Applies [change] to the current settings and saves the result.
  Future<void> update(AppSettings Function(AppSettings current) change) {
    return updateSettings(change(_settings));
  }

  Future<void> updateDisplayName(String value) =>
      update((s) => s.copyWith(displayName: value));

  Future<void> updateLocation(TunisiaLocation location) {
    return update(
      (s) => s.copyWith(
        cityName: location.city,
        cityNameFr: location.cityFr,
        cityNameEn: location.cityEnOrFr,
        governorateName: location.governorate,
        countryCode: location.countryCode,
        timezone: location.timezone,
        latitude: location.latitude,
        longitude: location.longitude,
        calculationMethod: CalculationMethods.normalize(location.method),
      ),
    );
  }

  Future<void> updateTheme(AppThemeId id) =>
      update((s) => s.copyWith(themeId: id.name));

  Future<void> updateLanguage(String code) =>
      update((s) => s.copyWith(language: code));

  Future<void> updateAdhanAdjustment(int index, int minutes) {
    return update((s) {
      final list = List<int>.of(s.adhanAdjustments);
      list[index] = minutes.clamp(-30, 30).toInt();
      return s.copyWith(adhanAdjustments: list);
    });
  }

  Future<void> updateIqamaDelay(int index, int minutes) {
    return update((s) {
      final list = List<int>.of(s.iqamaDelays);
      list[index] = minutes.clamp(0, 60).toInt();
      return s.copyWith(iqamaDelays: list);
    });
  }

  Future<void> addAnnouncement(String text) {
    final value = text.trim();
    if (value.isEmpty) return Future.value();

    return update((s) {
      if (s.announcements.length >= 20) return s;
      final trimmed = value.length > 200 ? value.substring(0, 200) : value;
      return s.copyWith(announcements: [...s.announcements, trimmed]);
    });
  }

  Future<void> removeAnnouncement(int index) {
    return update((s) {
      final list = List<String>.of(s.announcements)..removeAt(index);
      return s.copyWith(announcements: list);
    });
  }
}
