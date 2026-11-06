import 'dart:math' as math;

/// Mean synodic month and a reference new moon (2000-01-06 18:14 UTC).
/// Accurate to well under a day: enough to draw the right crescent. Never
/// used to decide a Hijri date; that stays with the calendar + user offset.
const synodicMonth = 29.530588853;
final _refNewMoon = DateTime.utc(2000, 1, 6, 18, 14);

/// 0 = new, 0.25 = first quarter, 0.5 = full, 0.75 = last quarter.
double moonAge(DateTime t) {
  final days = t.toUtc().difference(_refNewMoon).inMinutes / 1440;
  final a = (days / synodicMonth) % 1;
  return a < 0 ? a + 1 : a;
}

/// Fraction of the disc that is lit, 0…1.
double moonIllumination(DateTime t) => (1 - math.cos(2 * math.pi * moonAge(t))) / 2;
