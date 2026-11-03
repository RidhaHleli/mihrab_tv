import '../repositories/prayer_times_repository.dart';

class SyncPrayerCalendar {
  const SyncPrayerCalendar(this._repository);

  final PrayerTimesRepository _repository;

  Future<SyncResult> call() => _repository.syncCalendar();

  Future<DateTime?> lastSync() => _repository.getLastSync();
}
