import '../entities/tunisia_location.dart';
import '../repositories/locations_repository.dart';

class GetTunisiaLocations {
  GetTunisiaLocations(this._repository);

  final LocationsRepository _repository;

  Future<List<TunisiaLocation>> call() {
    return _repository.getLocations();
  }
}