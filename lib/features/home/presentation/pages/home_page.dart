import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/daily_reminders.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/events/app_events.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/remote/remote_control_service.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/adhan_player_service.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/theme/themed_background.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/hijri_date.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../prayer_times/domain/entities/prayer_time.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/home_logic.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/home_overlays.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/info_strips.dart';
import '../widgets/prayer_hero_section.dart';
import '../widgets/prayer_schedule_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  late final SettingsController _settingsController;
  late final AdhanPlayerService _adhan;

  PrayerType? _adhanPrayer;

  /// Overlay already closed by the user (so it does not come back).
  String? _dismissedOverlay;

  /// The night screen stays off until this moment after a key press.
  DateTime _nightWakeUntil = DateTime.fromMillisecondsSinceEpoch(0);

  static const Duration _nightWake = Duration(minutes: 2);
  static const Duration _reminderRotation = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _controller = InjectionContainer.createHomeController();
    _settingsController = InjectionContainer.createSettingsController();
    _adhan = InjectionContainer.createAdhanPlayerService();

    _controller.onPrayerTime = _handlePrayerTime;
    AppEvents.settingsChanged.addListener(_onSettingsEvent);

    _controller.load();
    unawaited(_initialSettings());
  }

  @override
  void dispose() {
    AppEvents.settingsChanged.removeListener(_onSettingsEvent);
    _controller.onPrayerTime = null;
    _controller.dispose();
    _settingsController.dispose();
    _adhan.dispose();

    super.dispose();
  }

  Future<void> _initialSettings() async {
    await _settingsController.loadSettings();
    if (!mounted) return;
    unawaited(RemoteControlService.instance.apply(_settingsController.settings));
  }

  /// Settings changed from the phone remote control.
  void _onSettingsEvent() {
    unawaited(_refreshSettings());
  }

  /// Reloads the settings and only reloads the prayer times when something
  /// that affects them (place, method, adjustments) has really changed.
  Future<void> _refreshSettings() async {
    final before = _settingsController.settings;
    await _settingsController.loadSettings();
    if (!mounted) return;

    final after = _settingsController.settings;

    if (after.timesDifferFrom(before)) {
      await _controller.reload();
    }

    unawaited(RemoteControlService.instance.apply(after));
  }

  void _handlePrayerTime(PrayerTime prayer) {
    final settings = _settingsController.settings;
    if (!settings.adhanEnabled) return;

    _adhanPrayer = prayer.type;

    _adhan.play(
      isFajr: prayer.type == PrayerType.fajr,
      volume: settings.volume,
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));

    if (!mounted) return;

    await _refreshSettings();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(child: _buildContent());
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _settingsController,
        _adhan.isPlaying,
      ]),
      builder: (context, child) {
        final r = Responsive.of(context);
        final settings = _settingsController.settings;
        final now = _controller.now;
        final today = _controller.todayPrayerTimes;
        final nextPrayer = _controller.nextPrayer;
        final lang = context.languageCode;
        final prayers = _buildPrayerItems(context, nextPrayer);

        final header = HomeTopBar(
          mosqueName: settings.displayName.trim().isEmpty
              ? AppConstants.defaultMosqueName
              : settings.displayName,
          location: _locationText(context, settings),
          onSettingsPressed: _openSettings,
        );

        final hero = PrayerHeroSection(
          prayerName: nextPrayer == null
              ? context.tr('unavailable')
              : context.tr(nextPrayer.type.name),
          prayerTime: nextPrayer == null
              ? '--:--'
              : DateTimeUtils.formatTime(nextPrayer.time),
          remainingTime: DateTimeUtils.countdown(
            _controller.timeUntilNextPrayer,
          ),
          currentTime: DateTimeUtils.formatTime(now),
          date: _formatDate(now, lang),
          hijriDate: _formatHijri(now, settings, lang),
        );

        final bottom = _buildBottomInfo(context, settings, now, today);

        final content = Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: r.isWide
                ? _WideLayout(
                    r: r,
                    header: header,
                    hero: hero,
                    schedule: PrayerScheduleGrid(
                      prayers: prayers,
                      fillHeight: true,
                    ),
                    banner: bottom,
                    footer: _footer(),
                  )
                : _StackedLayout(
                    r: r,
                    header: header,
                    hero: hero,
                    schedule: PrayerScheduleGrid(prayers: prayers),
                    banner: bottom,
                    footer: _footer(),
                  ),
          ),
        );

        final overlay = _buildOverlay(context, settings, now, today);

        if (overlay == null) return content;

        return Stack(
          children: [content, Positioned.fill(child: overlay)],
        );
      },
    );
  }

  Widget _footer() {
    return HomeBottomBar(
      lastSync: _controller.lastSync,
      isOnline: _controller.isOnline,
      isSyncing: _controller.isSyncing,
    );
  }

  // --- Overlays -------------------------------------------------------------

  Widget? _buildOverlay(
    BuildContext context,
    AppSettings settings,
    DateTime now,
    List<PrayerTime> today,
  ) {
    if (today.isEmpty) return null;

    final phase = PrayerPhaseResolver.resolve(
      now: now,
      today: today,
      iqamaDelays: settings.iqamaDelays,
      jumuahDelayMinutes: settings.jumuahDelayMinutes,
      iqamaEnabled: settings.iqamaEnabled,
    );

    if (phase.isActive) {
      final key =
          '${now.year}-${now.month}-${now.day}-'
          '${phase.prayer!.name}-${phase.kind.name}';

      if (_dismissedOverlay != key) {
        return IqamaOverlay(
          phase: phase,
          prayerName: _prayerLabel(context, phase),
          onDismiss: () => setState(() => _dismissedOverlay = key),
        );
      }

      return null;
    }

    if (settings.nightModeEnabled &&
        now.isAfter(_nightWakeUntil) &&
        NightModeResolver.isNight(now: now, today: today)) {
      final next = _controller.nextPrayer;

      return NightOverlay(
        now: now,
        nextPrayerName: next == null
            ? ''
            : context.tr(next.type.name),
        nextPrayerTime: next == null
            ? ''
            : DateTimeUtils.formatTime(next.time),
        onWake: () => setState(() => _nightWakeUntil = now.add(_nightWake)),
      );
    }

    return null;
  }

  String _prayerLabel(BuildContext context, PrayerPhase phase) {
    if (phase.isJumuah) return context.tr('jumuah');
    return context.tr(phase.prayer!.name);
  }

  // --- Strips (banner, Ramadan, Friday, reminders, announcements) ----------

  Widget? _buildBottomInfo(
    BuildContext context,
    AppSettings settings,
    DateTime now,
    List<PrayerTime> today,
  ) {
    final r = Responsive.of(context);
    final children = <Widget>[];

    final banner = _buildBanner(context);
    if (banner != null) children.add(banner);

    if (today.isNotEmpty &&
        RamadanResolver.isRamadan(
          now: now,
          mode: settings.ramadanMode,
          hijriAdjustment: settings.hijriAdjustment,
        )) {
      final info = RamadanResolver.resolve(
        now: now,
        today: today,
        imsakMinutes: settings.imsakMinutes,
      );
      if (info != null) children.add(RamadanStrip(info: info));
    }

    final slots = _rotatingSlots(context, settings, now);
    if (slots.isNotEmpty) {
      final seconds = now.minute * 60 + now.second;
      final index = (seconds ~/ _reminderRotation.inSeconds) % slots.length;
      children.add(slots[index]);
    }

    if (settings.announcementsEnabled && settings.announcements.isNotEmpty) {
      children.add(AnnouncementsStrip(announcements: settings.announcements));
    }

    if (children.isEmpty) return null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: r.gap * 0.6),
          children[i],
        ],
      ],
    );
  }

  List<Widget> _rotatingSlots(
    BuildContext context,
    AppSettings settings,
    DateTime now,
  ) {
    final slots = <Widget>[];
    final langIndex = AppLanguage.fromCode(context.languageCode).index;

    if (now.weekday == DateTime.friday) {
      slots.add(
        MessageStrip(
          icon: Icons.mosque_rounded,
          label: context.tr('jumuah'),
          text: context.tr('friday_banner'),
          highlight: true,
        ),
      );
    }

    if (settings.dailyReminderEnabled) {
      const labels = {
        ReminderKind.verse: 'rem_verse',
        ReminderKind.hadith: 'rem_hadith',
        ReminderKind.dhikr: 'rem_dhikr',
      };
      const icons = {
        ReminderKind.verse: Icons.menu_book_rounded,
        ReminderKind.hadith: Icons.format_quote_rounded,
        ReminderKind.dhikr: Icons.auto_awesome_rounded,
      };

      for (final kind in ReminderKind.values) {
        final reminder = DailyReminders.forDay(kind, now);

        slots.add(
          MessageStrip(
            icon: icons[kind]!,
            label: context.tr(labels[kind]!),
            source: reminder.sourceFor(langIndex),
            text: reminder.textFor(langIndex),
          ),
        );
      }
    }

    return slots;
  }

  Widget? _buildBanner(BuildContext context) {
    if (_adhan.isPlaying.value) {
      final type = _adhanPrayer;

      return _StatusMessage(
        message: context.tr(
          'adhan_now',
          args: {'p': type == null ? '' : context.tr(type.name)},
        ),
        icon: Icons.volume_up_rounded,
        highlight: true,
      );
    }

    final message = _getStatusMessage(context);
    return message == null ? null : _StatusMessage(message: message);
  }

  String? _getStatusMessage(BuildContext context) {
    if (_controller.isLoading && _controller.todayPrayerTimes.isEmpty) {
      return context.tr('loading_times');
    }

    if (_controller.errorMessage != null &&
        _controller.todayPrayerTimes.isEmpty) {
      return context.tr('load_error');
    }

    if (!_controller.isLoading && _controller.todayPrayerTimes.isEmpty) {
      return context.tr('no_times');
    }

    return null;
  }

  // --- Prayer grid ----------------------------------------------------------

  List<PrayerScheduleItem> _buildPrayerItems(
    BuildContext context,
    PrayerTime? nextPrayer,
  ) {
    final now = _controller.now;
    final isFriday = now.weekday == DateTime.friday;

    return PrayerType.values.map((type) {
      final matchingPrayers = _controller.todayPrayerTimes.where(
        (prayer) => prayer.type == type,
      );

      final prayer = matchingPrayers.isEmpty ? null : matchingPrayers.first;

      final isNext =
          nextPrayer?.type == type &&
          nextPrayer!.time.year == now.year &&
          nextPrayer.time.month == now.month &&
          nextPrayer.time.day == now.day;

      final name = (isFriday && type == PrayerType.dhuhr)
          ? context.tr('jumuah')
          : context.tr(type.name);

      return PrayerScheduleItem(
        name: name,
        time: prayer == null ? '--:--' : DateTimeUtils.formatTime(prayer.time),
        icon: _getPrayerIcon(type),
        isNext: isNext,
        isPassed: prayer != null && prayer.time.isBefore(now),
      );
    }).toList();
  }

  IconData _getPrayerIcon(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return Icons.nightlight_round;
      case PrayerType.sunrise:
        return Icons.wb_twilight_rounded;
      case PrayerType.dhuhr:
        return Icons.wb_sunny_rounded;
      case PrayerType.asr:
        return Icons.wb_cloudy_outlined;
      case PrayerType.maghrib:
        return Icons.wb_twilight;
      case PrayerType.isha:
        return Icons.nights_stay_rounded;
    }
  }

  // --- Text helpers ---------------------------------------------------------

  String _locationText(BuildContext context, AppSettings settings) {
    final separator = context.languageCode == 'ar' ? '، ' : ', ';
    final city = settings.localizedCity();

    final country = settings.countryCode == 'TN'
        ? context.tr('country_tn')
        : settings.governorateName;

    return country.isEmpty ? city : '$city$separator$country';
  }

  String _formatDate(DateTime date, String lang) {
    final comma = lang == 'ar' ? '،' : ',';

    return '${DateNames.weekday(lang, date.weekday)}$comma '
        '${date.day} ${DateNames.month(lang, date.month)} ${date.year}';
  }

  String _formatHijri(DateTime date, AppSettings settings, String lang) {
    final hijri = HijriDate.fromGregorian(
      date,
      adjustment: settings.hijriAdjustment,
    );

    final suffix = lang == 'ar' ? 'هـ' : (lang == 'fr' ? 'H' : 'AH');

    return '${hijri.day} ${DateNames.hijriMonth(lang, hijri.month)} '
        '${hijri.year} $suffix';
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.r,
    required this.header,
    required this.hero,
    required this.schedule,
    required this.banner,
    required this.footer,
  });

  final Responsive r;
  final Widget header;
  final Widget hero;
  final Widget schedule;
  final Widget? banner;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.pagePaddingH,
        vertical: r.pagePaddingV,
      ),
      child: Column(
        children: [
          header,
          SizedBox(height: r.s(28)),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 4, child: hero),
                SizedBox(width: r.s(28)),
                Expanded(flex: 6, child: schedule),
              ],
            ),
          ),
          if (banner != null) ...[SizedBox(height: r.gap), banner!],
          SizedBox(height: r.s(20)),
          footer,
        ],
      ),
    );
  }
}

class _StackedLayout extends StatelessWidget {
  const _StackedLayout({
    required this.r,
    required this.header,
    required this.hero,
    required this.schedule,
    required this.banner,
    required this.footer,
  });

  final Responsive r;
  final Widget header;
  final Widget hero;
  final Widget schedule;
  final Widget? banner;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: r.pagePaddingH,
            vertical: r.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              SizedBox(height: r.gap + 8),
              hero,
              SizedBox(height: r.gap + 8),
              schedule,
              if (banner != null) ...[SizedBox(height: r.gap), banner!],
              SizedBox(height: r.gap + 8),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.highlight = false,
  });

  final String message;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final t = context.text;

    return Semantics(
      liveRegion: true,
      child: GlassSurface(
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        color: highlight ? p.accentSurface.withValues(alpha: 0.85) : p.card,
        borderColor: highlight ? p.accent : p.cardBorder,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: p.accent, size: r.font(19, min: 18)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: t.label.copyWith(
                  fontSize: r.font(highlight ? 20 : 16, min: 14),
                  color: highlight ? p.accentLight : p.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
