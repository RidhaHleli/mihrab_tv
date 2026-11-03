import '../entities/prayer_time.dart';
import '../repositories/prayer_times_repository.dart';

class GetDailyPrayerTimes {
  const GetDailyPrayerTimes(this._repository);

  final PrayerTimesRepository _repository;

  Future<List<PrayerTime>> call(DateTime date) {
    return _repository.getDailyPrayerTimes(date);
  }
}
