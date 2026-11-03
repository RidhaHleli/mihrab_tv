import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/prayer_time.dart';
import '../models/prayer_time_model.dart';

class LocalPrayerTimesDataSource {
  LocalPrayerTimesDataSource({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  static const String _assetPath = 'assets/data/prayer_times.json';

  Future<List<PrayerTimeModel>> getPrayerTimesForDate(DateTime date) async {
    final jsonString = await _assetBundle.loadString(_assetPath);

    final Map<String, dynamic> data =
        jsonDecode(jsonString) as Map<String, dynamic>;

    final days = data['days'];

    if (days is! List) {
      throw const FormatException(
        'Invalid prayer timetable: days must be a list.',
      );
    }

    final dateKey = _formatDate(date);

    final dayData = days.cast<Map<String, dynamic>?>().firstWhere(
      (day) => day?['date'] == dateKey,
      orElse: () => null,
    );

    if (dayData == null) {
      return [];
    }

    final prayers = dayData['prayers'];

    if (prayers is! Map<String, dynamic>) {
      throw const FormatException('Invalid prayer timetable: missing prayers.');
    }

    return PrayerType.values.map((type) {
      final value = prayers[type.name];

      if (value is! String) {
        throw FormatException('Missing prayer time: ${type.name}');
      }

      return PrayerTimeModel.fromTimeString(type: type, value: value);
    }).toList();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
