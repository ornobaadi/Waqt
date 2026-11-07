import 'package:hijri/hijri_calendar.dart';

class HijriDate {
  const HijriDate(this.year, this.month, this.day);
  final int year;
  final int month;
  final int day;

  @override
  bool operator ==(Object other) =>
      other is HijriDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year-$month-$day';
}

/// When each Hijri month actually began, as announced by an authority after
/// the crescent was sighted (or not). Covers a few months around today.
class MonthTable {
  const MonthTable(this.months);

  /// (year, month) → first civil day and length.
  final Map<(int, int), ({DateTime start, int days})> months;

  bool get isEmpty => months.isEmpty;

  /// The Hijri date of a civil day, if one of the months covers it.
  HijriDate? lookup(DateTime civil) {
    final d = DateTime.utc(civil.year, civil.month, civil.day);
    for (final MapEntry(key: (y, m), value: v) in months.entries) {
      final s = DateTime.utc(v.start.year, v.start.month, v.start.day);
      final i = d.difference(s).inDays;
      if (i >= 0 && i < v.days) return HijriDate(y, m, i + 1);
    }
    return null;
  }

  ({DateTime start, int days})? month(int year, int month) => months[(year, month)];
}

/// The Hijri date. From an announced [table] where it covers the day;
/// otherwise Umm al-Qura's tabular calendar plus the user's offset (±2 days)
/// for local moon sighting.
class HijriService {
  const HijriService({this.table});

  final MonthTable? table;

  static const maxOffset = 2;

  /// The Islamic day begins at Maghrib, so after sunset the date advances.
  HijriDate dateFor(DateTime now, {DateTime? maghrib, int offset = 0}) {
    var d = DateTime(now.year, now.month, now.day);
    if (maghrib != null && !now.isBefore(maghrib)) d = d.add(const Duration(days: 1));
    final announced = table?.lookup(d);
    if (announced != null) return announced;
    d = DateTime(d.year, d.month, d.day + offset.clamp(-maxOffset, maxOffset));
    final h = HijriCalendar.fromDate(d);
    return HijriDate(h.hYear, h.hMonth, h.hDay);
  }

  /// First civil day and length of a Hijri month.
  ({DateTime start, int days}) monthOf(int year, int month, {int offset = 0}) {
    final known = table?.month(year, month);
    if (known != null) return known;
    final cal = HijriCalendar();
    final g = cal.hijriToGregorian(year, month, 1);
    return (
      start: DateTime(g.year, g.month, g.day - offset.clamp(-maxOffset, maxOffset)),
      days: cal.getDaysInMonth(year, month),
    );
  }
}
