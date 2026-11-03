import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/islamic_patterns.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/theme/themed_background.dart';
import '../../../../core/widgets/focusable_card.dart';
import '../../../../core/widgets/glass_surface.dart';

class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          StarOrnament(color: p.accent, size: 20),
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

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return GlassSurface(
      radius: p.cardRadius,
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

/// Switch row with a title and an optional description.
class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      value: value,
      onChanged: onChanged,
    );
  }
}

/// "- value +" control that works with touch and with a TV remote.
class SettingsStepper extends StatelessWidget {
  const SettingsStepper({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
    this.suffix = '',
    this.signed = false,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String suffix;
  final bool signed;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;

    final text = '${signed && value > 0 ? '+' : ''}$value$suffix';

    Widget button(IconData icon, String name, bool enabled, int delta) {
      return Opacity(
        opacity: enabled ? 1 : 0.35,
        child: FocusableCard(
          onTap: () {
            if (enabled) onChanged((value + delta).clamp(min, max).toInt());
          },
          borderRadius: 12,
          semanticLabel: '$label $name',
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: p.accent, size: 24),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: t.body.copyWith(fontSize: 16))),
          button(Icons.remove_rounded, '-', value > min, -step),
          SizedBox(
            width: 86,
            child: Text(
              text,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: t.title.copyWith(fontSize: 18),
            ),
          ),
          button(Icons.add_rounded, '+', value < max, step),
        ],
      ),
    );
  }
}

/// A row of mutually exclusive choices.
class SettingsChoices<T> extends StatelessWidget {
  const SettingsChoices({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  /// value -> label
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final entry in options.entries)
          FocusableCard(
            onTap: () => onSelected(entry.key),
            selected: entry.key == selected,
            borderRadius: 14,
            semanticLabel: entry.value,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entry.key == selected) ...[
                  Icon(Icons.check_circle_rounded, color: p.accent, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(entry.value, style: t.title.copyWith(fontSize: 17)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Lets the user pick one of the available looks; applied instantly.
class ThemePicker extends StatelessWidget {
  const ThemePicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppThemeId selected;
  final ValueChanged<AppThemeId> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = [
      for (final id in AppThemeId.values)
        _ThemeOption(
          id: id,
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
    required this.id,
    required this.selected,
    required this.onTap,
  });

  final AppThemeId id;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    final title = context.tr('theme_${id.name}');

    return FocusableCard(
      onTap: onTap,
      selected: selected,
      borderRadius: p.cardRadius,
      semanticLabel: title,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ThemePreview(palette: id.palette),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.title.copyWith(fontSize: 18),
                    ),
                    Text(
                      context.tr('sub_${id.name}'),
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
