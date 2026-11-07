import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/domain/hijri/hijri_service.dart';

import '../helpers/harness.dart';

/// Every special day of the year, at every part of the day, in a
/// left-to-right and a right-to-left language: Home must build without an
/// exception or an overflow.
void main() {
  DateTime civilOf(int y, int m, int d) {
    var g = DateTime(2026, 11, 1, 12);
    while (const HijriService().dateFor(g) != HijriDate(y, m, d)) {
      g = g.add(const Duration(days: 1));
    }
    return g;
  }

  const days = [
    (1448, 8, 13), // white days
    (1448, 8, 29), // eve of Ramadan
    (1448, 9, 1),
    (1448, 9, 21), // last ten begin
    (1448, 9, 27),
    (1448, 9, 29), // eve of Eid (by Umm al-Qura)
    (1448, 10, 1), // Eid al-Fitr
    (1448, 10, 2),
    (1448, 11, 29), // eve of Dhul Hijjah
    (1448, 12, 1),
    (1448, 12, 9), // Arafah
    (1448, 12, 10), // Eid al-Adha
    (1448, 12, 11), // Tashreeq
    (1448, 12, 13),
    (1449, 1, 9), // Tasu'a
    (1449, 1, 10), // Ashura
  ];
  const hours = [(3, 30), (6, 40), (12, 30), (16, 20), (18, 30), (21, 30), (23, 50)];

  for (final locale in const [Locale('en'), Locale('ar')]) {
    for (final (y, m, d) in days) {
      testWidgets('${locale.languageCode} $d/$m/$y', (t) async {
        final c = civilOf(y, m, d);
        for (final (h, min) in hours) {
          await t.pumpWidget(await app(at: DateTime(c.year, c.month, c.day, h, min), place: dhaka, locale: locale));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: '$h:$min');
          // Scroll the whole of Home so every card is laid out.
          await t.drag(find.byType(Scrollable).first, const Offset(0, -4000));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: '$h:$min scrolled');
        }
      });
    }
  }
}
