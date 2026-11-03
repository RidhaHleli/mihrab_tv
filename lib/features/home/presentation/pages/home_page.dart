import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/adhan_player_service.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/theme/themed_background.dart';
import '../../../prayer_times/domain/entities/prayer_time.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/home_top_bar.dart';
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

  String _adhanPrayerName = '';

  @override
  void initState() {
    super.initState();
    _controller = InjectionContainer.createHomeController();
    _settingsController = InjectionContainer.createSettingsController();
    _adhan = InjectionContainer.createAdhanPlayerService();

    _controller.onPrayerTime = _handlePrayerTime;

    _controller.load();
    _settingsController.loadSettings();
  }

  @override
  void dispose() {
    _controller.onPrayerTime = null;
    _controller.dispose();
    _settingsController.dispose();
    _adhan.dispose();

    super.dispose();
  }

  void _handlePrayerTime(PrayerTime prayer) {
    final settings = _settingsController.settings;
    if (!settings.adhanEnabled) return;

    _adhanPrayerName = _getPrayerName(prayer.type);

    _adhan.play(
      isFajr: prayer.type == PrayerType.fajr,
      volume: settings.volume,
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );

    if (!mounted) return;

    await _settingsController.loadSettings();
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: _buildContent(),
    );
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
        final nextPrayer = _controller.nextPrayer;
        final prayers = _buildPrayerItems(nextPrayer);

        final header = HomeTopBar(
          mosqueName: settings.displayName.trim().isEmpty
              ? AppConstants.defaultMosqueName
              : settings.displayName,
          location: '${settings.cityName}، ${AppConstants.defaultCountry}',
          onSettingsPressed: _openSettings,
        );

        final hero = PrayerHeroSection(
          prayerName:
              nextPrayer == null ? 'غير متاحة' : _getPrayerName(nextPrayer.type),
          prayerTime:
              nextPrayer == null ? '--:--' : _formatPrayerTime(nextPrayer.time),
          remainingTime: _formatRemainingTime(_controller.timeUntilNextPrayer),
          currentTime: _formatPrayerTime(_controller.now),
          date: _formatArabicDate(_controller.now),
        );

        final banner = _buildBanner();

        return Scaffold(
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
                    banner: banner,
                  )
                : _StackedLayout(
                    r: r,
                    header: header,
                    hero: hero,
                    schedule: PrayerScheduleGrid(prayers: prayers),
                    banner: banner,
                  ),
          ),
        );
      },
    );
  }

  Widget? _buildBanner() {
    if (_adhan.isPlaying.value) {
      return _StatusMessage(
        message: 'حان الآن وقت صلاة $_adhanPrayerName',
        icon: Icons.volume_up_rounded,
        highlight: true,
      );
    }

    final message = _getStatusMessage();
    return message == null ? null : _StatusMessage(message: message);
  }

  List<PrayerScheduleItem> _buildPrayerItems(PrayerTime? nextPrayer) {
    return PrayerType.values.map((type) {
      final matchingPrayers = _controller.todayPrayerTimes.where(
        (prayer) => prayer.type == type,
      );

      final prayer = matchingPrayers.isEmpty ? null : matchingPrayers.first;

      final isNext =
          nextPrayer?.type == type &&
          nextPrayer!.time.year == _controller.now.year &&
          nextPrayer.time.month == _controller.now.month &&
          nextPrayer.time.day == _controller.now.day;

      return PrayerScheduleItem(
        name: _getPrayerName(type),
        time: prayer == null ? '--:--' : _formatPrayerTime(prayer.time),
        icon: _getPrayerIcon(type),
        isNext: isNext,
        isPassed: prayer != null && prayer.time.isBefore(_controller.now),
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

  String? _getStatusMessage() {
    if (_controller.isLoading) {
      return 'جارٍ تحميل مواقيت الصلاة...';
    }

    if (_controller.errorMessage != null) {
      return 'تعذر تحميل مواقيت الصلاة.';
    }

    if (_controller.todayPrayerTimes.isEmpty) {
      return 'لم تتم إضافة مواقيت الصلاة لهذا التاريخ بعد.';
    }

    return null;
  }

  String _getPrayerName(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
    }
  }

  String _formatPrayerTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatRemainingTime(Duration? duration) {
    if (duration == null) {
      return '-- : -- : --';
    }

    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours : $minutes : $seconds';
  }

  String _formatArabicDate(DateTime date) {
    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    const months = [
      'جانفي',
      'فيفري',
      'مارس',
      'أفريل',
      'ماي',
      'جوان',
      'جويلية',
      'أوت',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${weekdays[date.weekday - 1]}، '
        '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.r,
    required this.header,
    required this.hero,
    required this.schedule,
    required this.banner,
  });

  final Responsive r;
  final Widget header;
  final Widget hero;
  final Widget schedule;
  final Widget? banner;

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
          const HomeBottomBar(),
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
  });

  final Responsive r;
  final Widget header;
  final Widget hero;
  final Widget schedule;
  final Widget? banner;

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
              const HomeBottomBar(),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: highlight ? p.accentSurface : p.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlight ? p.accent : p.cardBorder,
          ),
        ),
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
