# Moment rules: for scholar review

The Moment Engine (`lib/domain/moments/`) turns prayer times into windows.
Every margin below is a **fiqh decision**, so each one lives in `MomentConfig` and none is hard-coded.
Defaults are common, conservative choices. A qualified reviewer should confirm or change each one before public launch.

The "prayer day" runs from Fajr to the next Fajr. When several moments overlap, the highest priority becomes the hero.

| Moment | Window | Default margin | Priority | Needs ruling |
|---|---|---|---|---|
| Last hour of Friday | Maghrib − 60 min → Maghrib, Fridays | 60 min | 90 | Which narration/understanding of the "hour"; fixed 60 min vs. a fraction of Asr→Maghrib |
| Jumu'ah | Fajr → Maghrib, Fridays | — | 20 | Whether the day starts at Maghrib on Thursday (Islamic day) for content like Surat al-Kahf |
| Iftar | Maghrib → + 20 min, Ramadan days | 20 min | 88 | — |
| Suhoor | Fajr − 45 min → Fajr, before Ramadan days | 45 min | 86 | Length of the window; imsak margin if any |
| Odd night of the last ten | Maghrib → Fajr on the nights of 21, 23, 25, 27, 29 Ramadan | — | 84 | Labelled as an odd night, never as Laylat al-Qadr itself |
| Last third of the night | Fajr − (Fajr − Maghrib)/3 → Fajr | — | 85 | Night = Maghrib→Fajr (used) vs. Isha→Fajr or sunset→sunrise |
| Between adhan and iqamah | Adhan → adhan + delay | Fajr 20, Dhuhr 15, Asr 15, Maghrib 5, Isha 15 min | 80 | Local mosque practice; to be user-adjustable |
| After the prayer | Iqamah + 10 min (salah) → end of that waqt (Fajr → sunrise, Isha → Fajr) | 10 min | 75 | Whether post-salah adhkar should be shown for the whole waqt |
| Sun rising (restricted) | Sunrise → + 15 min | 15 min | 70 | Margin (10–20 min commonly cited) |
| Sun at zenith (restricted) | Dhuhr − 10 min → Dhuhr | 10 min | 70 | Margin (5–10 min commonly cited) |
| Sun setting (restricted) | Maghrib − 15 min → Maghrib | 15 min | 70 | Whether to flag only the final yellowing, or all of after-Asr |
| Bedtime | max(Isha, usual bedtime 21:00) → + 3 h, clipped to Fajr | 21:00 / 3 h | 65 | None (user preference) |
| Morning adhkar | Fajr → Sunrise | — | 60 | End time: sunrise vs. Duha vs. Dhuhr |
| Evening adhkar | Asr → Maghrib | — | 60 | Asr→Maghrib vs. Maghrib→Isha (both are cited) |
| Duha | End of sunrise restriction → start of zawal | — | 50 | Preferred part of the window (later is often cited) |
| Waqt (Fajr…Isha, "Morning") | Prayer time → next prayer time | — | 10 | — |

Texts attached to moments come from HadeethEnc.com (Arabic, translation, grade, explanation) and are listed per moment in `lib/data/sources/days.dart` and the content catalogue.

## Day-level occasions (header pill)
Ramadan *n*, last ten nights, Eid al-Fitr (1 Shawwal), Eid al-Adha (10 Dhul Hijjah), Arafah (9 Dhul Hijjah), first ten of Dhul Hijjah (1–9), Tashreeq (11–13 Dhul Hijjah), Ashura (10 Muharram), Tasu'a (9 Muharram), Ayyam al-Bid (13–15, excluding Ramadan and 13 Dhul Hijjah), Jumu'ah, Monday/Thursday fast (not in Ramadan, on Eid or in Tashreeq).
These use the Umm al-Qura date plus the user's ±2 day adjustment. **Needs ruling:** whether to show anything for days on which a local moon sighting may differ.

## Reminders (notifications)
Only the most rewarded moments, each saying what to do and why, with its source. Times and wording to review:

| Reminder | When | Default |
|---|---|---|
| Start of Ramadan | Maghrib + 25 min on the evening before 1 Ramadan | on |
| Dhul Hijjah | Evening before 1 Dhul Hijjah, and before 9 Dhul Hijjah (Arafah) | on |
| Eid | Evening before 1 Shawwal and 10 Dhul Hijjah | on |
| Tasu'a, Ashura | Evenings before 9 and 10 Muharram | on |
| White days | Evening before the 13th (not Ramadan, not 13 Dhul Hijjah) | on |
| Monday / Thursday fast | Sunday and Wednesday evenings (not in Ramadan, Eid, Tashreeq) | off |
| Jumu'ah | Friday, sunrise + 40 min | on |
| Hour of Friday | Start of the last hour before Maghrib | on |
| Suhoor, iftar, odd nights | Moment starts in Ramadan | on |
| Morning/evening adhkar, last third, bedtime | Moment starts | off |

At most one eve reminder per evening (most important first). Dates follow the chosen Hijri authority, so Ramadan and Eid eves can shift by a day with the sighting. Text: `remTitle` / `remBody` in `lib/l10n/*.arb`.

## Reviewer sign-off
Fill in one line per row of the tables above, then send this file back (or open a pull request). Changes go into `MomentConfig` and this file together.

| Moment / occasion | Agree with default? | Change to | Evidence / note | Reviewer | Date |
|---|---|---|---|---|---|
| | | | | | |

## Prayer times against official tables
Drop official timetables into `test/fixtures/timetables/` (format in the README there) and run
`flutter test test/domain/official_timetables_test.dart`. Every prayer more than 2 minutes off is reported per city and date.
