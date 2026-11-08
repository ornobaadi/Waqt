import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/domain/hijri/hijri_service.dart';
import 'package:waqt/domain/location/place.dart';
import 'package:waqt/domain/moments/moment.dart';
import 'package:waqt/domain/moments/moment_engine.dart';
import 'package:waqt/domain/notifications/reminder_planner.dart';
import 'package:waqt/domain/prayer/prayer_settings.dart';
import 'package:waqt/domain/prayer/prayer_times_service.dart';
import 'package:waqt/platform/widget/widget_bridge.dart';
import 'package:waqt/core/theme/tokens.dart';

const dhaka = Place(name: 'Dhaka', countryCode: 'BD', latitude: 23.8103, longitude: 90.4125);

/// Prayer days from the day before [from], with Hijri dates counted from
/// [hijri] (the Hijri date of [from]'s daylight); months are 30 days here,
/// which is all these tests need.
List<PrayerDay> days(DateTime from, int n, {HijriDate? hijri}) {
  const svc = PrayerTimesService();
  final s = PrayerSettings.defaultsFor('BD');
  final t = [for (var i = -1; i <= n; i++) svc.forDay(dhaka, DateTime(from.year, from.month, from.day + i), s)];
  HijriDate? h(int i) {
    if (hijri == null) return null;
    var d = hijri.day + i, m = hijri.month, y = hijri.year;
    while (d > 30) {
      d -= 30;
      m = m == 12 ? 1 : m + 1;
      if (m == 1) y++;
    }
    while (d < 1) {
      d += 30;
      m = m == 1 ? 12 : m - 1;
    }
    return HijriDate(y, m, d);
  }

  return [
    for (var i = 0; i + 1 < t.length; i++) PrayerDay(today: t[i], tomorrow: t[i + 1], hijri: h(i - 1), hijriNext: h(i)),
  ];
}

void main() {
  final now = DateTime(2026, 11, 6, 12, 0); // a Friday
  const planner = ReminderPlanner();

  test('defaults: the special days, Fridays and Ramadan on; daily reminders off', () {
    expect(ReminderKind.defaults, containsAll([ReminderKind.ashura, ReminderKind.dhulHijjah, ReminderKind.jumuah]));
    expect(ReminderKind.defaults, isNot(contains(ReminderKind.morningAdhkar)));
    expect(ReminderKind.defaults, isNot(contains(ReminderKind.monThu)));
  });

  test('Tasu\'a and Ashura: one reminder each, after Maghrib on the evening before', () {
    // Today is 5 Muharram; the 9th and 10th are four and five days away.
    final d = days(now, 33, hijri: const HijriDate(1448, 1, 5));
    final r = planner.plan(now, d, {ReminderKind.ashura});
    expect(r.map((x) => x.topic), [ReminderTopic.tasua, ReminderTopic.ashura]);
    final eve = d.firstWhere((x) => x.hijriNext == const HijriDate(1448, 1, 10));
    expect(r.last.at, eve.today[Waqt.maghrib].add(ReminderPlanner.eveDelay));
  });

  test('Dhul Hijjah: the start of the ten, Arafah, and Eid al-Adha', () {
    final d = days(now, 33, hijri: const HijriDate(1447, 11, 28));
    final r = planner.plan(now, d, {ReminderKind.dhulHijjah, ReminderKind.eid});
    expect(r.map((x) => x.topic).take(3), [ReminderTopic.dhulHijjah, ReminderTopic.arafah, ReminderTopic.eidAdha]);
  });

  test('white days: one reminder before the 13th; Monday fast only when asked, and never on top of it', () {
    final d = days(now, 33, hijri: const HijriDate(1448, 5, 10));
    expect(planner.plan(now, d, {ReminderKind.whiteDays}).map((x) => x.topic), [ReminderTopic.whiteDays]);
    final both = planner.plan(now, d, {ReminderKind.whiteDays, ReminderKind.monThu});
    final eves = both.map((x) => DateTime(x.at.year, x.at.month, x.at.day)).toList();
    expect(eves.toSet().length, eves.length, reason: 'at most one reminder per evening');
    expect(both.where((x) => x.topic == ReminderTopic.monday || x.topic == ReminderTopic.thursday), isNotEmpty);
  });

  test('Ramadan: start, suhoor and iftar come only with the Hijri date known', () {
    final d = days(now, 10, hijri: const HijriDate(1447, 8, 28));
    final r = planner.plan(now, d, {ReminderKind.ramadan, ReminderKind.suhoor, ReminderKind.iftar});
    expect(r.first.topic, ReminderTopic.ramadan);
    expect(r.where((x) => x.topic == ReminderTopic.suhoor), isNotEmpty);
    expect(r.where((x) => x.topic == ReminderTopic.iftar), isNotEmpty);
    expect(planner.plan(now, days(now, 10), {ReminderKind.suhoor, ReminderKind.iftar}), isEmpty);
  });

  test('Friday: morning after sunrise and the last hour, every Friday in the month', () {
    final d = days(now, 33, hijri: const HijriDate(1448, 5, 26));
    final r = planner.plan(now, d, {ReminderKind.jumuah, ReminderKind.fridayLastHour});
    final mornings = r.where((x) => x.topic == ReminderTopic.jumuah).toList();
    expect(mornings, isNotEmpty);
    expect(mornings.every((x) => x.at.weekday == DateTime.friday && x.at.hour < 12), isTrue);
    expect(
      r.where((x) => x.topic == ReminderTopic.fridayLastHour).every((x) => x.at.weekday == DateTime.friday),
      isTrue,
    );
    expect(r.last.at.difference(now).inDays, greaterThan(21), reason: 'special reminders look a month ahead');
  });

  test('daily reminders look a week ahead, in order, future only, unique ids', () {
    final d = days(now, 33);
    final r = planner.plan(now, d, {ReminderKind.lastThird, ReminderKind.bedtime});
    expect(r.where((x) => x.kind == ReminderKind.lastThird).length, 7);
    expect(r.every((x) => x.at.isAfter(now) && x.at.isBefore(now.add(const Duration(days: 8)))), isTrue);
    for (var i = 1; i < r.length; i++) {
      expect(r[i].at.isAfter(r[i - 1].at) || r[i].at == r[i - 1].at, isTrue);
    }
    expect(r.map((x) => x.id).toSet().length, r.length);
  });

  test('nothing enabled, nothing scheduled', () => expect(planner.plan(now, days(now, 9), {}), isEmpty));

  test('stays under the cap', () {
    final d = days(now, 33, hijri: const HijriDate(1447, 9, 1));
    expect(planner.plan(now, d, ReminderKind.values.toSet()).length, lessThanOrEqualTo(ReminderPlanner.maxReminders));
  });

  test('every kind has a preview topic of its own kind', () {
    for (final k in ReminderKind.values) {
      expect(ReminderTopic.sample(k).kind, k);
    }
  });

  test('widget schedule covers every waqt with the next prayer and palette', () {
    final d = days(now, 9);
    final e = widgetSchedule(
      days: d,
      place: 'Dhaka',
      label: (id) => id.name,
      time: (t) => '${t.hour}:${t.minute}',
      palette: (id) => id == MomentId.isha ? MomentPalette.night : MomentPalette.dhuhr,
    );
    expect(e.length, d.length * 6);
    for (var i = 1; i < e.length; i++) {
      expect(e[i].at, e[i - 1].nextAt, reason: 'entries must tile time with no gaps');
    }
    final sunrise = e.firstWhere((x) => x.current == 'sunrise');
    expect(sunrise.next, startsWith('dhuhr'));
    final isha = e.firstWhere((x) => x.current == 'isha');
    expect(isha.next, startsWith('fajr'));
    expect(isha.toJson()['ground'], MomentPalette.night.ground.toARGB32());
  });
}
