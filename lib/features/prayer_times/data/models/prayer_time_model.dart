import '../../domain/entities/prayer_time.dart';

class PrayerTimeModel {
  const PrayerTimeModel({
    required this.type,
    required this.hour,
    required this.minute,
  });

  final PrayerType type;
  final int hour;
  final int minute;

  factory PrayerTimeModel.fromTimeString({
    required PrayerType type,
    required String value,
  }) {
    final match = RegExp(r'^([0-1]\d|2[0-3]):([0-5]\d)$').firstMatch(value);

    if (match == null) {
      throw FormatException('Invalid prayer time: $value');
    }

    return PrayerTimeModel(
      type: type,
      hour: int.parse(match.group(1)!),
      minute: int.parse(match.group(2)!),
    );
  }

  PrayerTime toEntity(DateTime date) {
    return PrayerTime(
      type: type,
      time: DateTime(date.year, date.month, date.day, hour, minute),
    );
  }
}
