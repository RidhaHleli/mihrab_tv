import '../entities/tunisia_location.dart';

abstract interface class LocationsRepository {
  Future<List<TunisiaLocation>> getLocations();
}