import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock/clock.dart';
import '../core/theme/tokens.dart';
import '../data/places/place_repository.dart';
import '../data/user/user_prefs.dart';
import '../domain/hijri/hijri_service.dart';
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

/// Phase 1: palette follows the current waqt. Phase 2's Moment Engine refines
/// this (last third, bedtime…). Enum equality means dependents rebuild only
/// when the waqt actually changes, not every second.
final activePaletteProvider = Provider<MomentPalette>((ref) {
  final override = ref.watch(paletteOverrideProvider);
  if (override != null) return override;
  final current = ref.watch(prayerStatusProvider.select((s) => s?.current));
  return switch (current) {
    Waqt.fajr => MomentPalette.fajr,
    Waqt.sunrise || Waqt.dhuhr || null => MomentPalette.dhuhr,
    Waqt.asr => MomentPalette.asr,
    Waqt.maghrib => MomentPalette.maghrib,
    Waqt.isha => MomentPalette.night,
  };
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
