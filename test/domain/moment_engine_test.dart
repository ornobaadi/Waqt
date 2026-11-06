import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/app/app_state.dart' show paletteFor;
import 'package:waqt/core/theme/tokens.dart';
import 'package:waqt/domain/location/place.dart';
import 'package:waqt/domain/moments/moment.dart';
import 'package:waqt/domain/moments/moment_engine.dart';
import 'package:waqt/domain/prayer/prayer_settings.dart';
import 'package:waqt/domain/prayer/prayer_times_service.dart';

const service = PrayerTimesService();
const engine = MomentEngine();

Place at(String name, double lat, double lng, String cc) =>
    Place(name: name, countryCode: cc, latitude: lat, longitude: lng);

final dhaka = at('Dhaka', 23.8103, 90.4125, 'BD');

PrayerDay dayOf(Place p, DateTime d) {
  final s = PrayerSettings.defaultsFor(p.countryCode);
  return PrayerDay(
    today: service.forDay(p, d, s),
    tomorrow: service.forDay(p, DateTime(d.year, d.month, d.day + 1), s),
  );
}

/// Same resolution the app uses: before Fajr we're in yesterday's prayer day.
MomentSnapshot snap(Place p, DateTime now) {
  final s = PrayerSettings.defaultsFor(p.countryCode);
  final today = service.forDay(p, now, s);
  final start = now.isBefore(today[Waqt.fajr]) ? DateTime(now.year, now.month, now.day - 1) : now;
  final d0 = DateTime(start.year, start.month, start.day);
  return engine.snapshot(now, dayOf(p, d0), dayOf(p, DateTime(d0.year, d0.month, d0.day + 1)));
}

void main() {
  final cities = [
    dhaka,
    at('Makkah', 21.4225, 39.8262, 'SA'),
    at('London', 51.5074, -0.1278, 'GB'),
    at('Oslo', 59.9139, 10.7522, 'NO'),
    at('Jakarta', -6.2088, 106.8456, 'ID'),
    at('Toronto', 43.6532, -79.3832, 'CA'),
    at('Auckland', -36.8485, 174.7633, 'NZ'),
  ];
  // Includes the 2026 EU and NZ DST changeovers.
  final dates = [
    DateTime(2026, 3, 29),
    DateTime(2026, 4, 5),
    DateTime(2026, 6, 21),
    DateTime(2026, 10, 25),
    DateTime(2026, 11, 1),
    DateTime(2026, 12, 21),
  ];

  group('invariants', () {
    for (final p in cities) {
      for (final d in dates) {
        test('${p.name} ${d.month}/${d.day}', () {
          final day = dayOf(p, d);
          final span = day.span;
          final timeline = engine.timelineFor(day);

          for (final m in timeline) {
            expect(m.window.end.isAfter(m.window.start), isTrue, reason: '$m empty');
            expect(!m.window.start.isBefore(span.start) && !m.window.end.isAfter(span.end), isTrue, reason: '$m');
          }
          // Sorted by start.
          for (var i = 1; i < timeline.length; i++) {
            expect(!timeline[i].window.start.isBefore(timeline[i - 1].window.start), isTrue);
          }
          // Exactly one waqt covers every instant of the prayer day.
          for (var t = span.start; t.isBefore(span.end); t = t.add(const Duration(minutes: 7))) {
            final waqts = timeline.where((m) => m.kind == MomentKind.prayer && m.window.contains(t));
            expect(waqts.length, 1, reason: 'at $t');
          }

          final third = timeline.singleWhere((m) => m.id == MomentId.lastThird).window;
          expect(third.end, day.tomorrow[Waqt.fajr]);
          final night = day.tomorrow[Waqt.fajr].difference(day.today[Waqt.maghrib]);
          expect((third.length - night ~/ 3).inSeconds.abs(), lessThanOrEqualTo(1));

          final bed = timeline.singleWhere((m) => m.id == MomentId.bedtime).window;
          expect(!bed.start.isBefore(day.today[Waqt.isha]), isTrue);

          final duha = timeline.where((m) => m.id == MomentId.duha);
          for (final m in duha) {
            expect(m.window.start.isAfter(day.today[Waqt.sunrise]), isTrue);
            expect(m.window.end.isBefore(day.today[Waqt.dhuhr]), isTrue);
          }

          expect(timeline.any((m) => m.id == MomentId.fridayLastHour), d.weekday == DateTime.friday);
          expect(timeline.any((m) => m.id == MomentId.jumuah), d.weekday == DateTime.friday);
        });
      }
    }
  });

  group('hero resolution (Dhaka, Friday 6 Nov 2026)', () {
    final fri = DateTime(2026, 11, 6);
    final t = dayOf(dhaka, fri).today;

    test('last hour of Friday outranks evening adhkar', () {
      final s = snap(dhaka, t[Waqt.maghrib].subtract(const Duration(minutes: 40)));
      expect(s.hero.id, MomentId.fridayLastHour);
      expect(s.active.map((m) => m.id), containsAll([MomentId.eveningAdhkar, MomentId.asr]));
      expect(s.waqt.id, MomentId.asr);
    });

    test('…and outranks the sunset restriction it overlaps', () {
      final s = snap(dhaka, t[Waqt.maghrib].subtract(const Duration(minutes: 5)));
      expect(s.hero.id, MomentId.fridayLastHour);
      expect(s.active.map((m) => m.id), contains(MomentId.restrictedSunset));
    });

    test('on Saturday the same time is evening adhkar', () {
      final sat = dayOf(dhaka, DateTime(2026, 11, 7)).today;
      final s = snap(dhaka, sat[Waqt.maghrib].subtract(const Duration(minutes: 40)));
      expect(s.hero.id, MomentId.eveningAdhkar);
    });

    test('adhan → iqamah, then after the prayer', () {
      final a = snap(dhaka, t[Waqt.dhuhr].add(const Duration(minutes: 3)));
      expect(a.hero.id, MomentId.betweenAdhanIqamah);
      expect(a.hero.prayer, MomentId.dhuhr);
      final b = snap(dhaka, t[Waqt.dhuhr].add(const Duration(minutes: 30)));
      expect(b.hero.id, MomentId.afterSalah);
    });

    test('sunrise restriction, then Duha', () {
      expect(snap(dhaka, t[Waqt.sunrise].add(const Duration(minutes: 5))).hero.id, MomentId.restrictedSunrise);
      expect(snap(dhaka, t[Waqt.sunrise].add(const Duration(hours: 2))).hero.id, MomentId.duha);
    });

    test('03:10 next morning is the last third, in yesterday\'s prayer day', () {
      final s = snap(dhaka, DateTime(2026, 11, 7, 3, 10));
      expect(s.hero.id, MomentId.lastThird);
      expect(s.waqt.id, MomentId.isha);
      expect(s.timeline.first.window.start, t[Waqt.fajr]);
    });

    test('bedtime at 22:45', () {
      expect(snap(dhaka, DateTime(2026, 11, 6, 22, 45)).hero.id, MomentId.bedtime);
    });

    test('coming up: future refinements only, in order, at most two, across Fajr', () {
      for (final now in [DateTime(2026, 11, 6, 9, 0), DateTime(2026, 11, 6, 16, 20), DateTime(2026, 11, 7, 4, 30)]) {
        final s = snap(dhaka, now);
        expect(s.upcoming.length, 2, reason: '$now');
        expect(s.upcoming.every((m) => m.window.start.isAfter(now) && m.kind != MomentKind.prayer), isTrue);
        expect(!s.upcoming[1].window.start.isBefore(s.upcoming[0].window.start), isTrue);
      }
      expect(snap(dhaka, DateTime(2026, 11, 7, 4, 30)).upcoming.first.id, MomentId.betweenAdhanIqamah);
    });

    test('a hero always exists, all day', () {
      final span = dayOf(dhaka, fri).span;
      for (var now = span.start; now.isBefore(span.end); now = now.add(const Duration(minutes: 3))) {
        final s = snap(dhaka, now);
        expect(s.active, isNotEmpty, reason: '$now');
        expect(s.hero.priority, s.active.map((m) => m.priority).reduce((a, b) => a > b ? a : b));
      }
    });
  });

  test('palette follows the hero, then the waqt', () {
    expect(paletteFor(MomentId.lastThird, MomentId.isha), MomentPalette.night);
    expect(paletteFor(MomentId.bedtime, MomentId.isha), MomentPalette.bedtime);
    expect(paletteFor(MomentId.fridayLastHour, MomentId.asr), MomentPalette.asr);
    expect(paletteFor(MomentId.afterSalah, MomentId.maghrib), MomentPalette.maghrib);
    expect(paletteFor(MomentId.duha, MomentId.sunrise), MomentPalette.dhuhr);
    expect(paletteFor(null, null), MomentPalette.dhuhr);
  });
}
