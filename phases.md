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
- [x] Sun arc + night-thirds widgets (CustomPainter), animated
- [x] Right Now card, reference chips, coming-up tiles
- [x] Moment-driven theming (palette crossfade)
- [x] Today timeline
- [x] Dua detail bottom sheet (Arabic, translit, translation, source panel, link-out)
- [x] Checklists (bedtime, Jumu'ah) with daily reset
- [x] Duas library + search
- [x] Golden tests per moment

## Phase 5 — Notifications & widget (weeks 8–9)
- [x] Scheduler: 7-day horizon instead of 48 h + daily job (no background worker needed); re-plans on launch, resume, place/settings/reminder/language change; plugin re-arms after reboot
- [x] Per-moment toggles; sound on/off (adhan recording waits for a licensed source, Phase 6)
- [x] Permission + battery-optimisation onboarding (one-time card on Now, Reminders screen with status + OEM hint)
- [x] Home-screen widget (current waqt + next prayer, live countdown, moment colours, refreshes at each boundary)
- [ ] Verify on devices: exact alarms (Android 12–15), Xiaomi/Samsung battery behaviour, widget on 2–3 launchers

## Phase 6 — Delight (weeks 10–11)
- [x] Sky fragment shader (30 fps cap, gradient fallback) + real moon phase (hemisphere-aware); tilt parallax; static with reduce-motion
- [x] Misbaha counter (native, haptics, 33/99/100)
- [ ] Rive lantern + prayer mat: need `.riv` assets from a designer
- [ ] Audio playback for duas: blocked on a licensed recitation source
- [x] Hijri occasions: Ramadan (+ suhoor, iftar, odd nights of last ten), Dhul Hijjah, Arafah, Eids, Tashreeq, Ashura/Tasu'a, Ayyam al-Bid, Mon/Thu

## Phase 7 — Localisation & launch prep (weeks 12–14)
- [x] UI strings: Arabic, Urdu, Bengali, Indonesian, Turkish, French; Nastaliq + Bengali fonts, per-locale script fallback
- [ ] Native-speaker review of UI strings (drafted, not yet reviewed)
- [ ] Content translations (licensed, reviewed): blocked on Phase 3 approvals
- [x] Accessibility: 200% text (clock fits, strip becomes 3×2, labels wrap), contrast tests, semantics labels
- [ ] TalkBack walkthrough on a device
- [x] Crash log on device + user-reviewed report (no SDK); shader 30 fps cap
- [ ] Profile on a budget device
- [x] "Report an issue with this content" flow (pre-filled GitHub issue)
- [x] Play Store listing draft, privacy policy, release guide, upload-key signing, adaptive + themed app icon
- [x] Host privacy policy (https://ornobaadi.github.io/Waqt/privacy/)
- [x] Feature graphic, new app icon (sujood under the crescent), splash, store screenshots (`docs/store/`)
- [ ] Closed beta → public launch

## Phase 8 — Place time zones
- [x] Prayer times, moments, bedtime, Hijri switch and widget run in the chosen city's zone (IANA id from GeoNames), not the phone's
- [x] "{city} time" note on Now when the city's clock differs from the phone's
- [x] Tests: London/Toronto from a Dhaka-time machine, both DST changeovers, bedtime at 22:30 local, unknown-zone fallback

## Phase 9 — Home first, reports, release test mode
- [x] Home-first layout, email problem reports, no adhan alerts, test mode in release builds

## Phase 10 — Library, special days, Ramadan, HadeethEnc
- [x] Prayer windows on Home, dhikr picker, haptics, reading sizes
- [x] Special-day guides, Hijri calendar, moon sighting, Ramadan mode
- [x] HadeethEnc hadith in the app's language (bundled for Home, library downloaded per language)

## Phase 11 — Qibla and content trust
- [x] Qibla finder: tilt-compensated heading, turn arc, aligned haptic, no-compass fallback, 7 languages
- [x] Privacy policy on GitHub Pages
- [x] Reviewer sign-off table in `docs/moment-rules.md`; official-timetable comparison test (`test/fixtures/timetables/`)
- [ ] Collect official timetables (Diyanet, JAKIM, Kemenag, Islamic Foundation BD, UOIF…) as CSVs
- [x] Qibla: fused rotation-vector heading at game rate, true north (World Magnetic Model), per-frame rendering, precision-finding design

## Phase 12 — Deeds (salah, fasting, habits)
- [x] Tick each prayer on the Now strip (tap = prayed, on time or made up by the clock; long-press = on time / jama'ah / qada / clear). Stored per prayer day, per month, on the phone only.
- [x] Today ring (five arcs) pinned above the timeline; streak with "never miss twice".
- [x] Strip as colour-only beads: green on time, amber made up, sapphire congregation; the current bead drains as its time passes.
- [x] Progress: month figures, editable week of beads, each prayer over 30 days, last 12 weeks.
- [ ] Fasting and habits: set aside for now (salah only).
- [ ] "Did you pray?" prompt after a waqt ends unticked.

## Later
iOS · OTA signed content updates · more languages · cloud backup.

## First prompt for Claude Code
> Read PRD.md, architecture.md, design.md, phases.md. Start Phase 0 and Phase 1: scaffold the Flutter app with the structure in architecture.md, implement theme tokens from design.md, PrayerTimesService with adhan, and Home v0. Add a fake-clock debug override from the start. Do not add any religious text that isn't in the content DB.
