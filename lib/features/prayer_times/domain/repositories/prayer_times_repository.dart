import '../entities/prayer_time.dart';

abstract interface class PrayerTimesRepository {
  Future<List<PrayerTime>> getDailyPrayerTimes(DateTime date);
}
