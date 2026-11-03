import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/tunisia_location_model.dart';

class LocalLocationsDataSource {
  static const String _assetPath = 'assets/data/tunisia_locations.json';

  Future<List<TunisiaLocationModel>> getLocations() async {
    final jsonString = await rootBundle.loadString(_assetPath);

    final decodedJson = jsonDecode(jsonString);

    if (decodedJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid Tunisia locations JSON format.');
    }

    final locationsJson = decodedJson['locations'];

    if (locationsJson is! List) {
      throw const FormatException('The locations field must be a list.');
    }

    final locations = locationsJson.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid location entry.');
      }

      return TunisiaLocationModel.fromJson(item);
    }).toList();

    if (locations.isEmpty) {
      throw const FormatException('The locations catalogue is empty.');
    }

    return locations;
  }
}
