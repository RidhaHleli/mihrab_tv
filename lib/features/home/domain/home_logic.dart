import '../../../core/utils/hijri_date.dart';
import '../../prayer_times/domain/entities/prayer_time.dart';

// ---------------------------------------------------------------------------
// Prayer phase (iqama countdown / prayer in progress)
// ---------------------------------------------------------------------------

enum PrayerPhaseKind { normal, iqamaCountdown, prayerInProgress }

class PrayerPhase {
  const PrayerPhase._(this.kind, this.prayer, this.remaining, this.isJumuah);

  const PrayerPhase.normal() : this._(PrayerPhaseKind.normal, null, null, false);

  final PrayerPhaseKind kind;
  final PrayerType? prayer;

  /// Time left before the iqama (countdown) or before the end of the prayer.
  final Duration? remaining;
  final bool isJumuah;

  bool get isActive => kind != PrayerPhaseKind.normal;
}

abstract final class PrayerPhaseResolver {
  /// How long the "prayer in progress" screen stays up after the iqama.
  static const int prayerMinutes = 10;
  static const int jumuahPrayerMinutes = 20;

  static PrayerPhase resolve({
    required DateTime now,
    required List<PrayerTime> today,
    required List<int> iqamaDelays,
    required int jumuahDelayMinutes,
    required bool iqamaEnabled,
  }) {
    if (!iqamaEnabled) return const PrayerPhase.normal();

    final isFriday = now.weekday == DateTime.friday;

    for (final prayer in today) {
      if (prayer.type == PrayerType.sunrise) continue;

      final isJumuah = isFriday && prayer.type == PrayerType.dhuhr;
      final delay = isJumuah
          ? jumuahDelayMinutes
          : (prayer.type.index < iqamaDelays.length
                ? iqamaDelays[prayer.type.index]
                : 10);

      final iqama = prayer.time.add(Duration(minutes: delay));
      final end = iqama.add(
        Duration(minutes: isJumuah ? jumuahPrayerMinutes : prayerMinutes),
      );

      if (!now.isBefore(prayer.time) && now.isBefore(iqama)) {
        return PrayerPhase._(
          PrayerPhaseKind.iqamaCountdown,
          prayer.type,
          iqama.difference(now),
          isJumuah,
        );
      }

      if (!now.isBefore(iqama) && now.isBefore(end)) {
        return PrayerPhase._(
          PrayerPhaseKind.prayerInProgress,
          prayer.type,
          end.difference(now),
          isJumuah,
        );
      }
    }

    return const PrayerPhase.normal();
  }
}

// ---------------------------------------------------------------------------
// Night mode
// ---------------------------------------------------------------------------

abstract final class NightModeResolver {
  static const int afterIshaMinutes = 45;
  static const int beforeFajrMinutes = 30;

  /// True from [afterIshaMinutes] after Isha until [beforeFajrMinutes]
  /// before Fajr.
  static bool isNight({
    required DateTime now,
    required List<PrayerTime> today,
  }) {
    DateTime? fajr;
    DateTime? isha;

    for (final prayer in today) {
      if (prayer.type == PrayerType.fajr) fajr = prayer.time;
      if (prayer.type == PrayerType.isha) isha = prayer.time;
    }

    if (fajr == null || isha == null) return false;

    final nightStart = isha.add(const Duration(minutes: afterIshaMinutes));
    final nightEnd = fajr.subtract(const Duration(minutes: beforeFajrMinutes));

    return !now.isBefore(nightStart) || now.isBefore(nightEnd);
  }
}

// ---------------------------------------------------------------------------
// Ramadan
// ---------------------------------------------------------------------------

enum RamadanStage { untilImsak, fasting, afterIftar, taraweeh }

class RamadanInfo {
  const RamadanInfo({
    required this.stage,
    required this.imsak,
    required this.iftar,
    this.remaining,
  });

  final RamadanStage stage;
  final DateTime imsak;
  final DateTime iftar;

  /// Countdown to imsak (untilImsak) or iftar (fasting).
  final Duration? remaining;
}

abstract final class RamadanResolver {
  static const int taraweehMinutes = 100;

  static bool isRamadan({
    required DateTime now,
    required String mode,
    required int hijriAdjustment,
  }) {
    switch (mode) {
      case 'on':
        return true;
      case 'off':
        return false;
      default:
        return HijriDate.fromGregorian(now, adjustment: hijriAdjustment)
                .month ==
            HijriDate.ramadan;
    }
  }

  static RamadanInfo? resolve({
    required DateTime now,
    required List<PrayerTime> today,
    required int imsakMinutes,
  }) {
    DateTime? fajr;
    DateTime? maghrib;
    DateTime? isha;

    for (final prayer in today) {
      if (prayer.type == PrayerType.fajr) fajr = prayer.time;
      if (prayer.type == PrayerType.maghrib) maghrib = prayer.time;
      if (prayer.type == PrayerType.isha) isha = prayer.time;
    }

    if (fajr == null || maghrib == null || isha == null) return null;

    final imsak = fajr.subtract(Duration(minutes: imsakMinutes));

    if (now.isBefore(imsak)) {
      return RamadanInfo(
        stage: RamadanStage.untilImsak,
        imsak: imsak,
        iftar: maghrib,
        remaining: imsak.difference(now),
      );
    }

    if (now.isBefore(maghrib)) {
      return RamadanInfo(
        stage: RamadanStage.fasting,
        imsak: imsak,
        iftar: maghrib,
        remaining: maghrib.difference(now),
      );
    }

    final taraweehEnd = isha.add(const Duration(minutes: taraweehMinutes));

    return RamadanInfo(
      stage: !now.isBefore(isha) && now.isBefore(taraweehEnd)
          ? RamadanStage.taraweeh
          : RamadanStage.afterIftar,
      imsak: imsak,
      iftar: maghrib,
    );
  }
}
