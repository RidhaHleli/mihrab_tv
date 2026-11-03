import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/prayer_times/domain/entities/prayer_time.dart';
import '../../features/prayer_times/domain/usecases/get_daily_prayer_times.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../l10n/app_strings.dart';
import 'system_service.dart';

/// Adhan notifications for phones.
///
/// They are scheduled with the Android alarm manager, so they ring on time
/// even when the app is closed or the phone is asleep, and they are restored
/// after a reboot by the plugin's own boot receiver. TVs keep using the
/// in-app player (the app is always open there).
class PrayerNotificationService {
  PrayerNotificationService(this._getDailyPrayerTimes);

  final GetDailyPrayerTimes _getDailyPrayerTimes;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _ready = false;

  /// How many days ahead are scheduled (re-done every time the app opens).
  static const int _daysAhead = 7;

  static const String _channelAdhan = 'adhan_v1';
  static const String _channelFajr = 'adhan_fajr_v1';

  /// Notifications are only used on phones/tablets, never on a TV.
  static Future<bool> isActive(AppSettings settings) async {
    if (!SystemService.isAndroid ||
        !settings.notificationsEnabled ||
        !settings.adhanEnabled) {
      return false;
    }
    return !(await SystemService.isTv());
  }

  static Future<void> _init() async {
    if (_ready || !SystemService.isAndroid) return;

    tzdata.initializeTimeZones();

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_mihrab'),
      ),
    );

    _ready = true;
  }

  static AndroidFlutterLocalNotificationsPlugin? get _android {
    return _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }

  /// Asks for the notification permission (Android 13+) and for exact alarms.
  /// Returns false when notifications are blocked.
  static Future<bool> ensurePermissions() async {
    if (!SystemService.isAndroid) return false;
    await _init();

    final android = _android;
    if (android == null) return false;

    final granted = await android.requestNotificationsPermission() ?? true;

    try {
      if (!(await android.canScheduleExactNotifications() ?? true)) {
        await android.requestExactAlarmsPermission();
      }
    } catch (_) {
      // Exact alarms are a bonus; inexact ones still work.
    }

    return granted;
  }

  static NotificationDetails _details(String lang, {required bool fajr}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        fajr ? _channelFajr : _channelAdhan,
        trFor(lang, 'notif_channel'),
        channelDescription: trFor(lang, 'notif_sub'),
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(
          fajr ? 'adhan_fajr' : 'adhan',
        ),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        visibility: NotificationVisibility.public,
        icon: 'ic_stat_mihrab',
      ),
    );
  }

  /// Replaces every pending notification with the coming prayers.
  Future<void> reschedule(AppSettings settings) async {
    if (!SystemService.isAndroid) return;
    await _init();

    await _plugin.cancelAll();

    if (!await isActive(settings)) return;

    final android = _android;
    final exact = await android?.canScheduleExactNotifications() ?? false;
    final lang = settings.language;
    final body = trFor(lang, 'notif_body');
    final now = DateTime.now();

    var id = 0;

    for (var day = 0; day < _daysAhead; day++) {
      final date = DateTime(now.year, now.month, now.day + day);

      List<PrayerTime> times;
      try {
        times = await _getDailyPrayerTimes(date);
      } catch (_) {
        continue; // Not cached and offline: the next launch will retry.
      }

      for (final prayer in times) {
        if (prayer.type == PrayerType.sunrise) continue;
        if (!prayer.time.isAfter(now)) continue;

        final when = tz.TZDateTime.fromMillisecondsSinceEpoch(
          tz.UTC,
          prayer.time.millisecondsSinceEpoch,
        );

        await _plugin.zonedSchedule(
          id++,
          trFor(lang, prayer.type.name),
          body,
          when,
          _details(lang, fajr: prayer.type == PrayerType.fajr),
          androidScheduleMode: exact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  /// Rings right now, to let the user check the sound and the permission.
  static Future<void> showTest(String lang) async {
    if (!SystemService.isAndroid) return;
    await _init();

    await _plugin.show(
      9999,
      'MIHRAB | محراب',
      trFor(lang, 'notif_body'),
      _details(lang, fajr: false),
    );
  }
}
