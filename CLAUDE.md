# CLAUDE.md — Waqt

Waqt shows the right dua for the moment you are in (last third of the night, Friday hour, after salah, Ramadan nights…), with a verified source for every item. Flutter, offline-first, Android first, global audience.

Read before larger work: `PRD.md` (what/why), `architecture.md` (layers, Moment Engine), `design.md` (tokens, UI rules), `phases.md` (checklist). Content workflow: `content/README.md`. Scholar margins: `docs/moment-rules.md`. Release: `docs/release.md`.

## Ground rules
- **Global, not regional.** No hard-coded country defaults or copy. Package `com.ornobaadi.waqt`. RTL (ar, ur) must always work.
- **Launch languages:** en (first), ar, ur, bn, id, tr, fr. Every new UI string goes into all seven ARBs (`lib/l10n/*.arb`); write natural phrasing, not literal translation.
- **Authenticity is non-negotiable.** Every hadith/dua shown has a source. Hadith now comes only from HadeethEnc.com (bundled for Home; full library downloaded per language). If a translation is missing, show the Arabic with a note — never fall back to English.
- **High-craft UI.** Follow `design.md`. Concentric radii (inner = outer − inset), rows inside cards are flat under hairlines, no nested rounded boxes.
- **Do not run heavy builds** (`flutter build apk/appbundle`, web builds). Verify with analyze + tests; produce screenshots with golden tests. Give the user build commands instead.
- **Commit at the end of each phase/feature** to `main` (github.com/ornobaadi/Waqt). Commit subjects are short, user-facing sentences (see `git log`).

## Commands
```
dart format -l 120 lib test && flutter analyze && flutter test --exclude-tags screenshots
flutter test --tags screenshots --update-goldens     # PNGs -> test/screenshots/goldens/
flutter gen-l10n                                     # after ARB edits
dart run build_runner build -d                       # Riverpod codegen
python tool/build_content.py                         # content/ YAML -> assets/content/content.json
```
Generated `lib/l10n/app_localizations*.dart` is reformatted at width 80 by gen-l10n; run the 120-column `dart format` before committing so diffs stay clean.

Builds (for the user to run): `flutter build apk --profile` (Waqt Dev, debug tools, drafts visible), `flutter build apk --release`, `flutter build appbundle --release`. Release hides unreviewed content.

## Layout
- `lib/app` — app, router (go_router), app state, sync
- `lib/core` — clock (fakeable), config (flavor = build mode, `runtime.dart` for kIsWeb-safe platform checks, test mode), theme tokens, shared widgets, diagnostics
- `lib/domain` — pure Dart: `moments/moment_engine.dart` (the heart), prayer times (adhan), Hijri, occasions, moon, place time zones, reminder planner
- `lib/data` — content repository, HadeethEnc sources/library, places (GeoNames), Hijri calendar sync, user prefs, checklists
- `lib/features` — qibla (precision-finding screen; heading from the native `waqt/heading` EventChannel in MainActivity.kt: fused rotation vector, true north; fallback magnetometer maths; drawn per frame with a short settle), now (Home: sky shader, sun arc, moment cards, prayer windows, Ramadan, sighting), today, duas library, counter (misbaha), calendar, settings (adjust, city picker, reminders, reading, developer/test mode, reference checker)
- `lib/platform` — GPS, local notifications, home-screen widget bridge
- `content/` YAML source of truth → `assets/content/`; `tool/` build scripts; `shaders/sky.frag`
- `test/` — domain, data, app, content pipeline, screenshots (goldens)

Key behaviours: prayer times and moments run in the **chosen city's** IANA zone, not the phone's. Reminders (`domain/notifications/reminder_planner.dart`) cover only the most rewarded moments: eves of Ramadan, Dhul Hijjah/Arafah, Eid, Tasu'a/Ashura, white days; Friday morning and last hour; suhoor/iftar/odd nights; daily adhkar opt-in. Each has a title and body with its source (`remTitle`/`remBody` select strings). Daily ones planned 7 days ahead, special days 31; re-planned on launch/resume/settings change (no background worker). Test mode has a fake clock, fast-forward and one-tap scenarios (29 Sha'ban, suhoor, iftar, 27th night, Eid, Arafah, Ashura…).

## Status (Nov 2026)
Done: phases 0–10 — foundations; prayer times + high-latitude rules; Moment Engine with tests across cities/DST; content pipeline; core UI (sun arc, sky shader, moon phase, palette crossfade); reminders + widget; misbaha counter with per-dhikr memory and daily totals; Hijri occasions + Ramadan mode + live Hijri calendar + moon-sighting card; 7-language UI with Nastaliq/Bengali fonts and 200% text; place time zones; special-day guides; HadeethEnc hadith in the app's language; reading sizes; haptics; crash report by email; web runs. Phase 11: Qibla finder, privacy policy on GitHub Pages (https://ornobaadi.github.io/Waqt/privacy/), reviewer sign-off + official-timetable test harness. Brand: app icon, splash, feature graphic and store screenshots are generated by `tool/brand/*.py` (headless Chrome); publishing steps in `docs/publish-checklist.md`.
Latest ordering rule: newest moment on top; after-salah lasts until the waqt ends; bedtime from 21:00.

Open / human-blocked (see `phases.md`): scholar review of moment margins and content approval; native-speaker review of UI strings; comparison with official national timetables; on-device checks (exact alarms Android 12–15, OEM battery, widget launchers, TalkBack, budget-device profiling); Rive assets; licensed recitation audio; official timetable CSVs; closed beta.
Keep `phases.md` updated when finishing a phase.
