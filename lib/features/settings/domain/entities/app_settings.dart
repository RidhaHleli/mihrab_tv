import '../../../../core/constants/calculation_methods.dart';

class AppSettings {
  const AppSettings({
    this.displayName = 'مسجد الرحمة',
    this.cityName = 'القيروان',
    this.cityNameFr = 'Kairouan',
    this.cityNameEn = 'Kairouan',
    this.governorateName = 'القيروان',
    this.countryCode = 'TN',
    this.timezone = 'Africa/Tunis',
    this.latitude = 35.6781,
    this.longitude = 10.09633,
    this.calculationMethod = CalculationMethods.defaultMethod,
    this.language = 'ar',
    this.adhanEnabled = true,
    this.iqamaEnabled = true,
    this.volume = 0.8,
    this.adhanAdjustments = const [0, 0, 0, 0, 0, 0],
    this.iqamaDelays = const [20, 0, 15, 10, 5, 15],
    this.jumuahDelayMinutes = 30,
    this.announcements = const [],
    this.announcementsEnabled = true,
    this.dailyReminderEnabled = true,
    this.ramadanMode = 'auto',
    this.hijriAdjustment = 0,
    this.imsakMinutes = 10,
    this.nightModeEnabled = false,
    this.autoStartEnabled = true,
    this.notificationsEnabled = true,
    this.remoteEnabled = false,
    this.remoteToken = '',
    this.themeId = 'kairouan',
  });

  final String displayName;

  final String cityName;
  final String cityNameFr;
  final String cityNameEn;
  final String governorateName;
  final String countryCode;
  final String timezone;
  final double latitude;
  final double longitude;

  /// AlAdhan calculation method id.
  final int calculationMethod;

  /// 'ar' | 'fr' | 'en'
  final String language;

  final bool adhanEnabled;
  final bool iqamaEnabled;
  final double volume;

  /// Minutes added to (or removed from) each prayer, indexed by PrayerType.
  final List<int> adhanAdjustments;

  /// Minutes between adhan and iqama, indexed by PrayerType.
  final List<int> iqamaDelays;

  /// Minutes between the Friday adhan and the prayer.
  final int jumuahDelayMinutes;

  final List<String> announcements;
  final bool announcementsEnabled;
  final bool dailyReminderEnabled;

  /// 'auto' | 'on' | 'off'
  final String ramadanMode;
  final int hijriAdjustment;
  final int imsakMinutes;

  final bool nightModeEnabled;
  final bool autoStartEnabled;

  /// Phones: adhan notifications that ring even when the app is closed.
  final bool notificationsEnabled;

  final bool remoteEnabled;
  final String remoteToken;

  /// Name of the selected visual theme (see AppThemeId).
  final String themeId;

  /// City name in the active interface language.
  String localizedCity() {
    switch (language) {
      case 'fr':
        return cityNameFr.isEmpty ? cityName : cityNameFr;
      case 'en':
        return cityNameEn.isEmpty ? cityName : cityNameEn;
      default:
        return cityName;
    }
  }

  AppSettings copyWith({
    String? displayName,
    String? cityName,
    String? cityNameFr,
    String? cityNameEn,
    String? governorateName,
    String? countryCode,
    String? timezone,
    double? latitude,
    double? longitude,
    int? calculationMethod,
    String? language,
    bool? adhanEnabled,
    bool? iqamaEnabled,
    double? volume,
    List<int>? adhanAdjustments,
    List<int>? iqamaDelays,
    int? jumuahDelayMinutes,
    List<String>? announcements,
    bool? announcementsEnabled,
    bool? dailyReminderEnabled,
    String? ramadanMode,
    int? hijriAdjustment,
    int? imsakMinutes,
    bool? nightModeEnabled,
    bool? autoStartEnabled,
    bool? notificationsEnabled,
    bool? remoteEnabled,
    String? remoteToken,
    String? themeId,
  }) {
    return AppSettings(
      displayName: displayName ?? this.displayName,
      cityName: cityName ?? this.cityName,
      cityNameFr: cityNameFr ?? this.cityNameFr,
      cityNameEn: cityNameEn ?? this.cityNameEn,
      governorateName: governorateName ?? this.governorateName,
      countryCode: countryCode ?? this.countryCode,
      timezone: timezone ?? this.timezone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      language: language ?? this.language,
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      iqamaEnabled: iqamaEnabled ?? this.iqamaEnabled,
      volume: volume ?? this.volume,
      adhanAdjustments: adhanAdjustments ?? this.adhanAdjustments,
      iqamaDelays: iqamaDelays ?? this.iqamaDelays,
      jumuahDelayMinutes: jumuahDelayMinutes ?? this.jumuahDelayMinutes,
      announcements: announcements ?? this.announcements,
      announcementsEnabled: announcementsEnabled ?? this.announcementsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      ramadanMode: ramadanMode ?? this.ramadanMode,
      hijriAdjustment: hijriAdjustment ?? this.hijriAdjustment,
      imsakMinutes: imsakMinutes ?? this.imsakMinutes,
      nightModeEnabled: nightModeEnabled ?? this.nightModeEnabled,
      autoStartEnabled: autoStartEnabled ?? this.autoStartEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      remoteEnabled: remoteEnabled ?? this.remoteEnabled,
      remoteToken: remoteToken ?? this.remoteToken,
      themeId: themeId ?? this.themeId,
    );
  }

  /// Settings that change the prayer times themselves (need a reload).
  bool timesDifferFrom(AppSettings other) {
    return latitude != other.latitude ||
        longitude != other.longitude ||
        calculationMethod != other.calculationMethod ||
        timezone != other.timezone ||
        !_sameInts(adhanAdjustments, other.adhanAdjustments);
  }

  static bool _sameInts(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // --- Remote control (phone) ---------------------------------------------

  Map<String, dynamic> toRemoteJson() {
    return {
      'displayName': displayName,
      'language': language,
      'themeId': themeId,
      'adhanEnabled': adhanEnabled,
      'iqamaEnabled': iqamaEnabled,
      'volume': volume,
      'adhanAdjustments': adhanAdjustments,
      'iqamaDelays': iqamaDelays,
      'jumuahDelayMinutes': jumuahDelayMinutes,
      'announcements': announcements,
      'announcementsEnabled': announcementsEnabled,
      'dailyReminderEnabled': dailyReminderEnabled,
      'ramadanMode': ramadanMode,
      'hijriAdjustment': hijriAdjustment,
      'imsakMinutes': imsakMinutes,
      'nightModeEnabled': nightModeEnabled,
      'calculationMethod': calculationMethod,
    };
  }

  /// Applies a JSON payload coming from the phone. Every value is validated
  /// and clamped; unknown or invalid fields are ignored.
  AppSettings applyRemoteJson(Map<String, dynamic> json) {
    String? str(String key, {int max = 80}) {
      final v = json[key];
      if (v is! String) return null;
      final t = v.trim();
      return t.length > max ? t.substring(0, max) : t;
    }

    bool? flag(String key) {
      final v = json[key];
      return v is bool ? v : null;
    }

    int? integer(String key, int min, int max) {
      final v = json[key];
      if (v is! num) return null;
      return v.round().clamp(min, max).toInt();
    }

    List<int>? ints(String key, int min, int max) {
      final v = json[key];
      if (v is! List || v.length != 6) return null;
      final out = <int>[];
      for (final item in v) {
        if (item is! num) return null;
        out.add(item.round().clamp(min, max).toInt());
      }
      return out;
    }

    List<String>? texts() {
      final v = json['announcements'];
      if (v is! List) return null;
      return v
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => e.length > 200 ? e.substring(0, 200) : e)
          .take(20)
          .toList();
    }

    final language = str('language');
    final themeId = str('themeId');
    final ramadan = str('ramadanMode');
    final volume = json['volume'];
    final method = integer('calculationMethod', 0, 99);

    return copyWith(
      displayName: str('displayName'),
      language: const ['ar', 'fr', 'en'].contains(language) ? language : null,
      themeId: const ['kairouan', 'makkah', 'quds'].contains(themeId)
          ? themeId
          : null,
      adhanEnabled: flag('adhanEnabled'),
      iqamaEnabled: flag('iqamaEnabled'),
      volume: volume is num ? volume.toDouble().clamp(0.0, 1.0).toDouble() : null,
      adhanAdjustments: ints('adhanAdjustments', -30, 30),
      iqamaDelays: ints('iqamaDelays', 0, 60),
      jumuahDelayMinutes: integer('jumuahDelayMinutes', 5, 90),
      announcements: texts(),
      announcementsEnabled: flag('announcementsEnabled'),
      dailyReminderEnabled: flag('dailyReminderEnabled'),
      ramadanMode: const ['auto', 'on', 'off'].contains(ramadan)
          ? ramadan
          : null,
      hijriAdjustment: integer('hijriAdjustment', -2, 2),
      imsakMinutes: integer('imsakMinutes', 0, 30),
      nightModeEnabled: flag('nightModeEnabled'),
      calculationMethod:
          method == null ? null : CalculationMethods.normalize(method),
    );
  }
}
