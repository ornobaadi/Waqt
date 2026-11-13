import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/domain/location/place.dart';
import 'package:waqt/domain/moments/moment_config.dart';
import 'package:waqt/domain/prayer/prayer_settings.dart';
import 'package:waqt/domain/prayer/prayer_times_service.dart';

const service = PrayerTimesService();

Place at(String name, double lat, double lng, [String cc = 'XX']) =>
    Place(name: name, countryCode: cc, latitude: lat, longitude: lng);

/// Reference: AlAdhan API (an independent implementation), 21 June 2026,
/// UTC, fetched 2026-11-06. Order: Fajr Sunrise Dhuhr Asr Maghrib Isha.
/// These check our wiring of methods/schools/rules, not astronomy itself;
/// official national tables are still to be compared by a human (phases.md).
final references = <(Place, PrayerSettings, List<String>)>[
  (
    at('Dhaka', 23.8103, 90.4125),
    const PrayerSettings(method: CalcMethod.karachi, madhab: Madhab.hanafi),
    ['21:44', '23:12', '06:00', '10:41', '12:48', '14:16'],
  ),
  (
    at('Makkah', 21.4225, 39.8262),
    const PrayerSettings(method: CalcMethod.ummAlQura, madhab: Madhab.shafii),
    ['01:11', '02:39', '09:22', '12:42', '16:06', '17:36'],
  ),
  (
    at('Cairo', 30.0444, 31.2357),
    const PrayerSettings(method: CalcMethod.egypt, madhab: Madhab.shafii),
    ['01:08', '02:54', '09:57', '13:32', '16:59', '18:33'],
  ),
  (
    at('Jakarta', -6.2088, 106.8456),
    const PrayerSettings(method: CalcMethod.singapore, madhab: Madhab.shafii),
    ['21:38', '23:01', '04:54', '08:16', '10:47', '12:02'],
  ),
  (
    at('New York', 40.7128, -74.0060),
    const PrayerSettings(method: CalcMethod.isna, madhab: Madhab.shafii),
    ['07:45', '09:25', '16:58', '20:58', '00:31', '02:11'],
  ),
  (
    at('London', 51.5074, -0.1278),
    const PrayerSettings(method: CalcMethod.mwl, madhab: Madhab.shafii, highLatitude: HighLatitudeRule.seventhOfNight),
    ['02:40', '03:43', '12:02', '16:25', '20:22', '21:25'],
  ),
];

int minuteOfDayUtc(DateTime t) {
  final u = t.toUtc();
  return u.hour * 60 + u.minute;
}

int parse(String hm) => int.parse(hm.substring(0, 2)) * 60 + int.parse(hm.substring(3));

/// Circular distance in minutes, so 23:59 vs 00:01 is 2.
int diff(int a, int b) {
  final d = (a - b).abs() % 1440;
  return d > 720 ? 1440 - d : d;
}

void main() {
  group('matches reference within 2 min', () {
    for (final (place, settings, expected) in references) {
      test(place.name, () {
        final times = service.forDay(place, DateTime(2026, 6, 21), settings);
        for (final w in Waqt.values) {
          final got = minuteOfDayUtc(times[w]);
          expect(diff(got, parse(expected[w.index])), lessThanOrEqualTo(2), reason: '${w.name} got $got');
        }
      });
    }
  });

  group('order and validity', () {
    final places = [
      at('Oslo', 59.9139, 10.7522, 'NO'),
      at('Reykjavik', 64.1466, -21.9426, 'IS'),
      at('Cape Town', -33.9249, 18.4241, 'ZA'),
      at('Auckland', -36.8485, 174.7633, 'NZ'),
      at('Quito', -0.1807, -78.4678, 'EC'),
    ];
    for (final p in places) {
      for (final day in [
        DateTime(2026, 3, 29),
        DateTime(2026, 6, 21),
        DateTime(2026, 10, 25),
        DateTime(2026, 12, 21),
      ]) {
        test('${p.name} ${day.month}/${day.day}', () {
          final t = service.forDay(p, day, PrayerSettings.defaultsFor(p.countryCode));
          for (var i = 1; i < Waqt.values.length; i++) {
            expect(t[Waqt.values[i]].isAfter(t[Waqt.values[i - 1]]), isTrue, reason: Waqt.values[i].name);
          }
        });
      }
    }
  });

  test('polar day and night fall back to 65° and say so', () {
    final tromso = at('Tromsø', 69.6496, 18.9560, 'NO');
    for (final day in [DateTime(2026, 6, 21), DateTime(2026, 12, 21)]) {
      final t = service.forDay(tromso, day, PrayerSettings.defaultsFor('NO'));
      expect(t.estimated, isTrue);
      expect(t[Waqt.isha].isAfter(t[Waqt.fajr]), isTrue);
    }
    final normal = service.forDay(tromso, DateTime(2026, 3, 21), PrayerSettings.defaultsFor('NO'));
    expect(normal.estimated, isFalse);
  });

  group('status', () {
    final dhaka = at('Dhaka', 23.8103, 90.4125, 'BD');
    final s = PrayerSettings.defaultsFor('BD');
    final day = DateTime(2026, 11, 6);
    final t = service.forDay(dhaka, day, s);

    test('before Fajr: last night\'s Isha, Fajr next', () {
      final st = service.status(dhaka, t[Waqt.fajr].subtract(const Duration(minutes: 5)), s);
      expect(st.current, Waqt.isha);
      expect(st.next, Waqt.fajr);
      expect(st.currentStart.isBefore(DateTime(2026, 11, 6)), isTrue);
    });

    test('between Asr and Maghrib', () {
      final now = t[Waqt.asr].add(const Duration(minutes: 10));
      final st = service.status(dhaka, now, s);
      expect(st.current, Waqt.asr);
      expect(st.next, Waqt.maghrib);
      expect(st.remaining(now), t[Waqt.maghrib].difference(now));
      expect(st.isPast(Waqt.dhuhr, now), isTrue);
      expect(st.isPast(Waqt.asr, now), isFalse);
    });

    test('after Isha: tomorrow\'s Fajr next', () {
      final st = service.status(dhaka, t[Waqt.isha].add(const Duration(hours: 1)), s);
      expect(st.current, Waqt.isha);
      expect(st.next, Waqt.fajr);
      expect(st.nextAt.day, 7);
    });

    test('exactly at a boundary the new waqt has begun', () {
      expect(service.status(dhaka, t[Waqt.dhuhr], s).current, Waqt.dhuhr);
    });
  });

  group('regional defaults', () {
    test('methods', () {
      expect(PrayerSettings.defaultsFor('SA').method, CalcMethod.ummAlQura);
      expect(PrayerSettings.defaultsFor('TR').method, CalcMethod.turkey);
      expect(PrayerSettings.defaultsFor('ID').method, CalcMethod.singapore);
      expect(PrayerSettings.defaultsFor('US').method, CalcMethod.isna);
      expect(PrayerSettings.defaultsFor('FR').method, CalcMethod.mwl);
      expect(PrayerSettings.defaultsFor(null).method, CalcMethod.mwl);
    });
    test('Hanafi unless changed in Settings', () {
      for (final cc in ['PK', 'MA', 'SA', 'ID', null]) {
        expect(PrayerSettings.defaultsFor(cc).madhab, Madhab.hanafi, reason: '$cc');
      }
      expect(PrayerSettings.defaultsFor('MA').asr, AsrSchool.hanafi);
    });
    test('older settings: Asr school becomes the madhab; Tehran falls back to MWL', () {
      expect(PrayerSettings.fromJson({'method': 'karachi', 'asr': 'hanafi'})!.madhab, Madhab.hanafi);
      expect(PrayerSettings.fromJson({'method': 'mwl', 'asr': 'standard'})!.madhab, Madhab.shafii);
      expect(PrayerSettings.fromJson({'method': 'tehran'})!.method, CalcMethod.mwl);
      expect(CalcMethod.byName('tehran'), isNull);
    });
    test('zenith restriction by school', () {
      final friday = DateTime(2026, 11, 13), monday = DateTime(2026, 11, 16);
      for (final (m, fri, mon) in [
        (Madhab.hanafi, true, true),
        (Madhab.hanbali, true, true),
        (Madhab.shafii, false, true),
        (Madhab.maliki, false, false),
      ]) {
        final c = MomentConfig(madhab: m);
        expect((c.zawalRestricted(friday), c.zawalRestricted(monday)), (fri, mon), reason: m.name);
      }
    });
    test('json round-trip', () {
      const s = PrayerSettings(
        method: CalcMethod.egypt,
        madhab: Madhab.hanafi,
        highLatitude: HighLatitudeRule.twilightAngle,
      );
      expect(PrayerSettings.fromJson(s.toJson()), s);
      expect(PrayerSettings.fromJson({'method': 'nope'}), isNull);
    });
  });
}
