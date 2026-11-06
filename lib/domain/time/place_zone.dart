import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../location/place.dart';

/// The day is lived in the *place's* time zone, not the phone's: someone in
/// London checking Makkah sees Makkah's Fajr at Makkah's clock time.
///
/// Rule of thumb for the domain: compare instants freely (isBefore works
/// across zones), but build wall-clock times only through [wallClock], so
/// they land in the same zone as the day they belong to.

bool _ready = false;

void ensureTimeZones() {
  if (_ready) return;
  tzdata.initializeTimeZones();
  _ready = true;
}

/// The IANA zone for [place], or null (use the phone's zone) if unknown.
tz.Location? zoneOf(Place? place) {
  final id = place?.timeZone;
  if (id == null || id.isEmpty) return null;
  ensureTimeZones();
  try {
    return tz.getLocation(id);
  } on Object {
    return null;
  }
}

/// [t] as wall-clock time in [zone] (same instant).
DateTime inZone(DateTime t, tz.Location? zone) => zone == null ? deviceTime(t) : tz.TZDateTime.from(t, zone);

/// [t] in the phone's zone. Not `t.toLocal()`: on a TZDateTime that returns
/// the timezone package's `tz.local` (UTC unless set), not the device zone.
DateTime deviceTime(DateTime t) => DateTime.fromMillisecondsSinceEpoch(t.millisecondsSinceEpoch);

/// A wall-clock time in the same zone as [ref]. Out-of-range fields
/// normalise like [DateTime] (day + 1 at month end, etc.).
DateTime wallClock(DateTime ref, int year, int month, int day, [int hour = 0, int minute = 0]) => ref is tz.TZDateTime
    ? tz.TZDateTime(ref.location, year, month, day, hour, minute)
    : DateTime(year, month, day, hour, minute);

/// True when the place keeps a different clock from the phone right now.
bool differsFromDevice(tz.Location? zone, DateTime instant) {
  if (zone == null) return false;
  return tz.TZDateTime.from(instant, zone).timeZoneOffset != deviceTime(instant).timeZoneOffset;
}
