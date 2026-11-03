import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/theme/themed_background.dart';
import '../../../../core/widgets/focusable_card.dart';
import '../../domain/entities/tunisia_location.dart';
import '../controllers/locations_controller.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  late final LocationsController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = InjectionContainer.createLocationsController();
    _controller.loadLocations();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectLocation(TunisiaLocation location) {
    Navigator.of(context).pop(location);
  }

  Future<void> _createCustom() async {
    final location = await showDialog<TunisiaLocation>(
      context: context,
      builder: (_) => const _CustomLocationDialog(),
    );

    if (location != null && mounted) _selectLocation(location);
  }

  /// Secondary line of a card, in a language different from the main one.
  String _subtitle(TunisiaLocation location, String lang) {
    if (lang == 'ar') {
      return location.cityEnOrFr;
    }
    return location.governorate;
  }

  String _title(TunisiaLocation location, String lang) {
    switch (lang) {
      case 'fr':
        return location.cityFr;
      case 'en':
        return location.cityEnOrFr;
      default:
        return location.city;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final p = context.palette;
    final t = context.text;
    final lang = context.languageCode;

    return ThemedBackground(
      intensity: 0.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            context.tr('location_title'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: EdgeInsets.all(r.pagePaddingH.clamp(16, 32).toDouble()),
              child: Column(
                children: [
                  Text(
                    context.tr('choose_city'),
                    style: t.heading.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('choose_city_sub'),
                    textAlign: TextAlign.center,
                    style: t.body.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    onChanged: _controller.search,
                    style: TextStyle(color: p.textPrimary),
                    decoration: InputDecoration(
                      hintText: context.tr('search_hint'),
                      prefixIcon: Icon(Icons.search, color: p.accent),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FocusableCard(
                      onTap: _createCustom,
                      borderRadius: p.cardRadius,
                      semanticLabel: context.tr('custom_location'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_location_alt_outlined,
                              color: p.accent, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            context.tr('custom_location'),
                            style: t.title.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        if (_controller.isLoading) {
                          return Center(
                            child: CircularProgressIndicator(color: p.accent),
                          );
                        }

                        if (_controller.error != null) {
                          return Center(
                            child: Text(
                              context.tr(_controller.error!),
                              style: TextStyle(color: p.error),
                            ),
                          );
                        }

                        final locations = _controller.filteredLocations;

                        if (locations.isEmpty) {
                          return Center(
                            child: Text(
                              context.tr('no_results'),
                              style: t.body,
                            ),
                          );
                        }

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: r
                                    .s(300)
                                    .clamp(200, 380)
                                    .toDouble(),
                                mainAxisExtent: r
                                    .s(105)
                                    .clamp(88, 130)
                                    .toDouble(),
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            final location = locations[index];

                            return _LocationCard(
                              title: _title(location, lang),
                              subtitle: _subtitle(location, lang),
                              onTap: () => _selectLocation(location),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;

    return FocusableCard(
      onTap: onTap,
      borderRadius: p.cardRadius,
      semanticLabel: title,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: p.accent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.title.copyWith(fontSize: 19),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.body.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: p.accent),
        ],
      ),
    );
  }
}

/// Lets the user type any place: name, coordinates and time zone.
class _CustomLocationDialog extends StatefulWidget {
  const _CustomLocationDialog();

  @override
  State<_CustomLocationDialog> createState() => _CustomLocationDialogState();
}

class _CustomLocationDialogState extends State<_CustomLocationDialog> {
  final _name = TextEditingController();
  final _lat = TextEditingController();
  final _lon = TextEditingController();
  final _tz = TextEditingController(text: 'Africa/Tunis');

  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _lat.dispose();
    _lon.dispose();
    _tz.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final lat = double.tryParse(_lat.text.trim().replaceAll(',', '.'));
    final lon = double.tryParse(_lon.text.trim().replaceAll(',', '.'));
    final tz = _tz.text.trim();

    final valid =
        name.isNotEmpty &&
        lat != null &&
        lon != null &&
        lat >= -90 &&
        lat <= 90 &&
        lon >= -180 &&
        lon <= 180 &&
        RegExp(r'^[A-Za-z_]+(/[A-Za-z_\-+0-9]+)+$').hasMatch(tz);

    if (!valid) {
      setState(() => _error = context.tr('invalid_values'));
      return;
    }

    Navigator.of(context).pop(
      TunisiaLocation(
        id: 'custom',
        governorate: '',
        city: name,
        cityFr: name,
        cityEn: name,
        latitude: lat,
        longitude: lon,
        countryCode: 'XX',
        timezone: tz,
        method: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget field(TextEditingController c, String label, {bool number = false}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          keyboardType: number
              ? const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                )
              : TextInputType.text,
          style: TextStyle(color: p.textPrimary),
          decoration: InputDecoration(labelText: label),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: p.surfaceElevated,
      title: Text(context.tr('custom_location')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            field(_name, context.tr('custom_name')),
            field(_lat, context.tr('latitude'), number: true),
            field(_lon, context.tr('longitude'), number: true),
            field(_tz, context.tr('timezone')),
            if (_error != null)
              Text(_error!, style: TextStyle(color: p.error)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(onPressed: _submit, child: Text(context.tr('save'))),
      ],
    );
  }
}
