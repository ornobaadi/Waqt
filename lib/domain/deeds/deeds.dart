import '../prayer/prayer_times_service.dart';

/// How a prayer was kept. Absent from a day's log = not marked.
enum SalahMark { onTime, jamaah, qada }

/// The five daily prayers, in order.
const fivePrayers = [Waqt.fajr, Waqt.dhuhr, Waqt.asr, Waqt.maghrib, Waqt.isha];

/// One prayer day's deeds (Fajr to the next Fajr).
class DayLog {
  const DayLog({this.salah = const {}, this.fast, this.habits = const {}});

  final Map<Waqt, SalahMark> salah;

  /// True fasted, false did not (only asked on fasting days), null unasked.
  final bool? fast;

  /// Habit id → amount (1 for a plain yes; pages for Quran, count for dhikr).
  final Map<String, int> habits;

  static const empty = DayLog();

  int get prayed => salah.length;
  bool get allFive => fivePrayers.every(salah.containsKey);
  bool get isEmpty => salah.isEmpty && fast == null && habits.isEmpty;

  DayLog copyWith({Map<Waqt, SalahMark>? salah, Object? fast = _keep, Map<String, int>? habits}) => DayLog(
    salah: salah ?? this.salah,
    fast: identical(fast, _keep) ? this.fast : fast as bool?,
    habits: habits ?? this.habits,
  );

  Map<String, Object?> toJson() => {
    if (salah.isNotEmpty) 's': {for (final e in salah.entries) e.key.name: e.value.name},
    'f': ?fast,
    if (habits.isNotEmpty) 'h': habits,
  };

  static DayLog fromJson(Map<String, Object?> j) => DayLog(
    salah: _salahFrom(j['s'] as Map<String, Object?>?),
    fast: j['f'] as bool?,
    habits: {for (final e in ((j['h'] as Map<String, Object?>?) ?? const {}).entries) e.key: (e.value! as num).toInt()},
  );
}

const _keep = Object();

Map<Waqt, SalahMark> _salahFrom(Map<String, Object?>? raw) {
  final out = <Waqt, SalahMark>{};
  for (final e in (raw ?? const {}).entries) {
    final w = Waqt.values.asNameMap()[e.key], m = SalahMark.values.asNameMap()[e.value];
    if (w != null && m != null) out[w] = m;
  }
  return out;
}

/// Numbers for the progress screen. Pure: same logs, same answers.
class DeedStats {
  DeedStats(this.logs);

  /// Day key (yyyy-mm-dd of the prayer day's Fajr) → log.
  final Map<String, DayLog> logs;

  DayLog of(DateTime day) => logs[dayKey(day)] ?? DayLog.empty;

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Days in a row, ending [today], with all five prayed. "Never miss twice":
  /// a single incomplete day does not break the run (it just doesn't count);
  /// two in a row do. Today still in progress never breaks it.
  int streak(DateTime today) {
    var run = 0, misses = 0;
    for (var d = _date(today), first = true; ; d = d.subtract(const Duration(days: 1)), first = false) {
      final log = of(d);
      if (log.allFive) {
        run++;
        misses = 0;
      } else if (!first) {
        misses++;
        if (misses >= 2) break;
      }
      if (logs.isEmpty || run + misses > 3660) break;
      if (!_anyBefore(d)) break;
    }
    return run;
  }

  /// Longest run of all-five days under the same rule.
  int longestStreak() {
    if (logs.isEmpty) return 0;
    final days = logs.keys.toList()..sort();
    var d = DateTime.parse(days.first);
    final end = DateTime.parse(days.last);
    var best = 0, run = 0, misses = 0;
    for (; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      if (of(d).allFive) {
        run++;
        misses = 0;
      } else if (++misses >= 2) {
        run = 0;
      }
      if (run > best) best = run;
    }
    return best;
  }

  /// Of the prayers marked in [from]..[to] (inclusive), the share kept on
  /// time or in congregation. Null when nothing was marked.
  double? onTimeShare(DateTime from, DateTime to) {
    var marked = 0, onTime = 0;
    for (var d = _date(from); !d.isAfter(_date(to)); d = d.add(const Duration(days: 1))) {
      for (final m in of(d).salah.values) {
        marked++;
        if (m != SalahMark.qada) onTime++;
      }
    }
    return marked == 0 ? null : onTime / marked;
  }

  /// Prayers left unmarked on days that had at least one prayer marked,
  /// between [from] and the day before [today]. A gentle "to make up".
  int qadaOwed(DateTime from, DateTime today) {
    var owed = 0;
    for (var d = _date(from); d.isBefore(_date(today)); d = d.add(const Duration(days: 1))) {
      final log = of(d);
      if (log.salah.isNotEmpty) owed += 5 - log.prayed;
    }
    return owed;
  }

  int fastsIn(int year) => logs.entries.where((e) => e.key.startsWith('$year-') && e.value.fast == true).length;

  bool _anyBefore(DateTime d) {
    final k = dayKey(d);
    return logs.keys.any((x) => x.compareTo(k) < 0);
  }

  static DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);
}
