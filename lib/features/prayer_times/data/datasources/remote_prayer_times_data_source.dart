import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/prayer_time.dart';
import '../models/prayer_time_model.dart';

class RemotePrayerTimesDataSource {
  RemotePrayerTimesDataSource({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'api.aladhan.com';
  static const int _calculationMethod = 18;
  static const String _timeZone = 'Africa/Tunis';

  Future<List<PrayerTimeModel>> getPrayerTimesForDate({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) async {
    final datePath = [
      date.day.toString().padLeft(2, '0'),
      date.month.toString().padLeft(2, '0'),
      date.year.toString(),
    ].join('-');

    final uri = Uri.https(
      _baseUrl,
      '/v1/timings/$datePath',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'method': _calculationMethod.toString(),
        'timezonestring': _timeZone,
      },
    );

    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'AlAdhan request failed: HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> || decoded['code'] != 200) {
      throw const FormatException('Invalid AlAdhan API response.');
    }

    final data = decoded['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Missing prayer data.');
    }

    final timings = data['timings'];

    if (timings is! Map<String, dynamic>) {
      throw const FormatException('Missing prayer timings.');
    }

    const apiNames = {
      PrayerType.fajr: 'Fajr',
      PrayerType.sunrise: 'Sunrise',
      PrayerType.dhuhr: 'Dhuhr',
      PrayerType.asr: 'Asr',
      PrayerType.maghrib: 'Maghrib',
      PrayerType.isha: 'Isha',
    };

    return apiNames.entries.map((entry) {
      final rawValue = timings[entry.value];

      if (rawValue is! String) {
        throw FormatException(
          'Missing ${entry.value} time in AlAdhan response.',
        );
      }

      // AlAdhan may append a timezone label, e.g. "05:12 (EET)".
      final match = RegExp(r'(\d{2}:\d{2})').firstMatch(rawValue);

      if (match == null) {
        throw FormatException(
          'Invalid ${entry.value} time: $rawValue',
        );
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