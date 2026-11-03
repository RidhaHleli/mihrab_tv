import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/calculation_methods.dart';
import '../../domain/entities/app_settings.dart';

class LocalSettingsDataSource {
  static const _displayNameKey = 'display_name';

  static const _cityNameKey = 'city_name';
  static const _cityNameFrKey = 'city_name_fr';
  static const _cityNameEnKey = 'city_name_en';
  static const _governorateNameKey = 'governorate_name';
  static const _countryCodeKey = 'country_code';
  static const _timezoneKey = 'timezone';
  static const _latitudeKey = 'latitude';
  static const _longitudeKey = 'longitude';
  static const _methodKey = 'calculation_method';
  static const _languageKey = 'language';

  static const _adhanEnabledKey = 'adhan_enabled';
  static const _iqamaEnabledKey = 'iqama_enabled';
  static const _volumeKey = 'audio_volume';
  static const _adjustmentsKey = 'adhan_adjustments';
  static const _iqamaDelaysKey = 'iqama_delays';
  static const _jumuahDelayKey = 'jumuah_delay_minutes';

  static const _announcementsKey = 'announcements';
  static const _announcementsEnabledKey = 'announcements_enabled';
  static const _reminderEnabledKey = 'daily_reminder_enabled';

  static const _ramadanModeKey = 'ramadan_mode';
  static const _hijriAdjustmentKey = 'hijri_adjustment';
  static const _imsakMinutesKey = 'imsak_minutes';

  static const _nightModeKey = 'night_mode_enabled';

  /// Read natively by the Android BootReceiver (prefix "flutter." is added by
  /// the plugin), so keep this exact name.
  static const _autoStartKey = 'auto_start_enabled';

  static const _remoteEnabledKey = 'remote_enabled';
  static const _remoteTokenKey = 'remote_token';
  static const _themeIdKey = 'theme_id';

  static List<int> _intList(
    SharedPreferences prefs,
    String key,
    List<int> fallback,
  ) {
    final raw = prefs.getStringList(key);
    if (raw == null || raw.length != fallback.length) return fallback;

    final parsed = raw.map(int.tryParse).toList();
    if (parsed.contains(null)) return fallback;

    return parsed.cast<int>();
  }

  static String _newToken() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    const d = AppSettings();

    var token = prefs.getString(_remoteTokenKey) ?? '';
    if (token.isEmpty) {
      token = _newToken();
      await prefs.setString(_remoteTokenKey, token);
    }

    return AppSettings(
      displayName: prefs.getString(_displayNameKey) ?? d.displayName,
      cityName: prefs.getString(_cityNameKey) ?? d.cityName,
      cityNameFr: prefs.getString(_cityNameFrKey) ?? d.cityNameFr,
      cityNameEn: prefs.getString(_cityNameEnKey) ?? d.cityNameEn,
      governorateName:
          prefs.getString(_governorateNameKey) ?? d.governorateName,
      countryCode: prefs.getString(_countryCodeKey) ?? d.countryCode,
      timezone: prefs.getString(_timezoneKey) ?? d.timezone,
      latitude: prefs.getDouble(_latitudeKey) ?? d.latitude,
      longitude: prefs.getDouble(_longitudeKey) ?? d.longitude,
      calculationMethod: CalculationMethods.normalize(
        prefs.getInt(_methodKey) ?? d.calculationMethod,
      ),
      language: prefs.getString(_languageKey) ?? d.language,
      adhanEnabled: prefs.getBool(_adhanEnabledKey) ?? d.adhanEnabled,
      iqamaEnabled: prefs.getBool(_iqamaEnabledKey) ?? d.iqamaEnabled,
      volume: prefs.getDouble(_volumeKey) ?? d.volume,
      adhanAdjustments: _intList(prefs, _adjustmentsKey, d.adhanAdjustments),
      iqamaDelays: _intList(prefs, _iqamaDelaysKey, d.iqamaDelays),
      jumuahDelayMinutes: prefs.getInt(_jumuahDelayKey) ?? d.jumuahDelayMinutes,
      announcements: prefs.getStringList(_announcementsKey) ?? d.announcements,
      announcementsEnabled:
          prefs.getBool(_announcementsEnabledKey) ?? d.announcementsEnabled,
      dailyReminderEnabled:
          prefs.getBool(_reminderEnabledKey) ?? d.dailyReminderEnabled,
      ramadanMode: prefs.getString(_ramadanModeKey) ?? d.ramadanMode,
      hijriAdjustment: prefs.getInt(_hijriAdjustmentKey) ?? d.hijriAdjustment,
      imsakMinutes: prefs.getInt(_imsakMinutesKey) ?? d.imsakMinutes,
      nightModeEnabled: prefs.getBool(_nightModeKey) ?? d.nightModeEnabled,
      autoStartEnabled: prefs.getBool(_autoStartKey) ?? d.autoStartEnabled,
      remoteEnabled: prefs.getBool(_remoteEnabledKey) ?? d.remoteEnabled,
      remoteToken: token,
      themeId: prefs.getString(_themeIdKey) ?? d.themeId,
    );
  }

  Future<void> saveSettings(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_displayNameKey, s.displayName);

    await prefs.setString(_cityNameKey, s.cityName);
    await prefs.setString(_cityNameFrKey, s.cityNameFr);
    await prefs.setString(_cityNameEnKey, s.cityNameEn);
    await prefs.setString(_governorateNameKey, s.governorateName);
    await prefs.setString(_countryCodeKey, s.countryCode);
    await prefs.setString(_timezoneKey, s.timezone);
    await prefs.setDouble(_latitudeKey, s.latitude);
    await prefs.setDouble(_longitudeKey, s.longitude);
    await prefs.setInt(_methodKey, s.calculationMethod);
    await prefs.setString(_languageKey, s.language);

    await prefs.setBool(_adhanEnabledKey, s.adhanEnabled);
    await prefs.setBool(_iqamaEnabledKey, s.iqamaEnabled);
    await prefs.setDouble(_volumeKey, s.volume);
    await prefs.setStringList(
      _adjustmentsKey,
      s.adhanAdjustments.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      _iqamaDelaysKey,
      s.iqamaDelays.map((e) => e.toString()).toList(),
    );
    await prefs.setInt(_jumuahDelayKey, s.jumuahDelayMinutes);

    await prefs.setStringList(_announcementsKey, s.announcements);
    await prefs.setBool(_announcementsEnabledKey, s.announcementsEnabled);
    await prefs.setBool(_reminderEnabledKey, s.dailyReminderEnabled);

    await prefs.setString(_ramadanModeKey, s.ramadanMode);
    await prefs.setInt(_hijriAdjustmentKey, s.hijriAdjustment);
    await prefs.setInt(_imsakMinutesKey, s.imsakMinutes);

    await prefs.setBool(_nightModeKey, s.nightModeEnabled);
    await prefs.setBool(_autoStartKey, s.autoStartEnabled);

    await prefs.setBool(_remoteEnabledKey, s.remoteEnabled);
    await prefs.setString(_remoteTokenKey, s.remoteToken);
    await prefs.setString(_themeIdKey, s.themeId);
  }
}
