/// A place the user can pick. Historically Tunisian only, now worldwide
/// (the class name is kept to avoid touching every import).
class TunisiaLocation {
  const TunisiaLocation({
    required this.id,
    required this.governorate,
    required this.city,
    required this.cityFr,
    required this.latitude,
    required this.longitude,
    this.cityEn = '',
    this.countryCode = 'TN',
    this.timezone = 'Africa/Tunis',
    this.method = 18,
  });

  final String id;

  /// Governorate for Tunisia, country name (Arabic) elsewhere.
  final String governorate;
  final String city;
  final String cityFr;
  final String cityEn;
  final double latitude;
  final double longitude;
  final String countryCode;
  final String timezone;

  /// Default AlAdhan calculation method for this place.
  final int method;

  String get cityEnOrFr => cityEn.isEmpty ? cityFr : cityEn;
}
