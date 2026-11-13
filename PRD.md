# PRD — Waqt

> Handoff context for Claude Code. Read this first, then `architecture.md`, `design.md`, `phases.md`.

## 1. One-liner
An Android app (Flutter) that always knows **what moment it is in a Muslim's day** and shows the authentic duas, prayers and etiquettes for that moment — every item backed by a verifiable Qur'an or hadith reference.

## 2. Problem
Muslims forget, or don't know, which dua or Sunnah fits the current moment (bedtime, last third of the night, Friday's last hour, after salah…). Finding it means searching the web, where sources are often weak, unreferenced or wrong.

## 3. Audience
Muslims worldwide — from newly practising Muslims to students of knowledge — on everything from budget to flagship Android phones. No region is privileged: calculation method, Asr school, Hijri offset, language and number formats all adapt to the user.

### Launch languages
| Language | Who it reaches |
|---|---|
| English | Global default; Muslims in the West, Africa and South Asia |
| Arabic | Middle East & North Africa; language of the source texts (RTL) |
| Urdu | Pakistan and India (RTL) |
| Bengali | Bangladesh and West Bengal |
| Indonesian | Indonesia, the largest Muslim-majority country |
| Turkish | Turkey and communities across Europe |
| French | West & North Africa and France |

English ships first; the others follow before public release (UI strings + licensed, reviewed content translations).

## 4. Product principles
1. **Authenticity over volume.** No content without a reference. Nothing is AI-generated.
2. **Moments, not clocks.** Windows are derived from astronomical prayer times (e.g. last third of night = last third of Maghrib→Fajr), never fixed hours.
3. **Three depths.** Glance (2 s) → Act (30 s) → Learn (sources, grading, context).
4. **Calm, not naggy.** Gentle, user-controlled reminders.
5. **Offline first.** Full content and prayer-time calculation work without internet.

## 5. Core features (MVP)
| # | Feature | Notes |
|---|---|---|
| F1 | **Home "Now" screen** | Live clock, current waqt, countdown to next prayer, Gregorian + Hijri date, occasion tag, sun arc (day) / night-thirds bar (night). |
| F2 | **Prayer times** | 5 prayers + sunrise on home. Calculation method + Asr juristic (Standard/Hanafi) in settings. GPS or manual city. |
| F3 | **Right Now card** | Title, one-line why, 2–3 actions each with a reference chip. |
| F4 | **Moment engine** | Rules that map (location, time, weekday, Hijri date) → active window(s) + content. |
| F5 | **Today timeline** | Every window of the day, past dimmed, current highlighted, disliked-prayer times flagged. |
| F6 | **Dua detail sheet** | Arabic, transliteration, translation, audio, source panel (collection, number, narrator, grade, grader, translator), link to sunnah.com / quran.com, scholar-review status. |
| F7 | **Checklists** | Bedtime Sunnah, Jumu'ah etiquette — tick-off with daily reset. |
| F8 | **Duas library** | Browse by situation; search. |
| F9 | **Notifications** | Prayer adhan/reminder, "last third begins", "Friday last hour", bedtime — each toggle-able. |
| F10 | **Home-screen widget** | Current waqt + next prayer countdown. |
| F11 | **Hijri adjustment** | ±2 days manual offset for local moon-sighting. |

## 6. Moment catalogue v1 (content to research & verify)
Daily: after Fajr (morning adhkar) · sunrise (disliked) · Duha/Ishraq · zawal (disliked) · Dhuhr · Asr · evening adhkar · sunset (disliked) · Maghrib · Isha · bedtime · last third of night · between adhan & iqamah · after each fard salah.
Weekly: Jumu'ah (night before, morning prep, khutbah etiquette, last hour before Maghrib) · Monday/Thursday fasting.
Hijri: Ayyam al-Bid (13–15) · Ramadan (suhoor, iftar, Laylat al-Qadr on odd nights of last 10) · first 10 of Dhul Hijjah · Arafah · Eid · Ashura & 9th Muharram.
Situational (library, not time-based): travel, rain, entering home/masjid, eating, distress, etc. (Hisn al-Muslim as base).

## 7. Content authenticity requirements (non-negotiable)
- Each content item stores: `arabic`, `transliteration`, `translation`, `translator`, `source_type` (quran/hadith), `collection`, `number`, `narrator`, `grade`, `graded_by`, `source_url`, `review_status`, `reviewed_by`, `version`.
- Only **sahih/hasan** for Sunnah claims. Weak narrations excluded or explicitly labelled (decide policy before content work; default = exclude).
- Every reference is checked against the primary source (sunnah.com / quran.com) by a human. A qualified scholar signs off before public launch.
- References currently in mockups (Abu Dawud 1047/1048, Bukhari 1145/247/2311/3705/5017/6324, Muslim 758/831, Qur'an 51:18, al-Hakim for Kahf) are **drafts from memory — verify every one**.
- An LLM may help *find candidate sources*; it may never be the final source of any text shown to users.

## 8. Non-goals (v1)
Qibla AR, social features, fatwa Q&A, ads, accounts/cloud sync. (The Qur'an reader and recitation were added in phases 15–16: Tanzil text, QuranEnc translations, EveryAyah audio.)

## 9. Success metrics
- D7 retention ≥ 35%; DAU/MAU ≥ 40%
- ≥ 50% of DAU open a dua detail weekly
- 0 unresolved content-accuracy reports older than 7 days
- Prayer-time deviation vs. official national tables (e.g. Umm al-Qura, Diyanet, JAKIM, Kemenag, ISNA, Islamic Foundation BD) ≤ 1 min

## 10. Open questions
- Name decided: **Waqt** (package `com.ornobaadi.waqt`). Still check Play Store & trademark.
- Translation licensing (per launch language).
- Audio recitation source + licence.
- Scholar reviewer(s) — who, and how is sign-off recorded?
- Default calculation method per country.
- Monetisation: free + donation? (Recommended: no ads.)

## 11. Design references
- v1 canvas: https://claude.ai/artifact/39nPfwUPu7zBapMi2eZdGK
- v2 canvas (current direction): https://claude.ai/artifact/QPq4a1m6w5jHmQvfxhyzar
