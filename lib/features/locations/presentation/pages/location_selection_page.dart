import 'package:flutter/material.dart';

import '../../../../core/theme/mihrab_palette.dart';
import '../../../../core/theme/themed_background.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/focusable_card.dart';
import '../../domain/entities/tunisia_location.dart';
import '../controllers/locations_controller.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() =>
      _LocationSelectionPageState();
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
        title: const Text(
          'اختيار الموقع',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: EdgeInsets.all(r.pagePaddingH.clamp(16, 32).toDouble()),
              child: Column(
                children: [
                  Text(
                    'اختر مدينتك',
                    style: t.heading.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ستُستخدم هذه المعلومات لحساب مواقيت الصلاة بدقة.',
                    textAlign: TextAlign.center,
                    style: t.body.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    onChanged: _controller.search,
                    style: TextStyle(color: p.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مدينة أو ولاية...',
                      prefixIcon: Icon(Icons.search, color: p.accent),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                              _controller.error!,
                              style: TextStyle(color: p.error),
                            ),
                          );
                        }

                        final locations = _controller.filteredLocations;

                        if (locations.isEmpty) {
                          return Center(
                            child: Text('لا توجد نتائج', style: t.body),
                          );
                        }

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                r.s(300).clamp(200, 380).toDouble(),
                            mainAxisExtent:
                                r.s(105).clamp(88, 130).toDouble(),
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            final location = locations[index];

                            return _LocationCard(
                              location: location,
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
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.onTap,
  });

  final TunisiaLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;

    return FocusableCard(
      onTap: onTap,
      borderRadius: p.cardRadius,
      semanticLabel: location.city,
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
                  location.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.title.copyWith(fontSize: 19),
                ),
                const SizedBox(height: 4),
                Text(
                  location.cityFr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.body.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: p.accent),
        ],
      ),
    );
  }
}
