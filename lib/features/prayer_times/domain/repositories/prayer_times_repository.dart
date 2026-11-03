import '../entities/prayer_time.dart';

/// Result of a calendar synchronisation attempt.
class SyncResult {
  const SyncResult({required this.success, this.syncedAt, this.daysCached = 0});

  final bool success;
  final DateTime? syncedAt;
  final int daysCached;
}

abstract interface class PrayerTimesRepository {
  /// Prayer times for [date] with the user's minute adjustments applied.
  Future<List<PrayerTime>> getDailyPrayerTimes(DateTime date);

  /// Downloads the current and next months so the app keeps working offline.
  Future<SyncResult> syncCalendar();

  Future<DateTime?> getLastSync();
}
