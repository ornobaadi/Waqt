import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/domain/location/place.dart';
import 'package:waqt/domain/prayer/prayer_settings.dart';
import 'package:waqt/domain/prayer/prayer_times_service.dart';

void main() {
  const svc = PrayerTimesService();
  final day = DateTime(2027, 2, 20);
  const dhaka = Place(name: 'Dhaka', countryCode: 'BD', latitude: 23.8103, longitude: 90.4125);
  // Chattogram is east of Dhaka: its times come earlier.
  const ctg = Place(name: 'Chattogram', countryCode: 'BD', latitude: 22.3569, longitude: 91.7832);
  final base = PrayerSettings.defaultsFor('BD');

  test('minute adjustments move suhoor (Fajr) and iftar (Maghrib), nothing else', () {
    final a = svc.forDay(dhaka, day, base);
    final b = svc.forDay(dhaka, day, base.copyWith(minutes: {'fajr': -2, 'maghrib': 3}));
    expect(b[Waqt.fajr].difference(a[Waqt.fajr]).inMinutes, -2);
    expect(b[Waqt.maghrib].difference(a[Waqt.maghrib]).inMinutes, 3);
    expect(b[Waqt.dhuhr], a[Waqt.dhuhr]);
  });

  test('adjustments survive saving, and bad values are dropped or clamped', () {
    final s = base.copyWith(minutes: {'maghrib': 3});
    expect(PrayerSettings.fromJson(s.toJson()), s);
    final j = {
      ...base.toJson(),
      'minutes': {'maghrib': 99, 'bogus': 1, 'isha': 'x'},
    };
    expect(PrayerSettings.fromJson(j)!.minutes, {'maghrib': PrayerSettings.maxMinutes});
  });

  test('each place keeps its own minutes: districts of one country differ', () {
    final d = svc.forDay(dhaka, day, base), c = svc.forDay(ctg, day, base);
    expect(d[Waqt.maghrib].difference(c[Waqt.maghrib]).inMinutes, greaterThanOrEqualTo(3));
  });
}
