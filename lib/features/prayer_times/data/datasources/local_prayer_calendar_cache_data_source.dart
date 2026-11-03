import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/prayer_time.dart';
import '../models/prayer_time_model.dart';

class LocalPrayerCalendarCacheDataSource {
  static const String _keyPrefix = 'mihrab_prayer_calendar';

  String _cacheKey({
    required double latitude,
    required double longitude,
  }) {
    final lat = latitude.toStringAsFixed(5);
    final lon = longitude.toStringAsFixed(5);

    return '${_keyPrefix}_${lat}_$lon';
  }

  Future<List<PrayerTimeModel>?> getPrayerTimesForDate({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(
      _cacheKey(latitude: latitude, longitude: longitude),
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
      // Invalid cache is ignored. Existing data is not deleted.
      return null;
    }
  }

  Future<void> saveCalendar({
    required double latitude,
    required double longitude,
    required Map<DateTime, List<PrayerTimeModel>> calendar,
  }) async {
    if (calendar.isEmpty) {
      throw ArgumentError('Cannot save an empty prayer calendar.');
    }

    final prefs = await SharedPreferences.getInstance();

    final key = _cacheKey(
      latitude: latitude,
      longitude: longitude,
    );

    // Read the previous calendar first.
    final previousRaw = prefs.getString(key);

    final Map<String, dynamic> days = {};

    if (previousRaw != null) {
      try {
        final previous = jsonDecode(previousRaw);

        if (previous is Map<String, dynamic> &&
            previous['days'] is Map<String, dynamic>) {
          days.addAll(previous['days'] as Map<String, dynamic>);
        }
      } catch (_) {
        // Keep a clean replacement if the old cache is unreadable.
      }
    }

    // Validate every day before modifying persistent storage.
    final Map<String, dynamic> updates = {};

    for (final entry in calendar.entries) {
      final date = entry.key;
      final prayers = entry.value;

      _validatePrayerTimes(prayers);

      updates[_dateKey(date)] = {
        for (final prayer in prayers)
          prayer.type.name: _formatTime(prayer),
      };
    }

    // Merge and write once. The old calendar remains intact if validation fails.
    days.addAll(updates);

    final payload = jsonEncode({
      'version': 1,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': DateTime.now().toIso8601String(),
      'days': days,
    });

    final saved = await prefs.setString(key, payload);

    if (!saved) {
      throw Exception('Unable to save prayer calendar locally.');
    }
  }

  List<PrayerTimeModel> _parsePrayerTimes(
    Map<String, dynamic> dayData,
  ) {
    return PrayerType.values.map((type) {
      final value = dayData[type.name];

      if (value is! String) {
        throw FormatException('Missing prayer time: ${type.name}');
      }

      return PrayerTimeModel.fromTimeString(
        type: type,
        value: value,
      );
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
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}