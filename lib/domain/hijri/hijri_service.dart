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

/// Umm al-Qura tabular conversion plus a user offset (±2 days) for local
/// moon sighting.
class HijriService {
  const HijriService();

  static const maxOffset = 2;

  /// The Islamic day begins at Maghrib, so after sunset the date advances.
  HijriDate dateFor(DateTime now, {DateTime? maghrib, int offset = 0}) {
    var d = DateTime(now.year, now.month, now.day);
    if (maghrib != null && !now.isBefore(maghrib)) d = d.add(const Duration(days: 1));
    d = DateTime(d.year, d.month, d.day + offset.clamp(-maxOffset, maxOffset));
    final h = HijriCalendar.fromDate(d);
    return HijriDate(h.hYear, h.hMonth, h.hDay);
  }
}
