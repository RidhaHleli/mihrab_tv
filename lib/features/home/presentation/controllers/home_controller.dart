import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../prayer_times/domain/entities/prayer_time.dart';
import '../../../prayer_times/domain/usecases/get_daily_prayer_times.dart';
import '../../../prayer_times/domain/usecases/sync_prayer_calendar.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._getDailyPrayerTimes, this._syncPrayerCalendar) {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _handleTick());
    unawaited(_restoreLastSync());
  }

  final GetDailyPrayerTimes _getDailyPrayerTimes;
  final SyncPrayerCalendar _syncPrayerCalendar;

  /// Called once, at the moment a prayer (except sunrise) becomes due.
  void Function(PrayerTime prayer)? onPrayerTime;

  static const Duration _triggerWindow = Duration(seconds: 15);

  static const Duration _loadRetryStart = Duration(seconds: 15);
  static const Duration _loadRetryMax = Duration(minutes: 10);
  static const Duration _syncRetryStart = Duration(minutes: 1);
  static const Duration _syncRetryMax = Duration(minutes: 30);
  static const Duration _syncInterval = Duration(hours: 6);

  final Set<String> _triggeredPrayers = <String>{};

  late final Timer _ticker;

  List<PrayerTime> _todayPrayerTimes = [];
  List<PrayerTime> _tomorrowPrayerTimes = [];

  DateTime _now = DateTime.now();
  DateTime? _loadedDate;

  bool _isLoading = false;
  bool _disposed = false;
  bool _reloadRequested = false;

  Duration _loadRetry = _loadRetryStart;
  DateTime _nextLoadAttempt = DateTime.fromMillisecondsSinceEpoch(0);

  bool _isSyncing = false;
  Duration _syncRetry = _syncRetryStart;
  DateTime _nextSync = DateTime.now().add(const Duration(seconds: 4));

  DateTime? _lastSync;
  bool _isOnline = true;

  String? _errorMessage;

  List<PrayerTime> get todayPrayerTimes => _todayPrayerTimes;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  DateTime get now => _now;

  /// Last successful download of the prayer calendar.
  DateTime? get lastSync => _lastSync;

  /// False when the last synchronisation attempt failed (no network).
  bool get isOnline => _isOnline;

  bool get isSyncing => _isSyncing;

  Future<void> _restoreLastSync() async {
    try {
      _lastSync = await _syncPrayerCalendar.lastSync();
      if (!_disposed) notifyListeners();
    } catch (_) {
      // Ignore: the indicator simply shows "not synced yet".
    }
  }

  Future<void> load({bool clearOnError = false}) async {
    if (_isLoading || _disposed) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final today = _dateOnly(DateTime.now());
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
      _loadRetry = _loadRetryStart;
    } catch (_) {
      if (_disposed) return;

      _errorMessage = 'load_error';

      if (clearOnError || _todayPrayerTimes.isEmpty) {
        _todayPrayerTimes = [];
        _tomorrowPrayerTimes = [];
      }

      // Back off instead of retrying every second.
      _nextLoadAttempt = DateTime.now().add(_loadRetry);
      _loadRetry = _doubled(_loadRetry, _loadRetryMax);
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

  /// Reloads prayer times after the location, method or adjustments change.
  Future<void> reload() async {
    if (_disposed) return;

    _loadedDate = null;
    _loadRetry = _loadRetryStart;
    _nextLoadAttempt = DateTime.fromMillisecondsSinceEpoch(0);

    // New place or method => download the new calendar as soon as possible.
    _syncRetry = _syncRetryStart;
    _nextSync = DateTime.now();

    if (_isLoading) {
      _reloadRequested = true;
      return;
    }

    await load(clearOnError: true);
  }

  /// Forces a synchronisation now (used by the settings screen).
  Future<void> syncNow() async {
    _nextSync = DateTime.now();
    await _runSync();
  }

  Future<void> _runSync() async {
    if (_isSyncing || _disposed) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final result = await _syncPrayerCalendar();

      if (_disposed) return;

      if (result.success) {
        _lastSync = result.syncedAt;
        _isOnline = true;
        _syncRetry = _syncRetryStart;
        _nextSync = DateTime.now().add(_syncInterval);

        // Make sure the screen shows the freshly downloaded data.
        if (_todayPrayerTimes.isEmpty || _errorMessage != null) {
          _loadedDate = null;
          _nextLoadAttempt = DateTime.fromMillisecondsSinceEpoch(0);
        }
      } else {
        _markSyncFailure();
      }
    } catch (_) {
      if (_disposed) return;
      _markSyncFailure();
    } finally {
      if (!_disposed) {
        _isSyncing = false;
        notifyListeners();
      }
    }
  }

  void _markSyncFailure() {
    _isOnline = false;
    _nextSync = DateTime.now().add(_syncRetry);
    _syncRetry = _doubled(_syncRetry, _syncRetryMax);
  }

  Duration _doubled(Duration value, Duration max) {
    final next = value * 2;
    return next > max ? max : next;
  }

  PrayerTime? get nextPrayer {
    final upcomingToday = _todayPrayerTimes.where((prayer) {
      return prayer.type != PrayerType.sunrise && !prayer.time.isBefore(_now);
    }).toList()..sort((a, b) => a.time.compareTo(b.time));

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
    final needsLoad = _loadedDate == null || !_isSameDay(_loadedDate!, today);

    if (needsLoad && !_isLoading && !_now.isBefore(_nextLoadAttempt)) {
      unawaited(load());
    }

    if (!_isSyncing && !_isLoading && !_now.isBefore(_nextSync)) {
      unawaited(_runSync());
    }

    if (!needsLoad) {
      _checkPrayerTrigger();
    }

    notifyListeners();
  }

  void _checkPrayerTrigger() {
    final callback = onPrayerTime;
    if (callback == null) return;

    for (final prayer in _todayPrayerTimes) {
      if (prayer.type == PrayerType.sunrise) continue;

      final elapsed = _now.difference(prayer.time);
      if (elapsed.isNegative || elapsed > _triggerWindow) continue;

      final key =
          '${prayer.time.year}-${prayer.time.month}-'
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
