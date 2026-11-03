import '../../domain/entities/tunisia_location.dart';
import '../../domain/repositories/locations_repository.dart';
import '../datasources/local_locations_data_source.dart';

class LocationsRepositoryImpl implements LocationsRepository {
  LocationsRepositoryImpl(this._dataSource);

  final LocalLocationsDataSource _dataSource;

  @override
  Future<List<TunisiaLocation>> getLocations() async {
    return _dataSource.getLocations();
  }
}