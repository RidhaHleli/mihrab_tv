/// Tabular (arithmetical) Islamic calendar.
///
/// Real months start with the moon sighting, so the result can differ by a
/// day: [adjustment] lets the user correct it (-2..+2).
class HijriDate {
  const HijriDate({required this.year, required this.month, required this.day});

  final int year;
  final int month;
  final int day;

  static const int ramadan = 9;

  factory HijriDate.fromGregorian(DateTime date, {int adjustment = 0}) {
    final shifted = DateTime(date.year, date.month, date.day + adjustment);

    final a = (14 - shifted.month) ~/ 12;
    final y = shifted.year + 4800 - a;
    final m = shifted.month + 12 * a - 3;

    final jd = shifted.day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;

    var l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;

    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);

    l = l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;

    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;

    return HijriDate(year: year, month: month, day: day);
  }
}
