import '../../domain/entities/tunisia_location.dart';

class TunisiaLocationModel extends TunisiaLocation {
  const TunisiaLocationModel({
    required super.id,
    required super.governorate,
    required super.city,
    required super.cityFr,
    required super.latitude,
    required super.longitude,
  });

  factory TunisiaLocationModel.fromJson(Map<String, dynamic> json) {
    return TunisiaLocationModel(
      id: json['id'] as String,
      governorate: json['governorate'] as String,
      city: json['city'] as String,
      cityFr: json['cityFr'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
