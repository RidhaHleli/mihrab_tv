import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/prayer_time.dart';
import '../models/prayer_time_model.dart';

class RemotePrayerTimesDataSource {
  RemotePrayerTimesDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'api.aladhan.com';

  static const Map<PrayerType, String> _apiNames = {
    PrayerType.fajr: 'Fajr',
    PrayerType.sunrise: 'Sunrise',
    PrayerType.dhuhr: 'Dhuhr',
    PrayerType.asr: 'Asr',
    PrayerType.maghrib: 'Maghrib',
    PrayerType.isha: 'Isha',
  };

  Future<List<PrayerTimeModel>> getPrayerTimesForDate({
    required DateTime date,
    required double latitude,
    required double longitude,
    required int method,
    required String timezone,
  }) async {
    final datePath = [
      date.day.toString().padLeft(2, '0'),
      date.month.toString().padLeft(2, '0'),
      date.year.toString(),
    ].join('-');

    final uri = Uri.https(_baseUrl, '/v1/timings/$datePath', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'method': method.toString(),
      'timezonestring': timezone,
    });

    final data = await _getData(uri);

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Missing prayer data.');
    }

    return _parseTimings(data['timings']);
  }

  /// Downloads a whole month in a single request.
  Future<Map<DateTime, List<PrayerTimeModel>>> getMonthCalendar({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
    required int method,
    required String timezone,
  }) async {
    final uri = Uri.https(_baseUrl, '/v1/calendar/$year/$month', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'method': method.toString(),
      'timezonestring': timezone,
    });

    final data = await _getData(uri);

    if (data is! List) {
      throw const FormatException('Missing calendar data.');
    }

    final result = <DateTime, List<PrayerTimeModel>>{};

    for (final entry in data) {
      if (entry is! Map<String, dynamic>) continue;

      final date = entry['date'];
      final gregorian = date is Map<String, dynamic> ? date['gregorian'] : null;
      final dateText = gregorian is Map<String, dynamic>
          ? gregorian['date']
          : null;

      if (dateText is! String) continue;

      // Format: DD-MM-YYYY
      final parts = dateText.split('-');
      if (parts.length != 3) continue;

      final day = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (day == null || m == null || y == null) continue;

      try {
        result[DateTime(y, m, day)] = _parseTimings(entry['timings']);
      } catch (_) {
        // Skip a malformed day, keep the others.
      }
    }

    if (result.isEmpty) {
      throw const FormatException('Empty calendar response.');
    }

    return result;
  }

  Future<dynamic> _getData(Uri uri) async {
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('AlAdhan request failed: HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> || decoded['code'] != 200) {
      throw const FormatException('Invalid AlAdhan API response.');
    }

    return decoded['data'];
  }

  List<PrayerTimeModel> _parseTimings(Object? timings) {
    if (timings is! Map<String, dynamic>) {
      throw const FormatException('Missing prayer timings.');
    }

    return _apiNames.entries.map((entry) {
      final rawValue = timings[entry.value];

      if (rawValue is! String) {
        throw FormatException('Missing ${entry.value} time in response.');
      }

      // AlAdhan may append a timezone label, e.g. "05:12 (EET)".
      final match = RegExp(r'(\d{2}:\d{2})').firstMatch(rawValue);

      if (match == null) {
        throw FormatException('Invalid ${entry.value} time: $rawValue');
      }

      return PrayerTimeModel.fromTimeString(
        type: entry.key,
        value: match.group(1)!,
      );
    }).toList(growable: false);
  }

  void close() {
    _client.close();
  }
}
