import '../../domain/entities/tunisia_location.dart';

class TunisiaLocationModel extends TunisiaLocation {
  const TunisiaLocationModel({
    required super.id,
    required super.governorate,
    required super.city,
    required super.cityFr,
    required super.latitude,
    required super.longitude,
    super.cityEn,
    super.countryCode,
    super.timezone,
    super.method,
  });

  factory TunisiaLocationModel.fromJson(
    Map<String, dynamic> json, {
    String defaultCountryCode = 'TN',
    String defaultTimezone = 'Africa/Tunis',
    int defaultMethod = 18,
  }) {
    return TunisiaLocationModel(
      id: json['id'] as String,
      governorate: json['governorate'] as String,
      city: json['city'] as String,
      cityFr: json['cityFr'] as String,
      cityEn: (json['cityEn'] as String?) ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      countryCode: (json['countryCode'] as String?) ?? defaultCountryCode,
      timezone: (json['timezone'] as String?) ?? defaultTimezone,
      method: (json['method'] as num?)?.toInt() ?? defaultMethod,
    );
  }
}
