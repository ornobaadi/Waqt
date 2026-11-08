# Play Store listing

Everything to paste into Play Console. Step-by-step order: `docs/publish-checklist.md`.

## Store settings
- **App name** (30): `Waqt: Prayer Times, Dua, Qibla`
- **Category:** Lifestyle
- **Tags:** Religion & spirituality, Prayer times
- **Contact email:** ornobaadi.dev@gmail.com
- **Website:** https://ornobaadi.github.io/Waqt/
- **Privacy policy:** https://ornobaadi.github.io/Waqt/privacy/

## Short description (80)
`Prayer times, Qibla & the sunnah dua for every moment, Friday and Ramadan.`

## Full description (4000)
Waqt knows which moment of the day you are in, and shows the dua and sunnah that fit it, each with its source.

**The right dua for this moment**
The last third of the night, the hour before Maghrib on Friday, between adhan and iqamah, after the prayer, Duha, bedtime, suhoor, iftar and the odd nights of Ramadan. Waqt works these moments out from your own prayer times and puts the right words in front of you.

**Every hadith with its source**
Each hadith shows its collection, its grade and an explanation, from HadeethEnc.com, in your language. Where a translation is not available yet, Waqt shows the Arabic rather than guessing.

**Prayer times you can trust**
Calculated on your phone with twelve methods, including Umm al-Qura, Diyanet, JAKIM, Kemenag, ISNA, Egyptian, Karachi and MWL. Standard or Hanafi Asr, high-latitude rules, and minute adjustments to match your mosque. Works fully offline.

**Qibla finder**
Turn your phone until the Kaaba mark glows. Shows the direction in degrees and your distance to Makkah.

**Ramadan and the special days**
Suhoor and iftar times, Laylat al-Qadr nights, Eid, Arafah, Ashura, the white days and Monday and Thursday fasts, with what to do on each. A live Hijri calendar follows the announced moon sighting, or your own local sighting.

**Calm by design**
Gentle reminders you choose, a home-screen widget, a sky that follows the time of day, the real moon phase, and a tasbih counter that remembers your count. No ads, no accounts, no tracking.

**For Muslims everywhere**
English, العربية, اردو, বাংলা, Bahasa Indonesia, Türkçe and Français, with full right-to-left support.

## Graphics
| Asset | File | Spec |
|---|---|---|
| App icon | `docs/store/play-icon-512.png` | 512×512 PNG |
| Feature graphic | `docs/store/feature-graphic.png` | 1024×500 PNG |
| Phone screenshots | `docs/store/screenshots/01…08_*.png` | 1080×1920, upload in order |

Regenerate: `python tool/brand/waqt_icon.py` (icon, feature graphic, Android icons) and
`flutter test --tags screenshots --update-goldens && python tool/brand/store_screens.py` (screenshots).

## App content answers
- **Privacy policy:** URL above.
- **Ads:** No, the app does not contain ads.
- **App access:** All functionality is available without special access (no login).
- **Content rating (IARC questionnaire):** Category "Reference, News, or Educational" → answer **No** to violence, sexuality, language, controlled substances, gambling, user interaction/chat, sharing location with others, and digital purchases. Expected rating: Everyone / PEGI 3.
- **Target audience:** 13 and over (choosing under-13 brings in the Families policy; the app is suitable for all ages but is not designed for children).
- **News app:** No. **Government app:** No. **Financial features:** None. **Health:** No.

## Data safety form
- **Does your app collect or share any of the required user data types?** No.
  - Location is used only on the device to calculate prayer times and is never sent anywhere, so under Play's definition it is not "collected".
  - The app downloads public files (Hijri month start dates from api.aladhan.com, the hadith library from github.com) without sending any user data.
- **Is all data encrypted in transit?** Yes (HTTPS only).
- **Can users request data deletion?** Not applicable: no data leaves the device. Uninstalling removes everything.

## Permissions (for reviewers, if asked)
| Permission | Why |
|---|---|
| ACCESS_COARSE_LOCATION | Prayer times for where you are. City-level only and optional: a city can be picked by hand |
| POST_NOTIFICATIONS | Prayer and moment reminders the user turns on |
| SCHEDULE_EXACT_ALARM | Reminders at the exact prayer minute (a prayer-times app is a listed core use). Falls back to inexact alarms if declined |
| RECEIVE_BOOT_COMPLETED | Re-arm reminders and the widget after a restart |
| INTERNET | Hijri month dates and the optional hadith library download |
| VIBRATE | Haptics on the tasbih counter |

Sensors used without a permission: accelerometer and magnetometer, only while the Qibla screen is open.
