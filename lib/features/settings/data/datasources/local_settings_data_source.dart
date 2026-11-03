import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';

class LocalSettingsDataSource {
  static const _displayNameKey = 'display_name';

  static const _cityNameKey = 'city_name';
  static const _governorateNameKey = 'governorate_name';
  static const _latitudeKey = 'latitude';
  static const _longitudeKey = 'longitude';

  static const _adhanEnabledKey = 'adhan_enabled';
  static const _iqamaEnabledKey = 'iqama_enabled';
  static const _volumeKey = 'audio_volume';
  static const _iqamaDelayKey = 'iqama_delay_minutes';
  static const _themeIdKey = 'theme_id';

  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return AppSettings(
      displayName: prefs.getString(_displayNameKey) ?? 'مسجد الرحمة',

      cityName: prefs.getString(_cityNameKey) ?? 'القيروان',
      governorateName: prefs.getString(_governorateNameKey) ?? 'القيروان',
      latitude: prefs.getDouble(_latitudeKey) ?? 35.6781,
      longitude: prefs.getDouble(_longitudeKey) ?? 10.09633,

      adhanEnabled: prefs.getBool(_adhanEnabledKey) ?? true,
      iqamaEnabled: prefs.getBool(_iqamaEnabledKey) ?? true,
      volume: prefs.getDouble(_volumeKey) ?? 0.8,
      iqamaDelayMinutes: prefs.getInt(_iqamaDelayKey) ?? 10,
      themeId: prefs.getString(_themeIdKey) ?? 'kairouan',
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_displayNameKey, settings.displayName);

    await prefs.setString(_cityNameKey, settings.cityName);
    await prefs.setString(_governorateNameKey, settings.governorateName);
    await prefs.setDouble(_latitudeKey, settings.latitude);
    await prefs.setDouble(_longitudeKey, settings.longitude);

    await prefs.setBool(_adhanEnabledKey, settings.adhanEnabled);
    await prefs.setBool(_iqamaEnabledKey, settings.iqamaEnabled);
    await prefs.setDouble(_volumeKey, settings.volume);
    await prefs.setInt(_iqamaDelayKey, settings.iqamaDelayMinutes);
    await prefs.setString(_themeIdKey, settings.themeId);
  }
}
