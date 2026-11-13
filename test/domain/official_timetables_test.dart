import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:waqt/domain/location/place.dart';
import 'package:waqt/domain/prayer/prayer_settings.dart';
import 'package:waqt/domain/prayer/prayer_times_service.dart';

/// Compares our times with official tables dropped into
/// test/fixtures/timetables/*.csv (see the README there). With no tables
/// present the test has nothing to check and passes.
const tolerance = Duration(minutes: 2);
const columns = {
  'fajr': Waqt.fajr,
  'sunrise': Waqt.sunrise,
  'dhuhr': Waqt.dhuhr,
  'asr_time': Waqt.asr,
  'maghrib': Waqt.maghrib,
  'isha': Waqt.isha,
};

void main() {
  tzdata.initializeTimeZones();
  final dir = Directory('test/fixtures/timetables');
  final files = dir.existsSync()
      ? (dir.listSync().whereType<File>().where((f) => f.path.endsWith('.csv')).toList()
          ..sort((a, b) => a.path.compareTo(b.path)))
      : <File>[];

  if (files.isEmpty) {
    test('no official timetables yet', () {});
    return;
  }

  for (final file in files) {
    test('matches ${file.uri.pathSegments.last} within 2 min', () {
      final lines = file.readAsLinesSync().where((l) => l.trim().isNotEmpty).toList();
      final head = lines.first.split(',').map((s) => s.trim()).toList();
      final misses = <String>[];
      for (final line in lines.skip(1)) {
        final v = line.split(',').map((s) => s.trim()).toList();
        String col(String k) => v[head.indexOf(k)];
        final place = Place(
          name: col('city'),
          countryCode: 'XX',
          latitude: double.parse(col('lat')),
          longitude: double.parse(col('lng')),
          timeZone: col('tz'),
        );
        final settings = PrayerSettings(
          method: CalcMethod.values.byName(col('method')),
          madhab: col('asr') == 'hanafi' ? Madhab.hanafi : Madhab.shafii,
        );
        final date = DateTime.parse(col('date'));
        final ours = const PrayerTimesService().forDay(place, date, settings);
        for (final MapEntry(key: name, value: w) in columns.entries) {
          if (!head.contains(name) || col(name).isEmpty) continue;
          final [h, m] = col(name).split(':').map(int.parse).toList();
          final t = ours[w];
          final diff = Duration(minutes: (t.hour * 60 + t.minute) - (h * 60 + m));
          if (diff.abs() > tolerance) {
            misses.add(
              '${place.name} ${col('date')} $name: official ${col(name)}, ours '
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} '
              '(${diff.inMinutes > 0 ? '+' : ''}${diff.inMinutes} min)',
            );
          }
        }
      }
      expect(misses, isEmpty, reason: misses.join('\n'));
    });
  }
}
