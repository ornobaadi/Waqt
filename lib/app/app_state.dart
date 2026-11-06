import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock/clock.dart';
import '../core/theme/tokens.dart';
import '../data/places/place_repository.dart';
import '../data/user/user_prefs.dart';

import 'package:timezone/timezone.dart' as tz;

import '../domain/hijri/hijri_service.dart';
import '../domain/time/place_zone.dart';
import '../domain/moments/moment.dart';
import '../domain/moments/moment_engine.dart';
import '../domain/occasions/occasions.dart';
import '../domain/prayer/prayer_settings.dart';
import '../domain/prayer/prayer_times_service.dart';
import '../platform/location/gps.dart';

/// The debug panel can override the palette to preview every moment.
class PaletteOverride extends Notifier<MomentPalette?> {
  @override
  MomentPalette? build() => null;
  void set(MomentPalette? p) => state = p;
}

final paletteOverrideProvider = NotifierProvider<PaletteOverride, MomentPalette?>(PaletteOverride.new);

/// The moment drives the sky: the hero moment picks the palette when it has
/// one of its own, otherwise the running waqt does. Enum equality means
/// dependents rebuild only when the palette actually changes.
final activePaletteProvider = Provider<MomentPalette>((ref) {
  final override = ref.watch(paletteOverrideProvider);
  if (override != null) return override;
  final ids = ref.watch(momentSnapshotProvider.select((s) => s == null ? null : (s.hero.id, s.waqt.id)));
  return paletteFor(ids?.$1, ids?.$2);
});

MomentPalette paletteFor(MomentId? hero, MomentId? waqt) {
  switch (hero) {
    case MomentId.lastThird:
      return MomentPalette.night;
    case MomentId.bedtime:
      return MomentPalette.bedtime;
    case MomentId.fridayLastHour:
      return MomentPalette.asr;
    default:
  }
  return switch (waqt) {
    MomentId.fajr => MomentPalette.fajr,
    MomentId.asr => MomentPalette.asr,
    MomentId.maghrib => MomentPalette.maghrib,
    MomentId.isha => MomentPalette.night,
    _ => MomentPalette.dhuhr,
  };
}

final momentEngineProvider = Provider((ref) => const MomentEngine());

/// `null` until a location is set.
final momentSnapshotProvider = Provider<MomentSnapshot?>((ref) {
  final place = ref.watch(userPrefsProvider.select((p) => p.place));
  if (place == null) return null;
  final now = ref.watch(placeNowProvider);
  final settings = ref.watch(prayerSettingsProvider);
  final svc = ref.watch(prayerTimesServiceProvider);
  DayTimes day(DateTime d, int plus) => svc.forDay(place, DateTime(d.year, d.month, d.day + plus), settings);

  // The prayer day runs Fajr → Fajr; before today's Fajr we're still in yesterday's.
  final today = day(now, 0);
  final d0 = now.isBefore(today[Waqt.fajr]) ? day(now, -1) : today;
  final d1 = day(d0.date, 1), d2 = day(d0.date, 2);
  final offset = ref.watch(userPrefsProvider.select((p) => p.hijriOffset));
  HijriDate h(DayTimes d) => const HijriService().dateFor(d.date.add(const Duration(hours: 12)), offset: offset);
  PrayerDay pd(DayTimes a, DayTimes b) => PrayerDay(today: a, tomorrow: b, hijri: h(a), hijriNext: h(b));
  return ref.watch(momentEngineProvider).snapshot(now, pd(d0, d1), pd(d1, d2));
});

final prayerTimesServiceProvider = Provider((ref) => const PrayerTimesService());

/// The place's time zone (null = the phone's).
final placeZoneProvider = Provider<tz.Location?>((ref) => zoneOf(ref.watch(userPrefsProvider.select((p) => p.place))));

/// "Now" as wall-clock time at the chosen place. Everything about the day
/// (prayer status, moments, Hijri date, the big clock) reads this.
final placeNowProvider = Provider<DateTime>((ref) {
  final now = ref.watch(nowProvider).value ?? readNow(ref.watch(fakeClockProvider));
  return inZone(now, ref.watch(placeZoneProvider));
});

final prayerSettingsProvider = Provider<PrayerSettings>((ref) {
  final prefs = ref.watch(userPrefsProvider);
  return prefs.prayer ?? PrayerSettings.defaultsFor(prefs.place?.countryCode);
});

/// `null` until a location is set.
final prayerStatusProvider = Provider<PrayerStatus?>((ref) {
  final place = ref.watch(userPrefsProvider.select((p) => p.place));
  if (place == null) return null;
  final now = ref.watch(placeNowProvider);
  return ref.watch(prayerTimesServiceProvider).status(place, now, ref.watch(prayerSettingsProvider));
});

/// Occasions of the current daylight Hijri day (they don't flip at Maghrib:
/// "Monday fast" stays Monday's until Monday ends).
final occasionsProvider = Provider<({HijriDate date, List<OccasionId> list})>((ref) {
  final now = ref.watch(placeNowProvider);
  final day = DateTime(now.year, now.month, now.day, 12);
  final offset = ref.watch(userPrefsProvider.select((p) => p.hijriOffset));
  final h = const HijriService().dateFor(day, offset: offset);
  return (date: h, list: occasionsFor(h, now.weekday));
});

final hijriDateProvider = Provider<HijriDate>((ref) {
  final now = ref.watch(placeNowProvider);
  final maghrib = ref.watch(prayerStatusProvider.select((s) => s?.today[Waqt.maghrib]));
  final offset = ref.watch(userPrefsProvider.select((p) => p.hijriOffset));
  return const HijriService().dateFor(now, maghrib: maghrib, offset: offset);
});

/// Fix → nearest named city → saved. Returns the error, or null on success.
Future<GpsError?> locateWithGps(WidgetRef ref) async {
  try {
    final fix = await currentFix();
    final repo = await ref.read(placeRepositoryProvider.future);
    ref.read(userPrefsProvider.notifier).setPlace(repo.nearest(fix.lat, fix.lng));
    return null;
  } on GpsException catch (e) {
    return e.error;
  }
}

/// `null` follows the device locale.
class LocaleOverride extends Notifier<Locale?> {
  @override
  Locale? build() => null;
  void set(Locale? l) => state = l;
}

final localeOverrideProvider = NotifierProvider<LocaleOverride, Locale?>(LocaleOverride.new);
