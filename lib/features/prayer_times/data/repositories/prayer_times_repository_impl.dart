import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../../../settings/data/datasources/local_settings_data_source.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../datasources/local_prayer_calendar_cache_data_source.dart';
import '../datasources/local_prayer_times_data_source.dart';
import '../datasources/remote_prayer_times_data_source.dart';
import '../models/prayer_time_model.dart';

class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  const PrayerTimesRepositoryImpl({
    required this._dataSource,
    required this._remoteDataSource,
    required this._cacheDataSource,
    required this._settingsDataSource,
  });

  final LocalPrayerTimesDataSource _dataSource;
  final RemotePrayerTimesDataSource _remoteDataSource;
  final LocalPrayerCalendarCacheDataSource _cacheDataSource;
  final LocalSettingsDataSource _settingsDataSource;

  static const double _kairouanLatitude = 35.6781;
  static const double _kairouanLongitude = 10.09633;

  @override
  Future<List<PrayerTime>> getDailyPrayerTimes(DateTime date) async {
    final settings = await _settingsDataSource.getSettings();
    final raw = await _loadRaw(date, settings);

    return _applyAdjustments(raw, date, settings);
  }

  Future<List<PrayerTimeModel>> _loadRaw(
    DateTime date,
    AppSettings settings,
  ) async {
    final cached = await _cacheDataSource.getPrayerTimesForDate(
      date: date,
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
    );

    if (cached != null) return cached;

    try {
      final remote = await _remoteDataSource.getPrayerTimesForDate(
        date: date,
        latitude: settings.latitude,
        longitude: settings.longitude,
        method: settings.calculationMethod,
        timezone: settings.timezone,
      );

      try {
        await _cacheDataSource.saveCalendar(
          latitude: settings.latitude,
          longitude: settings.longitude,
          method: settings.calculationMethod,
          calendar: {date: remote},
        );
      } catch (_) {
        // A cache failure must not block valid remote results.
      }

      return remote;
    } catch (_) {
      // Bundled timetable only matches Kairouan with the Tunisian method.
      final isKairouan =
          (settings.latitude - _kairouanLatitude).abs() < 0.0001 &&
          (settings.longitude - _kairouanLongitude).abs() < 0.0001 &&
          settings.calculationMethod == 18;

      if (!isKairouan) rethrow;

      return _dataSource.getPrayerTimesForDate(date);
    }
  }

  List<PrayerTime> _applyAdjustments(
    List<PrayerTimeModel> raw,
    DateTime date,
    AppSettings settings,
  ) {
    return raw.map((model) {
      final entity = model.toEntity(date);
      final index = model.type.index;
      final minutes = index < settings.adhanAdjustments.length
          ? settings.adhanAdjustments[index]
          : 0;

      if (minutes == 0) return entity;

      return PrayerTime(
        type: entity.type,
        time: entity.time.add(Duration(minutes: minutes)),
      );
    }).toList(growable: false);
  }

  @override
  Future<SyncResult> syncCalendar() async {
    final settings = await _settingsDataSource.getSettings();
    final now = DateTime.now();

    // Current month, next month, and the one after when the month is ending.
    final months = <DateTime>[
      DateTime(now.year, now.month),
      DateTime(now.year, now.month + 1),
      if (now.day >= 20) DateTime(now.year, now.month + 2),
    ];

    var anySaved = false;

    for (final month in months) {
      final calendar = await _remoteDataSource.getMonthCalendar(
        year: month.year,
        month: month.month,
        latitude: settings.latitude,
        longitude: settings.longitude,
        method: settings.calculationMethod,
        timezone: settings.timezone,
      );

      await _cacheDataSource.saveCalendar(
        latitude: settings.latitude,
        longitude: settings.longitude,
        method: settings.calculationMethod,
        calendar: calendar,
      );

      anySaved = true;
    }

    final syncedAt = DateTime.now();

    if (anySaved) {
      await _cacheDataSource.saveLastSync(syncedAt);
    }

    final days = await _cacheDataSource.cachedDaysAhead(
      from: DateTime(now.year, now.month, now.day),
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
    );

    return SyncResult(success: anySaved, syncedAt: syncedAt, daysCached: days);
  }

  @override
  Future<DateTime?> getLastSync() => _cacheDataSource.getLastSync();
}
