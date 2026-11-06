import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock/clock.dart';
import '../core/theme/tokens.dart';
import '../data/places/place_repository.dart';
import '../data/user/user_prefs.dart';
import '../domain/hijri/hijri_service.dart';
import '../domain/moments/moment.dart';
import '../domain/moments/moment_engine.dart';
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
  final now = ref.watch(nowProvider).value ?? readNow(ref.watch(fakeClockProvider));
  final settings = ref.watch(prayerSettingsProvider);
  final svc = ref.watch(prayerTimesServiceProvider);
  DayTimes day(DateTime d, int plus) => svc.forDay(place, DateTime(d.year, d.month, d.day + plus), settings);

  // The prayer day runs Fajr → Fajr; before today's Fajr we're still in yesterday's.
  final today = day(now, 0);
  final d0 = now.isBefore(today[Waqt.fajr]) ? day(now, -1) : today;
  final d1 = day(d0.date, 1), d2 = day(d0.date, 2);
  return ref
      .watch(momentEngineProvider)
      .snapshot(now, PrayerDay(today: d0, tomorrow: d1), PrayerDay(today: d1, tomorrow: d2));
});

final prayerTimesServiceProvider = Provider((ref) => const PrayerTimesService());

final prayerSettingsProvider = Provider<PrayerSettings>((ref) {
  final prefs = ref.watch(userPrefsProvider);
  return prefs.prayer ?? PrayerSettings.defaultsFor(prefs.place?.countryCode);
});

/// `null` until a location is set.
final prayerStatusProvider = Provider<PrayerStatus?>((ref) {
  final place = ref.watch(userPrefsProvider.select((p) => p.place));
  if (place == null) return null;
  final now = ref.watch(nowProvider).value ?? readNow(ref.watch(fakeClockProvider));
  return ref.watch(prayerTimesServiceProvider).status(place, now, ref.watch(prayerSettingsProvider));
});

final hijriDateProvider = Provider<HijriDate>((ref) {
  final now = ref.watch(nowProvider).value ?? readNow(ref.watch(fakeClockProvider));
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
