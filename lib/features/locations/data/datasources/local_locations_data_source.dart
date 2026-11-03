import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/tunisia_location_model.dart';

class LocalLocationsDataSource {
  static const String _tunisiaPath = 'assets/data/tunisia_locations.json';
  static const String _worldPath = 'assets/data/world_cities.json';

  /// Tunisian places first, then the major cities of the world.
  Future<List<TunisiaLocationModel>> getLocations() async {
    final tunisia = await _load(_tunisiaPath, isTunisia: true);

    List<TunisiaLocationModel> world = const [];
    try {
      world = await _load(_worldPath, isTunisia: false);
    } catch (_) {
      // The world catalogue is optional: Tunisia alone still works.
    }

    final locations = [...tunisia, ...world];

    if (locations.isEmpty) {
      throw const FormatException('The locations catalogue is empty.');
    }

    return locations;
  }

  Future<List<TunisiaLocationModel>> _load(
    String path, {
    required bool isTunisia,
  }) async {
    final jsonString = await rootBundle.loadString(path);
    final decodedJson = jsonDecode(jsonString);

    if (decodedJson is! Map<String, dynamic>) {
      throw FormatException('Invalid locations JSON format: $path');
    }

    final locationsJson = decodedJson['locations'];

    if (locationsJson is! List) {
      throw const FormatException('The locations field must be a list.');
    }

    final countryCode = (decodedJson['countryCode'] as String?) ?? 'TN';
    final timezone = (decodedJson['timezone'] as String?) ?? 'Africa/Tunis';

    return locationsJson.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid location entry.');
      }

      return TunisiaLocationModel.fromJson(
        item,
        defaultCountryCode: isTunisia ? countryCode : 'XX',
        defaultTimezone: isTunisia ? timezone : 'UTC',
      );
    }).toList();
  }
}
