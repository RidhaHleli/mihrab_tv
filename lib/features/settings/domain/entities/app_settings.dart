class AppSettings {
  const AppSettings({
    this.displayName = 'مسجد الرحمة',
    this.cityName = 'القيروان',
    this.governorateName = 'القيروان',
    this.latitude = 35.6781,
    this.longitude = 10.09633,
    this.adhanEnabled = true,
    this.iqamaEnabled = true,
    this.volume = 0.8,
    this.iqamaDelayMinutes = 10,
    this.themeId = 'kairouan',
  });

  final String displayName;

  final String cityName;
  final String governorateName;
  final double latitude;
  final double longitude;

  final bool adhanEnabled;
  final bool iqamaEnabled;
  final double volume;
  final int iqamaDelayMinutes;

  /// Name of the selected visual theme (see AppThemeId).
  final String themeId;

  AppSettings copyWith({
    String? displayName,
    String? cityName,
    String? governorateName,
    double? latitude,
    double? longitude,
    bool? adhanEnabled,
    bool? iqamaEnabled,
    double? volume,
    int? iqamaDelayMinutes,
    String? themeId,
  }) {
    return AppSettings(
      displayName: displayName ?? this.displayName,
      cityName: cityName ?? this.cityName,
      governorateName: governorateName ?? this.governorateName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      iqamaEnabled: iqamaEnabled ?? this.iqamaEnabled,
      volume: volume ?? this.volume,
      iqamaDelayMinutes: iqamaDelayMinutes ?? this.iqamaDelayMinutes,
      themeId: themeId ?? this.themeId,
    );
  }
}
