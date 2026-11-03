enum PrayerType { fajr, sunrise, dhuhr, asr, maghrib, isha }

class PrayerTime {
  const PrayerTime({required this.type, required this.time});

  final PrayerType type;
  final DateTime time;
}
