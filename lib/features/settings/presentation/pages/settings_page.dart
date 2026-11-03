import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/theme/themed_background.dart';
import '../../../../core/widgets/focusable_card.dart';
import '../../../locations/presentation/pages/location_selection_page.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;
  final TextEditingController _nameController = TextEditingController();

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
    super.dispose();
  }

  Future<void> _selectLocation() async {
    final location = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LocationSelectionPage()),
    );

    if (!mounted || location == null) return;

    await _controller.updateLocation(location);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الموقع بنجاح')),
    );
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) return;

    await _controller.updateDisplayName(name);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الاسم')),
    );
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
          'إعدادات محراب',
          style: t.title.copyWith(
            fontSize: r.font(23, min: 19),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final settings = _controller.settings;

          if (_controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: p.accent),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: r.pagePaddingH.clamp(16, 40).toDouble(),
                  vertical: 16,
                ),
                children: [
                  _SectionTitle('المظهر', r: r),
                  _ThemePicker(
                    selected: AppThemeId.fromName(settings.themeId),
                    onSelected: _controller.updateTheme,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('هوية المسجد أو المنزل', r: r),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'الاسم المعروض',
                            hintText: 'مثال: مسجد الرحمة',
                          ),
                          onSubmitted: (_) => _saveName(),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: FilledButton.icon(
                            onPressed: _controller.isSaving ? null : _saveName,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('حفظ الاسم'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('الموقع الجغرافي', r: r),
                  FocusableCard(
                    onTap: _selectLocation,
                    semanticLabel: 'تغيير الموقع',
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
                                settings.cityName,
                                style: t.title.copyWith(fontSize: 20),
                              ),
                              Text(
                                settings.governorateName,
                                style: t.label,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_left, color: p.accent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('إعدادات الأذان والإقامة', r: r),
                  _Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('تشغيل الأذان'),
                          subtitle: const Text(
                            'تشغيل صوت الأذان عند دخول وقت الصلاة',
                          ),
                          value: settings.adhanEnabled,
                          onChanged: _controller.updateAdhanEnabled,
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('إعلان إقامة الصلاة'),
                          subtitle: const Text('إعلان قصير بعد الأذان'),
                          value: settings.iqamaEnabled,
                          onChanged: _controller.updateIqamaEnabled,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('مستوى الصوت', r: r),
                  _Card(
                    child: Row(
                      children: [
                        const Icon(Icons.volume_down),
                        Expanded(
                          child: Slider(
                            value: settings.volume,
                            min: 0,
                            max: 1,
                            divisions: 10,
                            label: '${(settings.volume * 100).round()}%',
                            onChanged: _controller.updateVolume,
                          ),
                        ),
                        const Icon(Icons.volume_up),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${(settings.volume * 100).round()}%',
                            textAlign: TextAlign.center,
                            style: t.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('الوقت قبل الإقامة', r: r),
                  _Card(
                    child: DropdownButtonFormField<int>(
                      initialValue: settings.iqamaDelayMinutes,
                      dropdownColor: p.surfaceElevated,
                      decoration: const InputDecoration(
                        labelText: 'مدة الانتظار بالدقائق',
                      ),
                      items: const [10, 11, 12, 13, 14, 15]
                          .map(
                            (minutes) => DropdownMenuItem<int>(
                              value: minutes,
                              child: Text('$minutes دقيقة'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _controller.updateIqamaDelay(value);
                        }
                      },
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.r});

  final String title;
  final Responsive r;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              style: context.text.heading.copyWith(
                fontSize: r.font(22, min: 18),
                color: p.accentLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(p.cardRadius),
        border: Border.all(color: p.cardBorder),
      ),
      child: child,
    );
  }
}

/// Lets the user pick one of the available looks; applied instantly.
class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.selected, required this.onSelected});

  final AppThemeId selected;
  final ValueChanged<AppThemeId> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = [
      for (final id in AppThemeId.values)
        _ThemeOption(
          palette: id.palette,
          selected: id == selected,
          onTap: () => onSelected(id),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 640) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(width: 14),
                Expanded(child: options[i]),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              options[i],
            ],
          ],
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final MihrabPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;

    return FocusableCard(
      onTap: onTap,
      selected: selected,
      borderRadius: p.cardRadius,
      semanticLabel: 'المظهر: ${palette.label}',
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ThemePreview(palette: palette),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      palette.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.title.copyWith(fontSize: 18),
                    ),
                    Text(
                      palette.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.label.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: selected ? p.accent : p.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
