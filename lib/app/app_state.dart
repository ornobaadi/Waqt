import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock/clock.dart';
import '../data/hijri/calendar_sync.dart';
import '../core/theme/tokens.dart';
import '../data/places/place_repository.dart';
import '../data/user/user_prefs.dart';

import 'package:timezone/timezone.dart' as tz;

import '../domain/hijri/hijri_service.dart';
import '../domain/location/place.dart';
import '../domain/time/place_zone.dart';
import '../domain/moments/moment.dart';
import '../domain/moments/moment_config.dart';
import '../domain/moments/moment_engine.dart';
import '../domain/notifications/reminder_planner.dart';
import '../data/user/notification_prefs.dart';
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

final momentEngineProvider = Provider(
  (ref) => MomentEngine(config: MomentConfig(madhab: ref.watch(prayerSettingsProvider.select((s) => s.madhab)))),
);

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
  final offset = ref.watch(hijriOffsetProvider);
  HijriDate h(DayTimes d) =>
      ref.watch(hijriServiceProvider).dateFor(d.date.add(const Duration(hours: 12)), offset: offset);
  PrayerDay pd(DayTimes a, DayTimes b) => PrayerDay(today: a, tomorrow: b, hijri: h(a), hijriNext: h(b));
  return ref.watch(momentEngineProvider).snapshot(now, pd(d0, d1), pd(d1, d2));
});

/// The Hijri calendar in use: the chosen authority's announced months where
/// downloaded, Umm al-Qura otherwise.
final hijriServiceProvider = Provider<HijriService>(
  (ref) => HijriService(table: ref.watch(calendarSyncProvider.select((s) => s.table))),
);

/// The user's ±2 day adjustment applies only to local sighting; an
/// authority's announced dates are taken as they are.
final hijriOffsetProvider = Provider<int>((ref) {
  final local = ref.watch(calendarSyncProvider.select((s) => s.authority)) == HijriAuthority.local;
  return local ? ref.watch(userPrefsProvider.select((p) => p.hijriOffset)) : 0;
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
  final offset = ref.watch(hijriOffsetProvider);
  final h = ref.watch(hijriServiceProvider).dateFor(day, offset: offset);
  return (date: h, list: occasionsFor(h, now.weekday));
});

/// Tomorrow's occasions, for "fast tomorrow" in the evening.
final tomorrowOccasionsProvider = Provider<List<OccasionId>>((ref) {
  final now = ref.watch(placeNowProvider);
  final day = DateTime(now.year, now.month, now.day + 1, 12);
  final offset = ref.watch(hijriOffsetProvider);
  return occasionsFor(ref.watch(hijriServiceProvider).dateFor(day, offset: offset), day.weekday);
});

final hijriDateProvider = Provider<HijriDate>((ref) {
  final now = ref.watch(placeNowProvider);
  final maghrib = ref.watch(prayerStatusProvider.select((s) => s?.today[Waqt.maghrib]));
  final offset = ref.watch(hijriOffsetProvider);
  final service = ref.watch(hijriServiceProvider);
  final evening = service.dateFor(now, maghrib: maghrib, offset: offset);
  final daytime = service.dateFor(now, offset: offset);
  // The evening of the 29th of a month whose end depends on the crescent:
  // until the sighting is known, the date stays the 29th rather than
  // claiming a new month that may not have begun.
  if (evening != daytime && daytime.day == 29 && const {8, 9, 11, 12}.contains(daytime.month)) {
    final sync = ref.watch(calendarSyncProvider);
    final next = daytime.month == 12 ? (daytime.year + 1, 1) : (daytime.year, daytime.month + 1);
    final known = sync.authority == HijriAuthority.local
        ? ref.watch(sightingAnswersProvider).contains(sightingKey(next.$1, next.$2))
        : sync.table.lookup(DateTime(now.year, now.month, now.day + 1)) != null;
    if (!known) return daytime;
  }
  return evening;
});

/// Fix → nearest named city → saved. Returns the error, or null on success.
Future<GpsError?> locateWithGps(WidgetRef ref) async {
  try {
    final fix = await currentFix();
    final repo = await ref.read(placeRepositoryProvider.future);
    // The nearest city names the place; the times use the phone's own
    // position, so two towns in one district get their own minutes.
    final city = repo.nearest(fix.lat, fix.lng);
    ref
        .read(userPrefsProvider.notifier)
        .setPlace(city.copyWith(latitude: fix.lat, longitude: fix.lng, source: PlaceSource.gps));
    return null;
  } on GpsException catch (e) {
    return e.error;
  }
}

/// The language the person chose; `null` follows the device. Saved, so a
/// choice made in onboarding or Settings survives a restart.
class LocaleOverride extends Notifier<Locale?> {
  static const _key = 'locale.v1';

  @override
  Locale? build() {
    final code = ref.read(sharedPrefsProvider).getString(_key);
    return code == null ? null : Locale(code);
  }

  void set(Locale? l) {
    final sp = ref.read(sharedPrefsProvider);
    l == null ? sp.remove(_key) : sp.setString(_key, l.languageCode);
    state = l;
  }
}

final localeOverrideProvider = NotifierProvider<LocaleOverride, Locale?>(LocaleOverride.new);

/// Prayer days from yesterday to [count] days ahead, each with its Hijri dates,
/// so the planner sees Ramadan, Arafah, Ashura and the rest.
List<PrayerDay> planningDays({
  required Place place,
  required PrayerSettings settings,
  required PrayerTimesService times,
  required HijriService hijri,
  required int offset,
  required DateTime now,
  int count = 33,
}) {
  DayTimes day(int plus) => times.forDay(place, DateTime(now.year, now.month, now.day + plus), settings);
  HijriDate h(DayTimes d) => hijri.dateFor(d.date.add(const Duration(hours: 12)), offset: offset);
  final t = [for (var i = -1; i <= count; i++) day(i)];
  return [
    for (var i = 0; i + 1 < t.length; i++)
      PrayerDay(today: t[i], tomorrow: t[i + 1], hijri: h(t[i]), hijriNext: h(t[i + 1])),
  ];
}

/// The reminders that would be scheduled now, for the Reminders screen's
/// "coming up" and the setup card. Recomputed once a minute, not every tick.
final upcomingRemindersProvider = Provider<List<PlannedReminder>>((ref) {
  final place = ref.watch(userPrefsProvider.select((p) => p.place));
  if (place == null) return const [];
  final now = ref.watch(placeNowProvider.select((n) => DateTime(n.year, n.month, n.day, n.hour, n.minute)));
  final days = planningDays(
    place: place,
    settings: ref.watch(prayerSettingsProvider),
    times: ref.watch(prayerTimesServiceProvider),
    hijri: ref.watch(hijriServiceProvider),
    offset: ref.watch(hijriOffsetProvider),
    now: now,
  );
  final enabled = ref.watch(notificationPrefsProvider.select((p) => p.enabled));
  return const ReminderPlanner().plan(now, days, enabled);
});
