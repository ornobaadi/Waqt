# Architecture — Waqt

## Stack
- **Flutter** (stable), Android first (minSdk 24), iOS later.
- State: **Riverpod** (`riverpod_generator`).
- Routing: **go_router**.
- Local DB: **Drift** (SQLite), content DB shipped as a bundled asset, read-only.
- User state (checklists, settings, favourites): Drift user DB or `shared_preferences` for simple settings.
- Prayer times: **`adhan`** Dart package (offline).
- Hijri: **`hijri`** package + user offset.
- Location: `geolocator` + offline city list fallback (no reverse-geocode dependency required).
- Notifications: `flutter_local_notifications` + `timezone`; `android_alarm_manager_plus` or WorkManager for daily rescheduling.
- Widget: `home_widget` (Android Glance/RemoteViews).
- Animation: `flutter_animate`, **Rive** for illustrative objects, **fragment shaders** for the sky.
- Audio: `just_audio`.
- i18n: `flutter_localizations` + ARB from day one; Arabic + Urdu RTL; script fonts per language (Noto Naskh Arabic, Noto Nastaliq Urdu, Noto Sans Bengali).

## Layered structure
```
lib/
  core/            # theme tokens, typography, utils, clock stream
  data/
    content/       # Drift content DB (read-only asset), DAOs
    user/          # settings, checklist progress, favourites
  domain/
    prayer/        # PrayerTimesService (adhan wrapper)
    hijri/         # HijriService (+ offset)
    moments/       # MomentEngine, rules, models
  features/
    now/           # home screen
    today/         # timeline
    duas/          # library + detail sheet
    settings/
    onboarding/
  platform/
    notifications/ # scheduler
    widget/        # home_widget bridge
content/           # source-of-truth YAML/JSON + build script → content.db
```

## Moment Engine (the heart)
Pure Dart, deterministic, fully unit-tested.

```dart
class MomentContext {
  DateTime now; Location loc; PrayerTimes today, tomorrow;
  HijriDate hijri; int weekday; UserPrefs prefs;
}

abstract class MomentRule {
  String id;                    // e.g. "last_third_night"
  int priority;                 // higher wins the hero card
  TimeWindow? window(MomentContext c); // null = inactive today
}
```
- Rules return windows computed from prayer times, e.g.
  - `last_third_night`: `fajr - (fajr - maghrib)/3 … fajr`
  - `friday_last_hour`: weekday==Fri, `maghrib - 60min … maghrib`
  - `disliked_sunrise`: `sunrise … sunrise + ~15–20 min` (exact margin = scholar decision, configurable)
  - `bedtime`: `max(isha, prefs.bedtime) … prefs.bedtime + 2h`
- Engine outputs `List<ActiveMoment>` sorted by priority → hero = first; "coming up" = next 2 future windows; timeline = all windows today.
- Each `moment_id` links to content items via `moment_content` table (ordered).
- **UI theming is derived from engine output** (moment → palette/sky/accent). This is the "generative UI": deterministic composition, no LLM.

## Content pipeline
1. Content authored in `content/*.yaml` (one file per moment / collection), reviewed via PRs.
2. CI script validates schema: every item must have source fields; `review_status` must be `approved` for release builds.
3. Script compiles to `assets/content.db` + content version number.
4. Optional later: OTA content updates (signed DB download), still offline-first.

### Schema (simplified)
```
content_item(id, kind[dua|etiquette|action], arabic, translit, title)
translation(item_id, lang, text, translator)
source(item_id, type[quran|hadith], collection, number, narrator,
       grade, graded_by, url)
review(item_id, status[draft|checked|approved], reviewer, date, notes)
moment(id, name, priority, palette_key)
moment_content(moment_id, item_id, order)
```

## Notifications
- On app open + daily at ~00:05 (and after reboot / timezone / location change): compute next 48 h of windows, schedule enabled ones.
- Android 12+: request `SCHEDULE_EXACT_ALARM` only for adhan; others use inexact. Android 13+: `POST_NOTIFICATIONS`.
- Onboarding step for battery-optimisation exemption on aggressive OEMs (Xiaomi, Oppo, Vivo, Samsung).

## Performance targets
- Cold start < 1.5 s on a budget device; 60 fps on home; sky shader < 2 ms/frame; respect "reduce motion".

## Testing
- Golden tests per moment (home screen at fixed fake clocks: Fri 16:20, Sat 03:10, 22:15 …).
- MomentEngine unit tests across latitudes (Dhaka, London, Oslo summer — high-latitude rules!) and DST zones.
- Prayer times compared with official national tables per region (Umm al-Qura, Diyanet, JAKIM, Kemenag, ISNA, Egyptian GAS, Islamic Foundation BD …).
