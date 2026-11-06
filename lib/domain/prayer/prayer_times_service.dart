import 'package:adhan/adhan.dart' as adhan;

import 'package:timezone/timezone.dart' as tz;

import '../location/place.dart';
import '../time/place_zone.dart';
import 'prayer_settings.dart';

/// The six daily markers shown in the prayer strip.
enum Waqt { fajr, sunrise, dhuhr, asr, maghrib, isha }

/// Prayer times for one civil day at the place, as wall-clock times in the
/// place's time zone (the phone's zone if the place's is unknown).
class DayTimes {
  DayTimes(this.date, this._times, {this.estimated = false});

  final DateTime date;

  /// True when computed with the polar fallback rather than the real latitude.
  final bool estimated;
  final Map<Waqt, DateTime> _times;

  DateTime operator [](Waqt w) => _times[w]!;
}

/// Where "now" sits in the prayer day.
class PrayerStatus {
  const PrayerStatus({
    required this.today,
    required this.current,
    required this.currentStart,
    required this.next,
    required this.nextAt,
  });

  final DayTimes today;

  /// The waqt now in progress. Before today's Fajr this is the previous
  /// night's Isha.
  final Waqt current;
  final DateTime currentStart;
  final Waqt next;
  final DateTime nextAt;

  Duration remaining(DateTime now) => nextAt.difference(now);

  /// Strip highlighting: has this marker of *today* already passed?
  bool isPast(Waqt w, DateTime now) => !today[w].isAfter(now) && w != current;
}

/// Thin, pure wrapper around the `adhan` package. Offline and deterministic.
class PrayerTimesService {
  const PrayerTimesService();

  /// Beyond this, the sun can stay up or down all day and the angle maths has
  /// no answer. We then use the nearest-latitude method (aqrab al-bilad):
  /// compute at ±65° on the same meridian and flag the result as estimated.
  static const polarFallbackLatitude = 65.0;

  /// [day]'s calendar fields name a date *at the place*.
  DayTimes forDay(Place place, DateTime day, PrayerSettings settings) {
    final zone = zoneOf(place);
    final date = zone == null
        ? DateTime(day.year, day.month, day.day)
        : tz.TZDateTime(zone, day.year, day.month, day.day);
    try {
      return _compute(place.latitude, place.longitude, date, zone, settings, estimated: false);
    } on ArgumentError {
      final lat = place.latitude.sign * polarFallbackLatitude;
      return _compute(lat, place.longitude, date, zone, settings, estimated: true);
    }
  }

  DayTimes _compute(
    double lat,
    double lng,
    DateTime date,
    tz.Location? zone,
    PrayerSettings settings, {
    required bool estimated,
  }) {
    // utcOffset makes adhan return UTC instants; we then present them in the
    // place's zone. The date components are the place's calendar date.
    final pt = adhan.PrayerTimes.utc(
      adhan.Coordinates(lat, lng),
      adhan.DateComponents(date.year, date.month, date.day),
      settings.parametersFor(lat),
    );
    DateTime local(DateTime t) => inZone(t, zone);
    return DayTimes(date, estimated: estimated, {
      Waqt.fajr: local(pt.fajr),
      Waqt.sunrise: local(pt.sunrise),
      Waqt.dhuhr: local(pt.dhuhr),
      Waqt.asr: local(pt.asr),
      Waqt.maghrib: local(pt.maghrib),
      Waqt.isha: local(pt.isha),
    });
  }

  PrayerStatus status(Place place, DateTime now, PrayerSettings settings) {
    final today = forDay(place, now, settings);
    if (now.isBefore(today[Waqt.fajr])) {
      final yesterday = forDay(place, now.subtract(const Duration(days: 1)), settings);
      return PrayerStatus(
        today: today,
        current: Waqt.isha,
        currentStart: yesterday[Waqt.isha],
        next: Waqt.fajr,
        nextAt: today[Waqt.fajr],
      );
    }
    if (!now.isBefore(today[Waqt.isha])) {
      final tomorrow = forDay(place, now.add(const Duration(days: 1)), settings);
      return PrayerStatus(
        today: today,
        current: Waqt.isha,
        currentStart: today[Waqt.isha],
        next: Waqt.fajr,
        nextAt: tomorrow[Waqt.fajr],
      );
    }
    var current = Waqt.fajr;
    for (final w in Waqt.values) {
      if (!now.isBefore(today[w])) current = w;
    }
    final next = Waqt.values[current.index + 1];
    return PrayerStatus(today: today, current: current, currentStart: today[current], next: next, nextAt: today[next]);
  }
}
