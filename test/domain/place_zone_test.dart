import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:waqt/domain/location/place.dart';
import 'package:waqt/domain/moments/moment.dart';
import 'package:waqt/domain/moments/moment_engine.dart';
import 'package:waqt/domain/prayer/prayer_settings.dart';
import 'package:waqt/domain/prayer/prayer_times_service.dart';
import 'package:waqt/domain/time/place_zone.dart';

// Whatever the phone's zone (this test machine runs on Dhaka time), times
// must read in the *place's* zone.
const london = Place(
  name: 'London',
  countryCode: 'GB',
  latitude: 51.5074,
  longitude: -0.1278,
  timeZone: 'Europe/London',
);
const toronto = Place(
  name: 'Toronto',
  countryCode: 'CA',
  latitude: 43.6532,
  longitude: -79.3832,
  timeZone: 'America/Toronto',
);
const service = PrayerTimesService();

int minutes(DateTime t) => t.hour * 60 + t.minute;

void main() {
  setUpAll(ensureTimeZones);

  test('London Fajr reads in BST, not the phone\'s zone', () {
    const s = PrayerSettings(
      method: CalcMethod.mwl,
      asr: AsrSchool.standard,
      highLatitude: HighLatitudeRule.seventhOfNight,
    );
    final t = service.forDay(london, DateTime(2026, 6, 21), s);
    final fajr = t[Waqt.fajr];
    expect(fajr, isA<tz.TZDateTime>());
    expect((fajr as tz.TZDateTime).location.name, 'Europe/London');
    // Reference 02:40 UTC (see prayer_times_test) = 03:40 BST.
    expect((minutes(fajr) - (3 * 60 + 40)).abs(), lessThanOrEqualTo(2));
    expect(t.date.day, 21);
    expect(t.date.hour, 0);
  });

  test('Toronto across both DST changes: local clock times stay sensible', () {
    final s = PrayerSettings.defaultsFor('CA');
    for (final (day, before, after) in [
      (DateTime(2026, 3, 7), DateTime(2026, 3, 7), DateTime(2026, 3, 8)), // spring forward
      (DateTime(2026, 10, 31), DateTime(2026, 10, 31), DateTime(2026, 11, 1)), // fall back
    ]) {
      final a = service.forDay(toronto, before, s)[Waqt.maghrib];
      final b = service.forDay(toronto, after, s)[Waqt.maghrib];
      // The wall-clock Maghrib jumps by about an hour across the change…
      expect((minutes(b) - minutes(a)).abs(), inInclusiveRange(55, 65), reason: '$day');
      // …while the instants are about a day apart.
      expect((b.difference(a).inMinutes - 24 * 60).abs(), lessThan(5), reason: '$day');
    }
  });

  test('bedtime is 21:00 at the place', () {
    final s = PrayerSettings.defaultsFor('GB');
    final day = PrayerDay(
      today: service.forDay(london, DateTime(2026, 11, 6), s),
      tomorrow: service.forDay(london, DateTime(2026, 11, 7), s),
    );
    final bed = const MomentEngine().timelineFor(day).singleWhere((m) => m.id == MomentId.bedtime).window.start;
    expect(bed, isA<tz.TZDateTime>());
    expect((bed.hour, bed.minute), (21, 0));
  });

  test('engine invariants hold for zoned places', () {
    for (final p in [london, toronto]) {
      final s = PrayerSettings.defaultsFor(p.countryCode);
      for (final d in [DateTime(2026, 3, 8), DateTime(2026, 3, 29), DateTime(2026, 10, 25), DateTime(2026, 11, 1)]) {
        final day = PrayerDay(
          today: service.forDay(p, d, s),
          tomorrow: service.forDay(p, DateTime(d.year, d.month, d.day + 1), s),
        );
        final span = day.span;
        final timeline = const MomentEngine().timelineFor(day);
        for (var t = span.start; t.isBefore(span.end); t = t.add(const Duration(minutes: 7))) {
          expect(timeline.where((m) => m.kind == MomentKind.prayer && m.window.contains(t)).length, 1);
        }
      }
    }
  });

  test('unknown or missing zone falls back to the phone', () {
    const p = Place(name: 'X', countryCode: 'XX', latitude: 0, longitude: 0, timeZone: 'Not/AZone');
    expect(zoneOf(p), isNull);
    expect(zoneOf(null), isNull);
    expect(
      service.forDay(p, DateTime(2026, 1, 1), PrayerSettings.defaultsFor(null))[Waqt.dhuhr],
      isNot(isA<tz.TZDateTime>()),
    );
  });
}
