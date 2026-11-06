# Play Store listing: draft

## App name
Waqt: Prayer Times & Duas

## Short description (≤ 80)
Prayer times and the right dua for this moment, every item with a verified source.

## Full description
Waqt knows what moment of the day it is, and shows what fits it.

**Prayer times, calculated on your phone**
Twelve calculation methods, including Umm al-Qura, Diyanet, JAKIM/Kemenag, ISNA, Egyptian, Karachi and MWL. Standard or Hanafi Asr. High-latitude rules, with an honest estimate where the sun never sets. Works fully offline.

**Moments, not just clocks**
Last third of the night, the last hour of Friday, between adhan and iqamah, after the prayer, Duha, bedtime, and Ramadan's suhoor, iftar and odd nights. Every window is derived from your real prayer times.

**Only verified sources**
Every dua and action carries its reference: collection, number, narrator and grading. Only sahih and hasan narrations, checked against the primary source and approved by a scholar before they appear.

**Calm by design**
Gentle reminders you choose, a home-screen widget, a sky that follows the day, the real moon phase, and a tasbih counter. No ads, no accounts, no tracking.

**For Muslims everywhere**
English, العربية, اردو, বাংলা, Bahasa Indonesia, Türkçe and Français. Hijri date with local moon-sighting adjustment.

## Category
Lifestyle (alternative: Books & Reference)

## Content rating
Everyone. No user-generated content, no ads, no in-app purchases.

## Data safety form
- Data collected: **None**
- Data shared: **None**
- Location: used **on device only** for app functionality; not collected (Play's definition: not transmitted off the device).
- Encrypted in transit: not applicable (nothing transmitted).
- Data deletion: all data is local; uninstalling removes it.

## Permissions to declare / justify
| Permission | Why |
|---|---|
| ACCESS_COARSE_LOCATION | Prayer times for where you are (city-level only, optional) |
| POST_NOTIFICATIONS | Prayer and moment reminders the user turns on |
| SCHEDULE_EXACT_ALARM | Prayer reminders at the exact minute. A prayer-times app is a listed core use case; the app falls back to inexact alarms if declined |
| RECEIVE_BOOT_COMPLETED | Re-arm reminders and the widget after a restart |

## Assets
- Icon: `docs/store/play-icon-512.png`
- Screenshots: `docs/screenshots/phase7/` (use 04, 06, 13, 16, 17, 30_*, at 1170×2532, cropped to 9:16 if needed)
- Feature graphic (1024×500): to make. Use the night sky + clock.

## Before submitting
- [ ] Privacy policy hosted at a public URL (e.g. GitHub Pages from `docs/privacy-policy.md`)
- [ ] At least the v1 bedtime + after-salah items **approved** (otherwise the release shows no duas)
- [ ] Upload key created and `android/key.properties` set (see `docs/release.md`)
- [ ] Closed testing track with 12+ testers for 14 days (required for new personal developer accounts)
