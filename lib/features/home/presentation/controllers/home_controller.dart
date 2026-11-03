import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../prayer_times/domain/entities/prayer_time.dart';
import '../../../prayer_times/domain/usecases/get_daily_prayer_times.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._getDailyPrayerTimes) {
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _handleTick(),
    );
  }

  final GetDailyPrayerTimes _getDailyPrayerTimes;

  /// Called once, at the moment a prayer (except sunrise) becomes due.
  void Function(PrayerTime prayer)? onPrayerTime;

  static const Duration _triggerWindow = Duration(seconds: 15);
  final Set<String> _triggeredPrayers = <String>{};

  late final Timer _ticker;

  List<PrayerTime> _todayPrayerTimes = [];
  List<PrayerTime> _tomorrowPrayerTimes = [];

  DateTime _now = DateTime.now();
  DateTime? _loadedDate;

  bool _isLoading = false;
  bool _disposed = false;
  bool _reloadRequested = false;

  String? _errorMessage;

  List<PrayerTime> get todayPrayerTimes => _todayPrayerTimes;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  DateTime get now => _now;

  Future<void> load() async {
    if (_isLoading || _disposed) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final currentDate = DateTime.now();
    final today = _dateOnly(currentDate);
    final tomorrow = today.add(const Duration(days: 1));

    try {
      final results = await Future.wait([
        _getDailyPrayerTimes(today),
        _getDailyPrayerTimes(tomorrow),
      ]);

      if (_disposed) return;

      _todayPrayerTimes = results[0];
      _tomorrowPrayerTimes = results[1];
      _loadedDate = today;
      _now = DateTime.now();
    } catch (_) {
      if (_disposed) return;

      _errorMessage = 'Unable to load prayer times.';
      _todayPrayerTimes = [];
      _tomorrowPrayerTimes = [];
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();

        if (_reloadRequested) {
          _reloadRequested = false;
          unawaited(reload());
        }
      }
    }
  }

  /// Reloads prayer times after the selected location changes.
  Future<void> reload() async {
    if (_disposed) return;

    _loadedDate = null;

    if (_isLoading) {
      _reloadRequested = true;
      return;
    }

    await load();
  }

  PrayerTime? get nextPrayer {
    final upcomingToday = _todayPrayerTimes.where((prayer) {
      return prayer.type != PrayerType.sunrise &&
          !prayer.time.isBefore(_now);
    }).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    if (upcomingToday.isNotEmpty) {
      return upcomingToday.first;
    }

    for (final prayer in _tomorrowPrayerTimes) {
      if (prayer.type == PrayerType.fajr) {
        return prayer;
      }
    }

    return null;
  }

  Duration? get timeUntilNextPrayer {
    final next = nextPrayer;
    if (next == null) return null;

    final difference = next.time.difference(_now);
    return difference.isNegative ? Duration.zero : difference;
  }

  void _handleTick() {
    if (_disposed) return;

    _now = DateTime.now();

    final today = _dateOnly(_now);

    if (_loadedDate == null || !_isSameDay(_loadedDate!, today)) {
      unawaited(load());
      return;
    }

    _checkPrayerTrigger();
    notifyListeners();
  }

  void _checkPrayerTrigger() {
    final callback = onPrayerTime;
    if (callback == null) return;

    for (final prayer in _todayPrayerTimes) {
      if (prayer.type == PrayerType.sunrise) continue;

      final elapsed = _now.difference(prayer.time);
      if (elapsed.isNegative || elapsed > _triggerWindow) continue;

      final key = '${prayer.time.year}-${prayer.time.month}-'
          '${prayer.time.day}-${prayer.type.name}';

      if (_triggeredPrayers.add(key)) {
        callback(prayer);
      }
    }
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker.cancel();
    super.dispose();
  }
}