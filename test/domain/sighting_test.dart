import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:waqt/data/sources/days.dart';
import 'package:waqt/domain/hijri/hijri_service.dart';
import 'package:waqt/domain/moments/moment.dart';
import 'package:waqt/domain/occasions/occasions.dart';
import 'package:waqt/features/now/sighting_card.dart';

import 'dart:io';

void main() {
  // The civil day that Umm al-Qura calls 29 Ramadan 1448.
  final g = HijriCalendar().hijriToGregorian(1448, 9, 29);
  final evening = DateTime(g.year, g.month, g.day, 20);
  const shawwal = (year: 1448, month: 10);

  test('seen: tomorrow becomes 1 Shawwal (Eid)', () {
    final o = offsetFor(evening, shawwal, seen: true)!;
    final t = const HijriService().dateFor(DateTime(g.year, g.month, g.day + 1, 12), offset: o);
    expect((t.month, t.day), (10, 1));
  });

  test('not seen: tomorrow is still Ramadan, Eid moves a day later', () {
    final o = offsetFor(evening, shawwal, seen: false)!;
    final t = const HijriService().dateFor(DateTime(g.year, g.month, g.day + 1, 12), offset: o);
    expect(t.month, 9);
    final after = const HijriService().dateFor(DateTime(g.year, g.month, g.day + 2, 12), offset: o);
    expect((after.month, after.day), (10, 1));
  });

  test('day guides: every occasion with a guide, fasting days marked, no weak grades', () {
    final d = DayGuides.parse(File('assets/sources/days.json').readAsStringSync());
    for (final o in [OccasionId.eidAlFitr, OccasionId.eidAlAdha, OccasionId.arafah, OccasionId.ashura]) {
      expect(d.forOccasion(o), isNotEmpty, reason: o.name);
    }
    expect(d.fasts, containsAll([OccasionId.arafah, OccasionId.ashura, OccasionId.mondayFast]));
    expect(d.fasts, isNot(contains(OccasionId.eidAlFitr)));
    for (final o in OccasionId.values) {
      for (final i in d.forOccasion(o)) {
        expect(i.he, greaterThan(0));
      }
    }
    expect(d.featured([OccasionId.eidAlFitr, OccasionId.jumuah]), OccasionId.eidAlFitr);
    expect(d.featured([OccasionId.jumuah]), isNull);
    // Moments that guide something have sourced items.
    for (final m in [
      MomentId.duha,
      MomentId.lastThird,
      MomentId.bedtime,
      MomentId.afterSalah,
      MomentId.morningAdhkar,
      MomentId.iftar,
      MomentId.taraweeh,
    ]) {
      expect(d.forMoment(m), isNotEmpty, reason: m.name);
    }
    // Ramadan items carry when they matter, for the folded checklist.
    expect(d.forOccasion(OccasionId.ramadan).every((i) => i.when != null), isTrue);
  });
}
