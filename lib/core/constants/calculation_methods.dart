/// Prayer time calculation methods supported by the AlAdhan API.
abstract final class CalculationMethods {
  static const Map<int, String> names = {
    1: 'University of Islamic Sciences, Karachi',
    2: 'ISNA (North America)',
    3: 'Muslim World League',
    4: 'Umm Al-Qura (Makkah)',
    5: 'Egyptian General Authority',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Singapore (MUIS)',
    12: 'France (UOIF)',
    13: 'Turkey (Diyanet)',
    14: 'Russia',
    15: 'Moonsighting Committee',
    16: 'Dubai',
    17: 'Malaysia (JAKIM)',
    18: 'Tunisia',
    19: 'Algeria',
    20: 'Indonesia (KEMENAG)',
    21: 'Morocco',
    22: 'Portugal',
    23: 'Jordan',
  };

  static const int defaultMethod = 18;

  static int normalize(int method) {
    return names.containsKey(method) ? method : defaultMethod;
  }
}
