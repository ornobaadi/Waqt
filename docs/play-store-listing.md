# Play Store listing

Everything to paste into Play Console. Step-by-step order: `docs/publish-checklist.md`.

## Store settings
- **App name** (30): `Waqt: Quran, Dua, Prayer Times`
- **Category:** Lifestyle
- **Tags:** Religion & spirituality, Prayer times
- **Contact email:** ornobaadi.dev@gmail.com
- **Website:** https://ornobaadi.github.io/Waqt/
- **Privacy policy:** https://ornobaadi.github.io/Waqt/privacy/

## Short description (80)
`Quran with audio, the right dua for each moment, prayer times and Qibla. No ads.`

## Full description (4000)
Same text as `docs/store/full-description.txt` (paste that file; 3,725 characters).

Waqt is the Muslim companion that knows what time it is in your day: it reads the Quran with you, gives you the right dua for the moment you are in, and keeps your prayer times, Qibla and salah in one calm place. Every hadith and dua comes with its source. No ads, no account, no tracking.

✦ THE QURAN, AYAH BY AYAH
Read all 114 surahs in the Uthmani or IndoPak script. Each ayah shows the Arabic, how to say it in English letters, and its meaning in your language, with the translator's notes one tap away. Save an ayah with a double-tap, copy it with a long press, and pick up right where you stopped.

✦ LISTEN TO BEAUTIFUL RECITATION
Five renowned reciters: Mishary Alafasy, Mahmoud Al-Husary, Abdul Basit, Saad Al-Ghamdi and Maher Al-Muaiqly. The page follows the ayah being recited. Change the speed, download surahs to listen offline, and pause from your lock screen or any screen of the app.

✦ AYAT AL-KURSI AND THE PASSAGES YOU LOOK FOR
Ayat al-Kursi, the last two ayat of al-Baqarah, al-Fatihah, al-Kahf on Friday, al-Mulk before sleep, the three Quls morning and evening: found in one tap, each with the authentic hadith on why it is read. Waqt puts the one for this moment first.

✦ THE RIGHT DUA FOR EVERY MOMENT
The last third of the night, the last hour of Friday, between adhan and iqamah, after the prayer, Duha, bedtime, suhoor, iftar and the odd nights of Ramadan. Waqt works these moments out from your own prayer times and puts the right words in front of you.

✦ DUAS FOR ALL YOU DO
14 categories, from waking up to going to sleep: morning and evening adhkar, wudu and salah, the mosque, food, travel, rain and wind, sneezing and weddings, illness and hardship, protection, loss and grief, istikhara, and asking Allah for guidance and a firm heart. One dua per page: the Arabic, how to say it, its meaning and its reference.

✦ EVERY HADITH WITH ITS SOURCE
Each hadith shows its collection, its grade and an explanation, from HadeethEnc.com, in your language. Where a translation does not exist yet, Waqt shows the Arabic rather than guessing.

✦ PRAYER TIMES YOU CAN TRUST
Calculated on your phone with eleven methods, including Umm al-Qura, Diyanet, ISNA, Egyptian, Karachi, Muslim World League, Moonsighting Committee and the Singapore method used across Southeast Asia. Choose your madhab (Hanafi, Shafi'i, Maliki or Hanbali) for Asr, with high-latitude rules and minute adjustments to match your mosque.

✦ TRACK YOUR SALAH, GENTLY
Mark each prayer on time, in congregation or made up. See your day on a ring next to the ayat you read and the dhikr you said, and your week at a glance. A missed prayer is something to make up, never a red mark. Everything stays on your phone.

✦ REMINDED WHEN IT MATTERS MOST
The evening before Arafah, Ashura, Eid or the white days, the night Ramadan begins, every Friday and every Ramadan suhoor: Waqt tells you what to do and why, with its source. You choose which; daily reminders stay off unless you turn them on.

✦ RAMADAN AND THE SPECIAL DAYS
Suhoor and iftar times, Laylat al-Qadr nights with its dua, Eid, Arafah, Ashura, the white days and the Monday and Thursday fasts, with what to do on each. A live Hijri calendar follows the announced moon sighting, or your own.

✦ QIBLA FINDER AND TASBIH
Turn your phone until the Kaaba mark glows, with the direction in degrees and your distance to Makkah. A tasbih counter remembers your count and today's total.

✦ CALM BY DESIGN
A sky that follows the time of day, the real moon phase, a home-screen widget and a dark palette for the night. Made to be simple enough for a child.

✦ FOR MUSLIMS EVERYWHERE
English, العربية, اردو, বাংলা, Bahasa Indonesia, Türkçe and Français, with full right-to-left support.

## Graphics
| Asset | File | Spec |
|---|---|---|
| App icon | `docs/store/play-icon-512.png` | 512×512 PNG |
| Feature graphic | `docs/store/feature-graphic.png` | 1024×500 PNG |
| Phone screenshots | `docs/store/screenshots/01…08_*.png` | 1080×1920, upload in order |

Regenerate: `python tool/brand/waqt_icon.py` (icon, Android icons) and
`flutter test --tags screenshots --update-goldens && python tool/brand/store_screens.py` (feature graphic and screenshots).

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
