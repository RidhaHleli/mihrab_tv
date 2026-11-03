import 'package:flutter/foundation.dart';

import '../../domain/entities/tunisia_location.dart';
import '../../domain/usecases/get_tunisia_locations.dart';

class LocationsController extends ChangeNotifier {
  LocationsController(this._getTunisiaLocations);

  final GetTunisiaLocations _getTunisiaLocations;

  List<TunisiaLocation> _locations = [];
  TunisiaLocation? _selectedLocation;

  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  bool _disposed = false;

  List<TunisiaLocation> get locations => _locations;
  TunisiaLocation? get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  List<TunisiaLocation> get filteredLocations {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return _locations;

    return _locations.where((location) {
      return location.city.toLowerCase().contains(query) ||
          location.cityFr.toLowerCase().contains(query) ||
          location.governorate.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadLocations() async {
    if (_isLoading || _disposed) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _locations = await _getTunisiaLocations();
    } catch (e) {
      _error = 'Impossible de charger les localisations.';
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void search(String query) {
    if (_disposed) return;

    _searchQuery = query;
    notifyListeners();
  }

  void selectLocation(TunisiaLocation location) {
    if (_disposed) return;

    _selectedLocation = location;
    notifyListeners();
  }

  void clearSelection() {
    if (_disposed) return;

    _selectedLocation = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}