import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/data/hijri/calendar_sync.dart';
import 'package:waqt/domain/hijri/hijri_service.dart';

/// A month as api.aladhan.com returns it: one entry per day.
String month(int y, int m, DateTime start, int days) => jsonEncode({
  'code': 200,
  'data': [
    for (var d = 1; d <= days; d++)
      {
        'hijri': {
          'day': '$d',
          'month': {'number': m, 'days': days},
          'year': '$y',
        },
        'gregorian': {
          'date': () {
            final g = start.add(Duration(days: d - 1));
            return '${g.day.toString().padLeft(2, '0')}-${g.month.toString().padLeft(2, '0')}-${g.year}';
          }(),
        },
      },
  ],
});

void main() {
  test('announced months decide the date; Umm al-Qura fills the gaps', () {
    // Ramadan announced as 30 days from 8 Feb 2027, Shawwal from 10 Mar.
    final table = MonthTable({
      (1448, 9): (start: DateTime(2027, 2, 8), days: 30),
      (1448, 10): (start: DateTime(2027, 3, 10), days: 29),
    });
    final s = HijriService(table: table);
    expect(s.dateFor(DateTime(2027, 3, 9, 12)), const HijriDate(1448, 9, 30));
    expect(s.dateFor(DateTime(2027, 3, 10, 12)), const HijriDate(1448, 10, 1));
    // After Maghrib on the 30th, the date is already 1 Shawwal.
    expect(s.dateFor(DateTime(2027, 3, 9, 19), maghrib: DateTime(2027, 3, 9, 18)), const HijriDate(1448, 10, 1));
    // Outside the table: the calculated calendar.
    expect(s.dateFor(DateTime(2027, 6, 1, 12)), const HijriService().dateFor(DateTime(2027, 6, 1, 12)));
  });

  test('download reads month starts and lengths, rejects odd data', () async {
    CalendarSync.fetch = (uri) async {
      expect(uri.host, 'api.aladhan.com');
      expect(uri.queryParameters['calendarMethod'], 'HJCoSA');
      final m = int.parse(uri.pathSegments[2]), y = int.parse(uri.pathSegments[3]);
      // Every month 29 days from an arbitrary anchor: enough to test parsing.
      return month(y, m, DateTime(2027, 1, 1).add(Duration(days: 29 * (m - 1))), m == 9 ? 30 : 29);
    };
    final t = await CalendarSync.download('HJCoSA', DateTime(2027, 2, 20));
    expect(t.months.length, 4);
    expect(t.month(1448, 9)!.days, 30);
    expect(CalendarSync.decode(CalendarSync.encode(t)).months, t.months);

    CalendarSync.fetch = (_) async => jsonEncode({'code': 200, 'data': []});
    expect(() => CalendarSync.download('HJCoSA', DateTime(2027, 2, 20)), throwsA(anything));
  });

  test('corrupt cache falls back to nothing, not a crash', () {
    expect(CalendarSync.decode('not json').isEmpty, isTrue);
    expect(CalendarSync.decode(null).isEmpty, isTrue);
  });
}
