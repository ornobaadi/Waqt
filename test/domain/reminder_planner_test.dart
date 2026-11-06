import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/domain/location/place.dart';
import 'package:waqt/domain/moments/moment.dart';
import 'package:waqt/domain/moments/moment_engine.dart';
import 'package:waqt/domain/notifications/reminder_planner.dart';
import 'package:waqt/domain/prayer/prayer_settings.dart';
import 'package:waqt/domain/prayer/prayer_times_service.dart';
import 'package:waqt/platform/widget/widget_bridge.dart';
import 'package:waqt/core/theme/tokens.dart';

const dhaka = Place(name: 'Dhaka', countryCode: 'BD', latitude: 23.8103, longitude: 90.4125);

List<PrayerDay> days(DateTime from, int n) {
  const svc = PrayerTimesService();
  final s = PrayerSettings.defaultsFor('BD');
  final t = [for (var i = -1; i <= n; i++) svc.forDay(dhaka, DateTime(from.year, from.month, from.day + i), s)];
  return [for (var i = 0; i + 1 < t.length; i++) PrayerDay(today: t[i], tomorrow: t[i + 1])];
}

void main() {
  final now = DateTime(2026, 11, 6, 12, 0); // a Friday
  final d = days(now, 9);
  const planner = ReminderPlanner();

  test('defaults: morning and evening adhkar, in order, future only, never a prayer time', () {
    final r = planner.plan(now, d, ReminderKind.defaults);
    expect(r.length, inInclusiveRange(13, 15));
    expect(r.every((x) => x.at.isAfter(now) && ReminderKind.defaults.contains(x.kind)), isTrue);
    for (var i = 1; i < r.length; i++) {
      expect(r[i].at.isAfter(r[i - 1].at), isTrue);
    }
    expect(r.map((x) => x.id).toSet().length, r.length);
  });

  test('moments: Friday last hour only on Fridays, no duplicates across day edges', () {
    final r = planner.plan(now, d, {ReminderKind.fridayLastHour, ReminderKind.lastThird, ReminderKind.bedtime});
    final fridays = r.where((x) => x.kind == ReminderKind.fridayLastHour);
    expect(fridays.length, 1);
    expect(fridays.single.at.weekday, DateTime.friday);
    expect(r.where((x) => x.kind == ReminderKind.lastThird).length, 7);
    expect(r.toSet().length, r.length);
  });

  test('nothing enabled, nothing scheduled', () => expect(planner.plan(now, d, {}), isEmpty));

  test('stays under the cap', () {
    expect(planner.plan(now, d, ReminderKind.values.toSet()).length, lessThanOrEqualTo(ReminderPlanner.maxReminders));
  });

  test('widget schedule covers every waqt with the next prayer and palette', () {
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
