import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/domain/astronomy/moon.dart';
import 'package:waqt/domain/hijri/hijri_service.dart';
import 'package:waqt/domain/location/place.dart';
import 'package:waqt/domain/moments/moment.dart';
import 'package:waqt/domain/moments/moment_engine.dart';
import 'package:waqt/domain/occasions/occasions.dart';
import 'package:waqt/domain/prayer/prayer_settings.dart';
import 'package:waqt/domain/prayer/prayer_times_service.dart';

const tue = DateTime.tuesday, mon = DateTime.monday, thu = DateTime.thursday, fri = DateTime.friday;

List<OccasionId> o(int m, int d, [int weekday = tue]) => occasionsFor(HijriDate(1448, m, d), weekday);

void main() {
  group('occasions', () {
    test('Eids, Arafah, Ashura, Tasu\'a', () {
      expect(o(10, 1).first, OccasionId.eidAlFitr);
      expect(o(12, 10).first, OccasionId.eidAlAdha);
      expect(o(12, 9).first, OccasionId.arafah);
      expect(o(12, 9), contains(OccasionId.firstTenDhulHijjah));
      expect(o(1, 10).first, OccasionId.ashura);
      expect(o(1, 9).first, OccasionId.tasua);
    });

    test('Ramadan and its last ten', () {
      expect(o(9, 5), [OccasionId.ramadan]);
      expect(o(9, 23).take(2), [OccasionId.lastTenNights, OccasionId.ramadan]);
    });

    test('Ayyam al-Bid: 13–15, but not in Ramadan and not on 13 Dhul Hijjah', () {
      expect(o(5, 14), contains(OccasionId.ayyamAlBid));
      expect(o(9, 14), isNot(contains(OccasionId.ayyamAlBid)));
      expect(o(12, 13), isNot(contains(OccasionId.ayyamAlBid)));
      expect(o(12, 13).first, OccasionId.tashreeq);
      expect(o(12, 14), contains(OccasionId.ayyamAlBid));
    });

    test('Monday/Thursday fasts, except Ramadan, Eid and Tashreeq', () {
      expect(o(5, 3, mon), [OccasionId.mondayFast]);
      expect(o(5, 3, thu), [OccasionId.thursdayFast]);
      expect(o(9, 3, mon), isNot(contains(OccasionId.mondayFast)));
      expect(o(10, 1, thu), isNot(contains(OccasionId.thursdayFast)));
      expect(o(12, 12, mon), isNot(contains(OccasionId.mondayFast)));
      expect(o(5, 3, fri), [OccasionId.jumuah]);
    });
  });

  group('moon', () {
    test('known phases (±1 day)', () {
      // New moon 2026-01-18 19:52 UTC, full moon 2026-03-03 11:38 UTC.
      final newMoon = moonAge(DateTime.utc(2026, 1, 18, 20));
      expect(newMoon < 1 / 29.5 || newMoon > 28.5 / 29.5, isTrue, reason: '$newMoon');
      expect((moonAge(DateTime.utc(2026, 3, 3, 12)) - 0.5).abs(), lessThan(1 / 29.5));
      expect(moonIllumination(DateTime.utc(2026, 3, 3, 12)), greaterThan(0.98));
    });
  });

  group('Ramadan moments', () {
    const dhaka = Place(name: 'Dhaka', countryCode: 'BD', latitude: 23.8103, longitude: 90.4125);
    const svc = PrayerTimesService();
    final s = PrayerSettings.defaultsFor('BD');
    PrayerDay day(DateTime d, HijriDate h, HijriDate next) => PrayerDay(
      today: svc.forDay(dhaka, d, s),
      tomorrow: svc.forDay(dhaka, d.add(const Duration(days: 1)), s),
      hijri: h,
      hijriNext: next,
    );
    const engine = MomentEngine();
    Set<MomentId> ids(PrayerDay d) => {for (final m in engine.timelineFor(d)) m.id};

    test('iftar on fasting days, suhoor before a fasting day', () {
      final eve = day(DateTime(2027, 2, 7), const HijriDate(1448, 8, 29), const HijriDate(1448, 9, 1));
      expect(ids(eve), contains(MomentId.suhoor));
      expect(ids(eve), isNot(contains(MomentId.iftar)));
      final last = day(DateTime(2027, 3, 8), const HijriDate(1448, 9, 29), const HijriDate(1448, 10, 1));
      expect(ids(last), contains(MomentId.iftar));
      expect(ids(last), isNot(contains(MomentId.suhoor)));
    });

    test('odd nights of the last ten, named by the night that follows Maghrib', () {
      final before23 = day(DateTime(2027, 3, 1), const HijriDate(1448, 9, 22), const HijriDate(1448, 9, 23));
      expect(ids(before23), contains(MomentId.laylatAlQadr));
      final before24 = day(DateTime(2027, 3, 2), const HijriDate(1448, 9, 23), const HijriDate(1448, 9, 24));
      expect(ids(before24), isNot(contains(MomentId.laylatAlQadr)));
    });

    test('suhoor outranks the last third at the end of the night', () {
      final d = day(DateTime(2027, 3, 1), const HijriDate(1448, 9, 22), const HijriDate(1448, 9, 23));
      final next = day(DateTime(2027, 3, 2), const HijriDate(1448, 9, 23), const HijriDate(1448, 9, 24));
      final at = d.tomorrow[Waqt.fajr].subtract(const Duration(minutes: 10));
      expect(engine.snapshot(at, d, next).hero.id, MomentId.suhoor);
    });
  });

  test("Sha'ban all month, alongside the white days", () {
    expect(o(8, 1), contains(OccasionId.shaban));
    expect(o(8, 14), containsAll([OccasionId.ayyamAlBid, OccasionId.shaban]));
    expect(o(9, 1), isNot(contains(OccasionId.shaban)));
  });
}
