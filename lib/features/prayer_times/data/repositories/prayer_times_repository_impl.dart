import 'package:flutter/foundation.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../datasources/local_prayer_times_data_source.dart';
import '../datasources/remote_prayer_times_data_source.dart';
import '../datasources/local_prayer_calendar_cache_data_source.dart';
import '../../../settings/data/datasources/local_settings_data_source.dart';

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

    final latitude = settings.latitude;
    final longitude = settings.longitude;

    debugPrint(
      'MIHRAB LOCATION => ${settings.cityName} | '
      'lat=$latitude | lon=$longitude',
    );

    final cached = await _cacheDataSource.getPrayerTimesForDate(
      date: date,
      latitude: latitude,
      longitude: longitude,
    );

    if (cached != null) {
      return cached.map((model) => model.toEntity(date)).toList();
    }

    try {
      final remote = await _remoteDataSource.getPrayerTimesForDate(
        date: date,
        latitude: latitude,
        longitude: longitude,
      );

      try {
        await _cacheDataSource.saveCalendar(
          latitude: latitude,
          longitude: longitude,
          calendar: {date: remote},
        );
      } catch (_) {
        // A cache failure must not block valid remote results.
      }

      return remote.map((model) => model.toEntity(date)).toList();
    } catch (_) {
      final isKairouan =
          (latitude - _kairouanLatitude).abs() < 0.0001 &&
          (longitude - _kairouanLongitude).abs() < 0.0001;

      if (!isKairouan) rethrow;

      final local = await _dataSource.getPrayerTimesForDate(date);

      return local.map((model) => model.toEntity(date)).toList();
    }
  }
}