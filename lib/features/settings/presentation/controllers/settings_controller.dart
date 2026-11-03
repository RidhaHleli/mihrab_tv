import 'package:flutter/material.dart';

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
      AppThemeController.instance.value = AppThemeId.fromName(_settings.themeId);
    } catch (e) {
      _error = 'Unable to load settings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
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

  Future<void> updateDisplayName(String value) =>
      updateSettings(_settings.copyWith(displayName: value));

  Future<void> updateLocation(TunisiaLocation location) {
    return updateSettings(
      _settings.copyWith(
        cityName: location.city,
        governorateName: location.governorate,
        latitude: location.latitude,
        longitude: location.longitude,
      ),
    );
  }

  Future<void> updateTheme(AppThemeId id) {
    // Apply immediately so the whole app previews the new look.
    AppThemeController.instance.value = id;
    return updateSettings(_settings.copyWith(themeId: id.name));
  }

  Future<void> updateAdhanEnabled(bool value) =>
      updateSettings(_settings.copyWith(adhanEnabled: value));

  Future<void> updateIqamaEnabled(bool value) =>
      updateSettings(_settings.copyWith(iqamaEnabled: value));

  Future<void> updateVolume(double value) =>
      updateSettings(_settings.copyWith(volume: value));

  Future<void> updateIqamaDelay(int value) =>
      updateSettings(_settings.copyWith(iqamaDelayMinutes: value));
}