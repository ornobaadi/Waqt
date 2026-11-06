# Phases — Waqt

Each phase ends with a shippable internal build. Content work runs in parallel from Phase 0.

## Phase 0 — Foundations (week 1)
- [x] Flutter project, flavors (dev/prod), lint, CI (format, analyze, test)
- [x] Folder structure per `architecture.md`; Riverpod + go_router
- [x] Theme tokens from `design.md` (moment palettes, type, radii) as `ThemeExtension`
- [x] ARB localisation set up (en only), RTL check with Arabic strings
- [ ] Decide: translation licence, scholar reviewer, weak-hadith policy

## Phase 1 — Prayer times & clock (weeks 2–3)
- [x] `PrayerTimesService` (adhan), calculation method + Asr setting
- [x] Location: GPS + manual city picker, cache last location
- [x] `HijriService` + offset setting
- [x] Live clock stream (minute tick, second precision for countdown)
- [x] Home v0: header, clock, current waqt, countdown, prayer strip
- [x] High-latitude handling (auto rule + polar nearest-latitude fallback); cross-checked vs AlAdhan in 6 cities
- [ ] Compare against official national tables (human task: collect PDFs per region)

## Phase 2 — Moment Engine (weeks 3–4)
- [x] Rule interface + rules: last third, Friday last hour, adhan↔iqamah, disliked times, Duha, bedtime, morning/evening adhkar, post-salah
- [x] Priority resolution → hero / coming up / timeline
- [x] Fake-clock debug panel (jump to any date/time) — essential for QA
- [x] Unit tests across cities and DST

Margins awaiting scholar review: see `docs/moment-rules.md`.

## Phase 3 — Content system (parallel, weeks 1–6)
- [x] YAML schema + validator + build script → `assets/content/content.json` (JSON instead of SQLite for v1; see architecture.md)
- [x] Draft v1 catalogue as candidate references (23 items, all `draft`, no text)
- [ ] Fill text + grading from primary sources (human)
- [ ] Human verification against sunnah.com / quran.com (status `checked`)
- [ ] Scholar review (status `approved`)

## Phase 4 — Core UI (weeks 5–7)
- [ ] Sun arc + night-thirds widgets (CustomPainter), animated
- [ ] Right Now card, reference chips, coming-up tiles
- [ ] Moment-driven theming (palette crossfade)
- [ ] Today timeline
- [ ] Dua detail bottom sheet (Arabic, translit, translation, source panel, link-out)
- [ ] Checklists (bedtime, Jumu'ah) with daily reset
- [ ] Duas library + search
- [ ] Golden tests per moment

## Phase 5 — Notifications & widget (weeks 8–9)
- [ ] Scheduler (48 h horizon, reschedule on boot/tz/location change)
- [ ] Per-moment toggles; adhan sound option
- [ ] Permission + battery-optimisation onboarding
- [ ] Home-screen widget (current waqt + next prayer)

## Phase 6 — Delight (weeks 10–11)
- [ ] Sky fragment shader + moon phase; tilt parallax; reduce-motion fallback
- [ ] Rive objects (lantern, misbaha counter, prayer mat)
- [ ] Audio playback for duas (licensed source)
- [ ] Hijri occasions: Ramadan, Dhul Hijjah, Arafah, Ashura, Ayyam al-Bid, Mon/Thu

## Phase 7 — Localisation & launch prep (weeks 12–14)
- [ ] Arabic, Urdu, Bengali, Indonesian, Turkish, French UI strings and translations of content (licensed, reviewed)
- [ ] Accessibility pass (TalkBack, contrast, font scaling to 200%)
- [ ] Performance on budget devices; crash reporting (privacy-respecting)
- [ ] "Report an issue with this content" flow
- [ ] Play Store listing, privacy policy (location stays on device)
- [ ] Closed beta → public launch

## Later
iOS · OTA signed content updates · more languages · Qibla · cloud backup.

## First prompt for Claude Code
> Read PRD.md, architecture.md, design.md, phases.md. Start Phase 0 and Phase 1: scaffold the Flutter app with the structure in architecture.md, implement theme tokens from design.md, PrayerTimesService with adhan, and Home v0. Add a fake-clock debug override from the start. Do not add any religious text that isn't in the content DB.
