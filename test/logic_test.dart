import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_tv/core/data/daily_reminders.dart';
import 'package:mihrab_tv/core/l10n/app_strings.dart';
import 'package:mihrab_tv/core/utils/hijri_date.dart';
import 'package:mihrab_tv/features/home/domain/home_logic.dart';
import 'package:mihrab_tv/features/prayer_times/domain/entities/prayer_time.dart';
import 'package:mihrab_tv/features/settings/domain/entities/app_settings.dart';

/// Prayer times of one day (Wednesday 4 November 2026 or Friday 6th).
List<PrayerTime> _day(int day) {
  PrayerTime at(PrayerType type, int h, int m) =>
      PrayerTime(type: type, time: DateTime(2026, 11, day, h, m));

  return [
    at(PrayerType.fajr, 5, 0),
    at(PrayerType.sunrise, 6, 20),
    at(PrayerType.dhuhr, 12, 0),
    at(PrayerType.asr, 15, 0),
    at(PrayerType.maghrib, 17, 0),
    at(PrayerType.isha, 19, 30),
  ];
}

const _delays = [20, 0, 15, 10, 5, 15];

PrayerPhase _phase(DateTime now, {bool enabled = true, int jumuah = 30}) {
  return PrayerPhaseResolver.resolve(
    now: now,
    today: _day(now.day),
    iqamaDelays: _delays,
    jumuahDelayMinutes: jumuah,
    iqamaEnabled: enabled,
  );
}

void main() {
  group('PrayerPhaseResolver', () {
    test('counts down to the iqama after the adhan', () {
      final phase = _phase(DateTime(2026, 11, 4, 12, 5));

      expect(phase.kind, PrayerPhaseKind.iqamaCountdown);
      expect(phase.prayer, PrayerType.dhuhr);
      expect(phase.remaining, const Duration(minutes: 10));
      expect(phase.isJumuah, isFalse);
    });

    test('shows "prayer in progress" after the iqama, then goes back', () {
      expect(
        _phase(DateTime(2026, 11, 4, 12, 16)).kind,
        PrayerPhaseKind.prayerInProgress,
      );
      expect(_phase(DateTime(2026, 11, 4, 12, 30)).kind, PrayerPhaseKind.normal);
    });

    test('uses the Jumu\'a delay on Friday', () {
      final countdown = _phase(DateTime(2026, 11, 6, 12, 10));

      expect(countdown.kind, PrayerPhaseKind.iqamaCountdown);
      expect(countdown.isJumuah, isTrue);
      expect(countdown.remaining, const Duration(minutes: 20));

      // The Friday prayer lasts longer.
      expect(
        _phase(DateTime(2026, 11, 6, 12, 45)).kind,
        PrayerPhaseKind.prayerInProgress,
      );
    });

    test('does nothing when the iqama screen is disabled', () {
      expect(
        _phase(DateTime(2026, 11, 4, 12, 5), enabled: false).kind,
        PrayerPhaseKind.normal,
      );
    });

    test('ignores sunrise', () {
      expect(_phase(DateTime(2026, 11, 4, 6, 21)).kind, PrayerPhaseKind.normal);
    });
  });

  group('NightModeResolver', () {
    bool night(int h, int m) => NightModeResolver.isNight(
      now: DateTime(2026, 11, 4, h, m),
      today: _day(4),
    );

    test('starts 45 minutes after Isha', () {
      expect(night(20, 14), isFalse);
      expect(night(20, 15), isTrue);
    });

    test('ends 30 minutes before Fajr', () {
      expect(night(4, 29), isTrue);
      expect(night(4, 30), isFalse);
    });

    test('is off during the day', () {
      expect(night(13, 0), isFalse);
    });
  });

  group('RamadanResolver', () {
    RamadanInfo? info(int h, int m) => RamadanResolver.resolve(
      now: DateTime(2026, 11, 4, h, m),
      today: _day(4),
      imsakMinutes: 10,
    );

    test('follows the day: imsak, fasting, iftar, taraweeh', () {
      final before = info(4, 0)!;
      expect(before.stage, RamadanStage.untilImsak);
      expect(before.remaining, const Duration(minutes: 50));

      final fasting = info(12, 0)!;
      expect(fasting.stage, RamadanStage.fasting);
      expect(fasting.remaining, const Duration(hours: 5));

      expect(info(18, 0)!.stage, RamadanStage.afterIftar);
      expect(info(19, 45)!.stage, RamadanStage.taraweeh);
    });

    test('mode on / off / auto', () {
      final inRamadan = DateTime(2025, 3, 15);
      final outside = DateTime(2025, 6, 15);

      bool is_(String mode, DateTime d) => RamadanResolver.isRamadan(
        now: d,
        mode: mode,
        hijriAdjustment: 0,
      );

      expect(is_('on', outside), isTrue);
      expect(is_('off', inRamadan), isFalse);
      expect(is_('auto', inRamadan), isTrue);
      expect(is_('auto', outside), isFalse);
    });
  });

  group('HijriDate', () {
    test('March 2025 falls in Ramadan 1446', () {
      final hijri = HijriDate.fromGregorian(DateTime(2025, 3, 15));

      expect(hijri.year, 1446);
      expect(hijri.month, HijriDate.ramadan);
    });

    test('the correction moves the date by whole days', () {
      final base = HijriDate.fromGregorian(DateTime(2025, 3, 15));
      final next = HijriDate.fromGregorian(DateTime(2025, 3, 15), adjustment: 1);

      expect(next.day, base.day + 1);
    });
  });

  group('AppSettings remote control', () {
    test('clamps and validates what the phone sends', () {
      final updated = const AppSettings().applyRemoteJson({
        'volume': 5,
        'language': 'xx',
        'themeId': 'makkah',
        'adhanAdjustments': [99, -99, 0, 0, 0, 0],
        'iqamaDelays': [1, 2, 3],
        'calculationMethod': 999,
        'announcements': ['  Salam  ', '', 42, 'x' * 500],
        'imsakMinutes': 100,
      });

      expect(updated.volume, 1.0);
      expect(updated.language, 'ar', reason: 'invalid language is ignored');
      expect(updated.themeId, 'makkah');
      expect(updated.adhanAdjustments, [30, -30, 0, 0, 0, 0]);
      expect(updated.iqamaDelays, const AppSettings().iqamaDelays);
      expect(updated.calculationMethod, 18);
      expect(updated.announcements.first, 'Salam');
      expect(updated.announcements.length, 2);
      expect(updated.announcements.last.length, 200);
      expect(updated.imsakMinutes, 30);
    });

    test('never exposes the pairing token', () {
      final json = const AppSettings(remoteToken: '123456').toRemoteJson();

      expect(json.containsKey('remoteToken'), isFalse);
    });

    test('detects changes that need a reload of the prayer times', () {
      const base = AppSettings();

      expect(base.timesDifferFrom(base.copyWith(volume: 0.1)), isFalse);
      expect(base.timesDifferFrom(base.copyWith(calculationMethod: 3)), isTrue);
      expect(
        base.timesDifferFrom(base.copyWith(adhanAdjustments: [1, 0, 0, 0, 0, 0])),
        isTrue,
      );
    });
  });

  group('Translations and reminders', () {
    test('translates the prayer names', () {
      expect(trFor('ar', 'fajr'), 'الفجر');
      expect(trFor('fr', 'fajr'), 'Fajr');
      expect(trFor('en', 'sunrise'), 'Sunrise');
    });

    test('replaces placeholders and falls back to the key', () {
      expect(
        trFor('fr', 'adhan_now', args: {'p': 'Dhuhr'}),
        contains('Dhuhr'),
      );
      expect(trFor('en', 'does_not_exist'), 'does_not_exist');
    });

    test('every reminder has a text and a source in the 3 languages', () {
      for (final kind in ReminderKind.values) {
        for (final reminder in DailyReminders.of(kind)) {
          expect(reminder.text.length, 3);
          expect(reminder.source.length, 3);
          expect(reminder.text.every((e) => e.trim().isNotEmpty), isTrue);
        }
      }
    });

    test('the daily reminder is stable during the day', () {
      final a = DailyReminders.forDay(ReminderKind.verse, DateTime(2026, 11, 4, 8));
      final b = DailyReminders.forDay(ReminderKind.verse, DateTime(2026, 11, 4, 22));

      expect(identical(a, b), isTrue);
    });
  });
}
