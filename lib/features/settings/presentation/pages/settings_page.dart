import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/calculation_methods.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/remote/remote_control_service.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/system_service.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/theme/themed_background.dart';
import '../../../../core/widgets/focusable_card.dart';
import '../../../locations/presentation/pages/location_selection_page.dart';
import '../../../prayer_times/domain/entities/prayer_time.dart';
import '../controllers/settings_controller.dart';
import '../widgets/remote_control_card.dart';
import '../widgets/settings_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _announcementController = TextEditingController();

  /// Bumped to re-check the overlay permission after the user comes back.
  int _permissionCheck = 0;

  @override
  void initState() {
    super.initState();

    _controller = InjectionContainer.createSettingsController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _controller.loadSettings();

    if (!mounted) return;

    _nameController.text = _controller.settings.displayName;
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _announcementController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _selectLocation() async {
    final location = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LocationSelectionPage()),
    );

    if (!mounted || location == null) return;

    await _controller.updateLocation(location);

    if (!mounted) return;

    _toast(context.tr('location_saved'));
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) return;

    await _controller.updateDisplayName(name);

    if (!mounted) return;

    _toast(context.tr('name_saved'));
  }

  Future<void> _addAnnouncement() async {
    final text = _announcementController.text;
    if (text.trim().isEmpty) return;

    _announcementController.clear();
    await _controller.addAnnouncement(text);
  }

  Future<void> _setRemote(bool enabled) async {
    await _controller.update(
      (s) => s.copyWith(remoteEnabled: enabled),
    );
    unawaited(RemoteControlService.instance.apply(_controller.settings));
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final t = context.text;

    return ThemedBackground(
      intensity: 0.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            context.tr('settings_title'),
            style: t.title.copyWith(fontSize: r.font(23, min: 19)),
          ),
        ),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final s = _controller.settings;

            if (_controller.isLoading) {
              return Center(child: CircularProgressIndicator(color: p.accent));
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.pagePaddingH.clamp(16, 40).toDouble(),
                    vertical: 8,
                  ),
                  children: [
                    // --- Appearance + language -----------------------------
                    SettingsSectionTitle(context.tr('appearance')),
                    ThemePicker(
                      selected: AppThemeId.fromName(s.themeId),
                      onSelected: _controller.updateTheme,
                    ),
                    SettingsSectionTitle(context.tr('language')),
                    SettingsChoices<String>(
                      options: {
                        for (final language in AppLanguage.values)
                          language.code: language.label,
                      },
                      selected: s.language,
                      onSelected: _controller.updateLanguage,
                    ),

                    // --- Identity ------------------------------------------
                    SettingsSectionTitle(context.tr('identity')),
                    SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: context.tr('display_name'),
                              hintText: context.tr('display_name_hint'),
                            ),
                            onSubmitted: (_) => _saveName(),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: FilledButton.icon(
                              onPressed:
                                  _controller.isSaving ? null : _saveName,
                              icon: const Icon(Icons.save_outlined),
                              label: Text(context.tr('save_name')),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Location + method ---------------------------------
                    SettingsSectionTitle(context.tr('location')),
                    FocusableCard(
                      onTap: _selectLocation,
                      semanticLabel: context.tr('change_location'),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: p.accent,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.localizedCity(),
                                  style: t.title.copyWith(fontSize: 20),
                                ),
                                Text(
                                  s.countryCode == 'TN'
                                      ? '${s.governorateName} · '
                                            '${context.tr('country_tn')}'
                                      : s.governorateName,
                                  style: t.label,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: p.accent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SettingsCard(
                      child: DropdownButtonFormField<int>(
                        key: ValueKey('method-${s.calculationMethod}'),
                        initialValue: s.calculationMethod,
                        isExpanded: true,
                        dropdownColor: p.surfaceElevated,
                        decoration: InputDecoration(
                          labelText: context.tr('calc_method'),
                        ),
                        items: [
                          for (final entry in CalculationMethods.names.entries)
                            DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _controller.update(
                              (s) => s.copyWith(calculationMethod: value),
                            );
                          }
                        },
                      ),
                    ),

                    // --- Adhan / iqama -------------------------------------
                    SettingsSectionTitle(context.tr('adhan_section')),
                    SettingsCard(
                      child: Column(
                        children: [
                          SettingsSwitch(
                            title: context.tr('adhan_on'),
                            subtitle: context.tr('adhan_on_sub'),
                            value: s.adhanEnabled,
                            onChanged: (v) => _controller.update(
                              (s) => s.copyWith(adhanEnabled: v),
                            ),
                          ),
                          const Divider(),
                          SettingsSwitch(
                            title: context.tr('iqama_on'),
                            subtitle: context.tr('iqama_on_sub'),
                            value: s.iqamaEnabled,
                            onChanged: (v) => _controller.update(
                              (s) => s.copyWith(iqamaEnabled: v),
                            ),
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Icon(Icons.volume_down),
                              Expanded(
                                child: Slider(
                                  value: s.volume,
                                  min: 0,
                                  max: 1,
                                  divisions: 10,
                                  label: '${(s.volume * 100).round()}%',
                                  onChanged: (v) => _controller.update(
                                    (s) => s.copyWith(volume: v),
                                  ),
                                ),
                              ),
                              const Icon(Icons.volume_up),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 48,
                                child: Text(
                                  '${(s.volume * 100).round()}%',
                                  textAlign: TextAlign.center,
                                  style: t.body,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SettingsSectionTitle(context.tr('iqama_delays')),
                    SettingsCard(
                      child: Column(
                        children: [
                          for (final type in PrayerType.values)
                            if (type != PrayerType.sunrise)
                              SettingsStepper(
                                label: context.tr(type.name),
                                value: s.iqamaDelays[type.index],
                                min: 0,
                                max: 60,
                                suffix: ' ${context.tr('minutes_unit')}',
                                onChanged: (v) =>
                                    _controller.updateIqamaDelay(type.index, v),
                              ),
                          SettingsStepper(
                            label: context.tr('jumuah_delay'),
                            value: s.jumuahDelayMinutes,
                            min: 5,
                            max: 90,
                            step: 5,
                            suffix: ' ${context.tr('minutes_unit')}',
                            onChanged: (v) => _controller.update(
                              (s) => s.copyWith(jumuahDelayMinutes: v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SettingsSectionTitle(context.tr('adjustments')),
                    SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('adjustments_sub'), style: t.label),
                          const SizedBox(height: 8),
                          for (final type in PrayerType.values)
                            SettingsStepper(
                              label: context.tr(type.name),
                              value: s.adhanAdjustments[type.index],
                              min: -30,
                              max: 30,
                              signed: true,
                              suffix: ' ${context.tr('minutes_unit')}',
                              onChanged: (v) => _controller
                                  .updateAdhanAdjustment(type.index, v),
                            ),
                        ],
                      ),
                    ),

                    // --- Announcements + reminders -------------------------
                    SettingsSectionTitle(context.tr('announcements')),
                    SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SettingsSwitch(
                            title: context.tr('announcements_on'),
                            value: s.announcementsEnabled,
                            onChanged: (v) => _controller.update(
                              (s) => s.copyWith(announcementsEnabled: v),
                            ),
                          ),
                          const Divider(),
                          SettingsSwitch(
                            title: context.tr('reminders_on'),
                            value: s.dailyReminderEnabled,
                            onChanged: (v) => _controller.update(
                              (s) => s.copyWith(dailyReminderEnabled: v),
                            ),
                          ),
                          const Divider(),
                          if (s.announcements.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                context.tr('no_announcements'),
                                style: t.label,
                              ),
                            ),
                          for (var i = 0; i < s.announcements.length; i++)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(s.announcements[i]),
                              trailing: IconButton(
                                tooltip: context.tr('delete'),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: p.error,
                                ),
                                onPressed: () =>
                                    _controller.removeAnnouncement(i),
                              ),
                            ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _announcementController,
                            maxLength: 200,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: context.tr('announcement_hint'),
                              counterText: '',
                            ),
                            onSubmitted: (_) => _addAnnouncement(),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: FilledButton.icon(
                              onPressed: _addAnnouncement,
                              icon: const Icon(Icons.add_rounded),
                              label: Text(context.tr('add')),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Ramadan / Hijri -----------------------------------
                    SettingsSectionTitle(context.tr('ramadan_section')),
                    SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('ramadan_mode'), style: t.label),
                          const SizedBox(height: 10),
                          SettingsChoices<String>(
                            options: {
                              'auto': context.tr('mode_auto'),
                              'on': context.tr('mode_on'),
                              'off': context.tr('mode_off'),
                            },
                            selected: s.ramadanMode,
                            onSelected: (v) => _controller.update(
                              (s) => s.copyWith(ramadanMode: v),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SettingsStepper(
                            label: context.tr('hijri_adjust'),
                            value: s.hijriAdjustment,
                            min: -2,
                            max: 2,
                            signed: true,
                            onChanged: (v) => _controller.update(
                              (s) => s.copyWith(hijriAdjustment: v),
                            ),
                          ),
                          SettingsStepper(
                            label: context.tr('imsak_minutes'),
                            value: s.imsakMinutes,
                            min: 0,
                            max: 30,
                            suffix: ' ${context.tr('minutes_unit')}',
                            onChanged: (v) => _controller.update(
                              (s) => s.copyWith(imsakMinutes: v),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Screen / startup ----------------------------------
                    SettingsSectionTitle(context.tr('screen_section')),
                    SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SettingsSwitch(
                            title: context.tr('night_mode'),
                            subtitle: context.tr('night_mode_sub'),
                            value: s.nightModeEnabled,
                            onChanged: (v) => _controller.update(
                              (s) => s.copyWith(nightModeEnabled: v),
                            ),
                          ),
                          if (SystemService.isAndroid) ...[
                            const Divider(),
                            SettingsSwitch(
                              title: context.tr('autostart'),
                              subtitle: context.tr('autostart_sub'),
                              value: s.autoStartEnabled,
                              onChanged: (v) => _controller.update(
                                (s) => s.copyWith(autoStartEnabled: v),
                              ),
                            ),
                            if (s.autoStartEnabled)
                              _OverlayPermission(key: ValueKey(_permissionCheck)),
                          ],
                        ],
                      ),
                    ),

                    // --- Phone remote control ------------------------------
                    SettingsSectionTitle(context.tr('remote')),
                    SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SettingsSwitch(
                            title: context.tr('remote'),
                            subtitle: context.tr('remote_sub'),
                            value: s.remoteEnabled,
                            onChanged: RemoteControlService.isSupported
                                ? _setRemote
                                : (_) {},
                          ),
                          const SizedBox(height: 8),
                          RemoteControlCard(settings: s),
                        ],
                      ),
                    ),

                    if (_controller.error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _controller.error!,
                        style: t.label.copyWith(color: p.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'MIHRAB | محراب',
                      textAlign: TextAlign.center,
                      style: t.label.copyWith(letterSpacing: 2),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Shows the state of the "display over other apps" permission (Android).
class _OverlayPermission extends StatefulWidget {
  const _OverlayPermission({super.key});

  @override
  State<_OverlayPermission> createState() => _OverlayPermissionState();
}

class _OverlayPermissionState extends State<_OverlayPermission>
    with WidgetsBindingObserver {
  bool? _granted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final granted = await SystemService.canDrawOverlays();
    if (mounted) setState(() => _granted = granted);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;

    if (_granted == null) return const SizedBox.shrink();

    if (_granted!) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: p.success, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.tr('overlay_granted'),
                style: t.label.copyWith(color: p.success),
              ),
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FilledButton.tonalIcon(
        onPressed: SystemService.openOverlaySettings,
        icon: const Icon(Icons.layers_outlined),
        label: Text(context.tr('allow_overlay')),
      ),
    );
  }
}
