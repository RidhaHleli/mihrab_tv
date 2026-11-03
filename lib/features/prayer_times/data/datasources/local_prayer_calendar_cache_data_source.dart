import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/prayer_time.dart';
import '../models/prayer_time_model.dart';

/// Stores raw (un-adjusted) prayer times per day, per place and per method.
class LocalPrayerCalendarCacheDataSource {
  static const String _keyPrefix = 'mihrab_prayer_calendar_v2';
  static const String _lastSyncKey = 'mihrab_last_sync_ms';

  /// Days older than this are dropped when saving, to keep storage small.
  static const int _keepPastDays = 3;

  String _cacheKey({
    required double latitude,
    required double longitude,
    required int method,
  }) {
    final lat = latitude.toStringAsFixed(4);
    final lon = longitude.toStringAsFixed(4);

    return '${_keyPrefix}_${lat}_${lon}_m$method';
  }

  Future<List<PrayerTimeModel>?> getPrayerTimesForDate({
    required DateTime date,
    required double latitude,
    required double longitude,
    required int method,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(
      _cacheKey(latitude: latitude, longitude: longitude, method: method),
    );

    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final days = decoded['days'];
      if (days is! Map<String, dynamic>) return null;

      final dayData = days[_dateKey(date)];
      if (dayData is! Map<String, dynamic>) return null;

      return _parsePrayerTimes(dayData);
    } catch (_) {
      return null;
    }
  }

  /// Number of future days (from [from]) already cached.
  Future<int> cachedDaysAhead({
    required DateTime from,
    required double latitude,
    required double longitude,
    required int method,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
      _cacheKey(latitude: latitude, longitude: longitude, method: method),
    );
    if (raw == null) return 0;

    try {
      final decoded = jsonDecode(raw);
      final days = decoded is Map<String, dynamic> ? decoded['days'] : null;
      if (days is! Map<String, dynamic>) return 0;

      var count = 0;
      for (var i = 0; i < 90; i++) {
        final date = DateTime(from.year, from.month, from.day + i);
        if (!days.containsKey(_dateKey(date))) break;
        count++;
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  Future<void> saveCalendar({
    required double latitude,
    required double longitude,
    required int method,
    required Map<DateTime, List<PrayerTimeModel>> calendar,
  }) async {
    if (calendar.isEmpty) {
      throw ArgumentError('Cannot save an empty prayer calendar.');
    }

    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(
      latitude: latitude,
      longitude: longitude,
      method: method,
    );

    final Map<String, dynamic> days = {};
    final previousRaw = prefs.getString(key);

    if (previousRaw != null) {
      try {
        final previous = jsonDecode(previousRaw);
        if (previous is Map<String, dynamic> &&
            previous['days'] is Map<String, dynamic>) {
          days.addAll(previous['days'] as Map<String, dynamic>);
        }
      } catch (_) {
        // Unreadable old cache: start clean.
      }
    }

    final Map<String, dynamic> updates = {};

    for (final entry in calendar.entries) {
      _validatePrayerTimes(entry.value);

      updates[_dateKey(entry.key)] = {
        for (final prayer in entry.value) prayer.type.name: _formatTime(prayer),
      };
    }

    days.addAll(updates);

    // Drop old days.
    final now = DateTime.now();
    final limit = _dateKey(
      DateTime(now.year, now.month, now.day - _keepPastDays),
    );
    days.removeWhere((dayKey, _) => dayKey.compareTo(limit) < 0);

    final payload = jsonEncode({
      'version': 2,
      'latitude': latitude,
      'longitude': longitude,
      'method': method,
      'updatedAt': DateTime.now().toIso8601String(),
      'days': days,
    });

    final saved = await prefs.setString(key, payload);
    if (!saved) {
      throw Exception('Unable to save prayer calendar locally.');
    }
  }

  Future<void> saveLastSync(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_lastSyncKey);
    return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
  }

  List<PrayerTimeModel> _parsePrayerTimes(Map<String, dynamic> dayData) {
    return PrayerType.values.map((type) {
      final value = dayData[type.name];

      if (value is! String) {
        throw FormatException('Missing prayer time: ${type.name}');
      }

      return PrayerTimeModel.fromTimeString(type: type, value: value);
    }).toList(growable: false);
  }

  void _validatePrayerTimes(List<PrayerTimeModel> prayers) {
    final types = prayers.map((prayer) => prayer.type).toSet();

    if (types.length != PrayerType.values.length ||
        !PrayerType.values.every(types.contains)) {
      throw const FormatException(
        'A calendar day must contain all six prayer times exactly once.',
      );
    }
  }

  String _formatTime(PrayerTimeModel prayer) {
    return '${prayer.hour.toString().padLeft(2, '0')}:'
        '${prayer.minute.toString().padLeft(2, '0')}';
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}
