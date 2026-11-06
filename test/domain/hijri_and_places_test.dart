import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:waqt/core/utils/digits.dart';
import 'package:waqt/data/places/place_repository.dart';
import 'package:waqt/domain/hijri/hijri_service.dart';
import 'package:waqt/domain/location/place.dart';
import 'package:waqt/features/now/now_screen.dart' show formatCountdown;

void main() {
  setUpAll(initializeDateFormatting);
  const hijri = HijriService();

  group('hijri', () {
    final day = DateTime(2026, 11, 6, 12);
    final maghrib = DateTime(2026, 11, 6, 17, 15);
    final nextDay = hijri.dateFor(DateTime(2026, 11, 7, 12));

    test('advances at Maghrib, not midnight', () {
      expect(hijri.dateFor(day, maghrib: maghrib), isNot(nextDay));
      expect(hijri.dateFor(DateTime(2026, 11, 6, 17, 15), maghrib: maghrib), nextDay);
    });

    test('offset shifts by whole days and is clamped to ±2', () {
      expect(hijri.dateFor(day, offset: 1), nextDay);
      expect(hijri.dateFor(day, offset: 9), hijri.dateFor(day, offset: 2));
    });

    test('known date: 1 Ramadan 1447 is 18 Feb 2026 (Umm al-Qura)', () {
      expect(hijri.dateFor(DateTime(2026, 2, 18, 9)), const HijriDate(1447, 9, 1));
    });
  });

  group('places', () {
    final repo = PlaceRepository.parse(
      '# header\n'
          'Istanbul\tIstanbul\tTR\t41.0138\t28.9497\t14804116\tEurope/Istanbul\n'
          'São Paulo\tSao Paulo\tBR\t-23.5475\t-46.6361\t10021295\tAmerica/Sao_Paulo\n'
          'Isfahan\tIsfahan\tIR\t32.6525\t51.6746\t1547164\tAsia/Tehran\n'
          'Dakar\tDakar\tSN\t14.6937\t-17.4441\t2476400\tAfrica/Dakar\n',
      'TR\tTurkey\nBR\tBrazil\nIR\tIran\nSN\tSenegal\n',
    );

    test('prefix search, larger city first, accent-insensitive', () {
      expect(repo.search('is').map((p) => p.name), ['Istanbul', 'Isfahan']);
      expect(repo.search('sao p').single.name, 'São Paulo');
      expect(repo.search('  ').isEmpty, isTrue);
    });

    test('later-word match only at word start', () {
      expect(repo.search('paulo').single.name, 'São Paulo');
      expect(repo.search('stan').isEmpty, isTrue);
    });

    test('search by country name', () {
      expect(repo.search('senegal').single.name, 'Dakar');
    });

    test('nearest keeps exact coordinates and marks GPS', () {
      final p = repo.nearest(14.70, -17.40);
      expect(p.name, 'Dakar');
      expect(p.country, 'Senegal');
      expect(p.latitude, 14.70);
      expect(p.source, PlaceSource.gps);
    });

    test('json round-trip', () {
      final p = repo.search('dakar').single;
      expect(Place.fromJson(p.toJson()), p);
      expect(Place.fromJson({'lat': 'x'}), isNull);
    });
  });

  test('countdown format', () {
    final n = LocaleDigits('en');
    expect(formatCountdown(const Duration(hours: 1, minutes: 5, seconds: 9), n), '1:05:09');
    expect(formatCountdown(const Duration(minutes: 4, seconds: 2), n), '04:02');
    expect(formatCountdown(const Duration(seconds: -3), n), '00:00');
    // Digits always match the clock's DateFormat digits for the locale.
    expect(
      formatCountdown(const Duration(minutes: 57), LocaleDigits('ar')),
      DateFormat('mm:ss', 'ar').format(DateTime(2000, 1, 1, 0, 57)),
    );
  });
}
