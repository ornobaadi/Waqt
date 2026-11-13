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

## Phase 13 — Onboarding
- [x] Four screens on first launch, each in a time of day: welcome (dawn moon), language (sunrise script tiles), location (noon globe and pin), reminders (night bell with a real notification preview). Drawn, shaded objects with gentle loops; still under reduced motion.
- [x] Language chosen here or in Settings is saved (`locale.v1`) and used on every launch.
- [x] Both permissions explained first and skippable ("Choose a city instead", "Maybe later"). Older installs with a place skip onboarding.
- [ ] On-device check of GPS and notification prompts from onboarding.

## Phase 14 — Duas by task
- [x] Duas tab split into "Duas to say" (by task) and "Hadith" (the HadeethEnc library as before).
- [x] 30 duas in 8 tasks (Hisn al-Muslim's list and order), each tied to a HadeethEnc hadith. `tool/duas_data.py` holds only start/end markers; `tool/build_content.py` cuts the Arabic and each language's meaning out of HadeethEnc unchanged → `assets/sources/duas.json`. Where HadeethEnc's translation has no stand-alone meaning, the Arabic shows with a note.
- [x] Task list, one dua per page (when, times, Arabic, transliteration, meaning, reference, full hadith on request), "Right now" card for morning/evening, bedtime, after salah, iftar.
- [ ] Review: transliterations (ours) and the choice of excerpts, by a qualified reviewer.
- [ ] Meanings still missing: ur/bn/id/tr/fr for some items (HadeethEnc quotes only the Arabic there); 65913, 65997, 65919 are Arabic-only on HadeethEnc.

## Phase 15 — Quran reader
- [x] Tanzil Uthmani text bundled verbatim with its notice, and Tanzil metadata (surahs, juz, 604 pages) — `python tool/build_quran.py`. Amiri Quran font (OFL).
- [x] Quran tab (fifth dock tab): continue reading, "For this moment" (each tied to a bundled HadeethEnc hadith: al-Baqarah 285–286 at night, the three Quls, al-Mulk, al-Kahf 1–10), Surah / Juz / Saved.
- [x] Reader: each surah's basmala as Tanzil writes it, ayah marks, "You stopped here", tap an ayah to save, copy or recite from it; translation beneath.
- [x] Translations from QuranEnc.com, one per language (en Saheeh International, ur Junagarhi, bn Zakaria, id Kemenag, tr Rowwad, fr Rachid Maach), downloaded once, shown unchanged with version; translator's notes on tap.
- [x] Reading settings: Arabic size, translation, follow the recitation, keep the screen on.
- [x] IndoPak script: DigitalKhatt IndoPak text (MIT, pinned commit) cut into ayat at its own marks, checked against Tanzil (every ayah within one word); DigitalKhatt IndoPak font (OFL). Al-Fatihah numbered as Hafs (basmala = 1). Choice in reading settings.
- [ ] Al-Kahf on Friday: no HadeethEnc hadith yet; add when a sourced one is reviewed.
- [ ] Log Quran reading as a habit on Today (`DeedsNotifier.setHabit`).

## Phase 16 — Recitation
- [x] Five reciters (Alafasy, Husary, Abdul Basit, Ghamdi, Muaiqly) from EveryAyah.com, ayah by ayah: the recited ayah is highlighted and followed.
- [x] just_audio + audio_service: plays with the screen off, lock-screen and headset controls; speed 0.75–1.5×.
- [x] Per-surah downloads per reciter (resumable), Wi-Fi only unless mobile data is allowed; streaming otherwise.
- [ ] Written permission from EveryAyah before the store release (or move to a source that grants it). Email drafted: `docs/permissions/everyayah-request.md`.
- [ ] On-device checks: Android 14/15 foreground service, lock screen, Bluetooth buttons, offline playback.

## Phase 17 — Madhab, Quran on Today
- [x] Madhab (Hanafi, Shafi'i, Maliki, Hanbali): Hanafi by default, changed in Settings (not asked in onboarding); replaces the Asr setting. Witr shown as wajib (Hanafi) or stressed Sunnah (others). Sets the Asr time and the zenith restriction (`MomentConfig.zawalRestricted`). Tehran (Ja'fari) method removed; old settings move to MWL.
- [x] Quran reading on Today: ayat read in the reader count as the day's `quran` habit; a row under the ring shows it and opens the reader where you stopped.
- [x] Coverage pass: "Say the duas" on Home's Right now card opens the words for that moment (adhkar, bedtime, after salah, adhan, iftar). New sourced items: Witr, the twelve Sunnah rak'ahs, four before and after Dhuhr, Ayat al-Kursi and "a'inni" after salah, Friday (silence in the khutbah, not fasting Friday alone), Umrah in Ramadan, the sacrifice, a Sha'ban guide (fast much of it; not the day or two before Ramadan). New duas with their words: after the adhan, iftar, seeing the new moon (a ninth task, "Fasting and the new moon").
- [ ] Not on HadeethEnc, so not shown yet: the dua of Arafah, al-Kahf on Friday, the Eid takbir wording. Need a sourced, reviewed reference each (`referenced.dart`).
- [ ] Scholar check of the madhab rows in `docs/moment-rules.md`.
- [ ] Hadith sources: research and plan in `docs/hadith-sources.md` (keep HadeethEnc; referenced layer for gaps; ask for translation permissions).

## Phase 18 — Design pass against the canvas
- [x] Now (board 01): moments happening together share one Right now card with a tab each.
- [x] Today (board 02): Quran (where you stopped) and Dhikr (today's count) under the ring.
- [x] Quran (board 03): find a surah by number, common spelling ("yasin", "kahf"), English or Arabic name.
- [x] Dua page (board 12): larger/smaller text (Arabic, transliteration and meaning together) and copy with the source.
- [x] Reading settings (board 09): small and large A on the size slider.
- [x] Source lines: book and grade in the reader's language even where HadeethEnc has not translated the hadith yet (HadeethEnc's own wording for that book and grade); one line in lists.
- [x] Right now rows do the thing: Ayat al-Kursi opens the reader at 2:255, the 33-each and Fatimah tasbih open the after-salah counter, salawat and SubhanAllah wa bihamdihi open their dhikr, a row that is a dua opens its words. The hadith moved behind an info button (`ACTIONS` in build_content.py, `doItem` in library_views.dart).
- [x] Several moments at once: one tab bar, each tab on one line and sized to its name.
- [x] Onboarding greets with "Assalaamu Alaikum," (Instrument Serif italic, OFL; Arabic/Urdu/Bangla in their own fonts).
- [ ] Not built from the canvas yet: saved duas, share, transliteration toggle (no licensed source), repeat-ayah in the player, "Read al-Kahf" on Friday (no sourced hadith).

## Later
iOS · OTA signed content updates · more languages · cloud backup.

## First prompt for Claude Code
> Read PRD.md, architecture.md, design.md, phases.md. Start Phase 0 and Phase 1: scaffold the Flutter app with the structure in architecture.md, implement theme tokens from design.md, PrayerTimesService with adhan, and Home v0. Add a fake-clock debug override from the start. Do not add any religious text that isn't in the content DB.
