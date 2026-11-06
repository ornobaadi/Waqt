import '../prayer/prayer_times_service.dart';
import 'moment.dart';
import 'moment_config.dart';

/// Inputs for one prayer day: Fajr of [today] to Fajr of [tomorrow].
class PrayerDay {
  const PrayerDay({required this.today, required this.tomorrow});
  final DayTimes today;
  final DayTimes tomorrow;

  TimeWindow get span => TimeWindow(today[Waqt.fajr], tomorrow[Waqt.fajr]);
}

/// One rule = one kind of moment. Rules are pure: same day, same windows.
abstract class MomentRule {
  const MomentRule();
  Iterable<Moment> windows(PrayerDay d, MomentConfig c);
}

/// Base waqt windows. Sunrise→Dhuhr is its own span so the day is covered
/// end to end with no gaps.
class WaqtRule extends MomentRule {
  const WaqtRule();

  static const _ids = {
    Waqt.fajr: MomentId.fajr,
    Waqt.sunrise: MomentId.sunrise,
    Waqt.dhuhr: MomentId.dhuhr,
    Waqt.asr: MomentId.asr,
    Waqt.maghrib: MomentId.maghrib,
    Waqt.isha: MomentId.isha,
  };

  @override
  Iterable<Moment> windows(PrayerDay d, MomentConfig c) sync* {
    for (final w in Waqt.values) {
      final end = w == Waqt.isha ? d.tomorrow[Waqt.fajr] : d.today[Waqt.values[w.index + 1]];
      yield Moment(_ids[w]!, MomentKind.prayer, 10, TimeWindow(d.today[w], end));
    }
  }
}

class LastThirdRule extends MomentRule {
  const LastThirdRule();
  @override
  Iterable<Moment> windows(PrayerDay d, MomentConfig c) sync* {
    final maghrib = d.today[Waqt.maghrib], fajr = d.tomorrow[Waqt.fajr];
    final third = fajr.difference(maghrib) ~/ 3;
    yield Moment(MomentId.lastThird, MomentKind.devotion, 85, TimeWindow(fajr.subtract(third), fajr));
  }
}

class FridayLastHourRule extends MomentRule {
  const FridayLastHourRule();
  @override
  Iterable<Moment> windows(PrayerDay d, MomentConfig c) sync* {
    if (d.today.date.weekday != DateTime.friday) return;
    final maghrib = d.today[Waqt.maghrib];
    yield Moment(
      MomentId.fridayLastHour,
      MomentKind.devotion,
      90,
      TimeWindow(maghrib.subtract(c.fridayLastHour), maghrib),
    );
  }
}

class RestrictedTimesRule extends MomentRule {
  const RestrictedTimesRule();
  @override
  Iterable<Moment> windows(PrayerDay d, MomentConfig c) sync* {
    final t = d.today;
    yield Moment(
      MomentId.restrictedSunrise,
      MomentKind.restricted,
      70,
      TimeWindow(t[Waqt.sunrise], t[Waqt.sunrise].add(c.restrictedAfterSunrise)),
    );
    yield Moment(
      MomentId.restrictedZawal,
      MomentKind.restricted,
      70,
      TimeWindow(t[Waqt.dhuhr].subtract(c.restrictedBeforeDhuhr), t[Waqt.dhuhr]),
    );
    yield Moment(
      MomentId.restrictedSunset,
      MomentKind.restricted,
      70,
      TimeWindow(t[Waqt.maghrib].subtract(c.restrictedBeforeMaghrib), t[Waqt.maghrib]),
    );
  }
}

/// Adhan → iqamah, then the prayer, then a short after-salah window, for each
/// of the five fard prayers.
class SalahRule extends MomentRule {
  const SalahRule();

  static const _fard = {
    Waqt.fajr: MomentId.fajr,
    Waqt.dhuhr: MomentId.dhuhr,
    Waqt.asr: MomentId.asr,
    Waqt.maghrib: MomentId.maghrib,
    Waqt.isha: MomentId.isha,
  };

  @override
  Iterable<Moment> windows(PrayerDay d, MomentConfig c) sync* {
    for (final MapEntry(key: w, value: id) in _fard.entries) {
      final adhan = d.today[w];
      final iqamah = adhan.add(c.iqamahDelay[w] ?? Duration.zero);
      if (iqamah.isAfter(adhan)) {
        yield Moment(MomentId.betweenAdhanIqamah, MomentKind.devotion, 80, TimeWindow(adhan, iqamah), prayer: id);
      }
      final done = iqamah.add(c.salahLength);
      yield Moment(
        MomentId.afterSalah,
        MomentKind.devotion,
        75,
        TimeWindow(done, done.add(c.afterSalahLength)),
        prayer: id,
      );
    }
  }
}

class AdhkarRule extends MomentRule {
  const AdhkarRule();
  @override
  Iterable<Moment> windows(PrayerDay d, MomentConfig c) sync* {
    final t = d.today;
    yield Moment(MomentId.morningAdhkar, MomentKind.devotion, 60, TimeWindow(t[Waqt.fajr], t[Waqt.sunrise]));
    yield Moment(MomentId.eveningAdhkar, MomentKind.devotion, 60, TimeWindow(t[Waqt.asr], t[Waqt.maghrib]));
  }
}

/// From the end of the sunrise restriction to the start of zawal.
class DuhaRule extends MomentRule {
  const DuhaRule();
  @override
  Iterable<Moment> windows(PrayerDay d, MomentConfig c) sync* {
    final start = d.today[Waqt.sunrise].add(c.restrictedAfterSunrise);
    final end = d.today[Waqt.dhuhr].subtract(c.restrictedBeforeDhuhr);
    if (end.isAfter(start)) yield Moment(MomentId.duha, MomentKind.devotion, 50, TimeWindow(start, end));
  }
}

/// `max(isha, usual bedtime)` for [MomentConfig.bedtimeLength], clipped to
/// the night so it never runs past Fajr.
class BedtimeRule extends MomentRule {
  const BedtimeRule();
  @override
  Iterable<Moment> windows(PrayerDay d, MomentConfig c) sync* {
    final day = d.today.date;
    final maghrib = d.today[Waqt.maghrib], isha = d.today[Waqt.isha], fajr = d.tomorrow[Waqt.fajr];
    // The usual bedtime that falls in tonight (Maghrib → Fajr), whichever
    // calendar day that is; if the night never reaches it, start at Isha.
    final usual = [
      for (final offset in const [0, 1, -1]) DateTime(day.year, day.month, day.day + offset, 0, c.bedtimeMinutes),
    ].where((t) => !t.isBefore(maghrib) && t.isBefore(fajr)).firstOrNull;
    final start = usual != null && usual.isAfter(isha) ? usual : isha;
    var end = start.add(c.bedtimeLength);
    if (end.isAfter(fajr)) end = fajr;
    if (end.isAfter(start)) yield Moment(MomentId.bedtime, MomentKind.devotion, 65, TimeWindow(start, end));
  }
}

const defaultRules = <MomentRule>[
  WaqtRule(),
  LastThirdRule(),
  FridayLastHourRule(),
  RestrictedTimesRule(),
  SalahRule(),
  AdhkarRule(),
  DuhaRule(),
  BedtimeRule(),
];

/// Deterministic: (prayer days, now, config) → snapshot. No clock, no I/O.
class MomentEngine {
  const MomentEngine({this.rules = defaultRules, this.config = const MomentConfig()});

  final List<MomentRule> rules;
  final MomentConfig config;

  List<Moment> timelineFor(PrayerDay d) {
    final all = [for (final r in rules) ...r.windows(d, config)]..removeWhere((m) => m.window.length <= Duration.zero);
    all.sort((a, b) {
      final s = a.window.start.compareTo(b.window.start);
      return s != 0 ? s : b.priority.compareTo(a.priority);
    });
    return all;
  }

  /// [current] is the prayer day containing [now]; [next] the one after,
  /// so "coming up" can look past tomorrow's Fajr.
  MomentSnapshot snapshot(DateTime now, PrayerDay current, PrayerDay next) {
    final timeline = timelineFor(current);
    final active = timeline.where((m) => m.window.contains(now)).toList()
      ..sort((a, b) {
        final p = b.priority.compareTo(a.priority);
        // Tie: the one that started most recently is the more specific.
        return p != 0 ? p : b.window.start.compareTo(a.window.start);
      });
    final upcoming = [
      ...timeline,
      ...timelineFor(next),
    ].where((m) => m.kind != MomentKind.prayer && m.window.start.isAfter(now)).take(2).toList();
    return MomentSnapshot(now: now, active: active, upcoming: upcoming, timeline: timeline);
  }
}
