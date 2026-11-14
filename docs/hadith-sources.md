# Hadith sources: what exists, what Waqt should use

Researched 13 Nov 2026. The goal is almost every authentic hadith, translated into en, ar, ur, bn, id, tr and fr. Each translation must have a known translator and a licence that allows an offline app, and nothing may be machine-translated.

## Candidates

| Source | Size | Languages | Translation quality | Licence / access | Verdict |
|---|---|---|---|---|---|
| **HadeethEnc.com** (current) | 3,582 hadith in Arabic. Per language: en 2,328, id 2,260, ur 2,220, tr 2,150, bn 1,925, fr 1,790 | All 7 | Human translators, reviewed, with a grade and an explanation per hadith; Sunni scholarship | Free API and SQLite downloads, attribution | **Keep as the backbone** |
| **fawazahmed0/hadith-api** | ~34,000 hadith in 9 books (Bukhari, Muslim, Abu Dawud, Tirmidhi, Nasa'i, Ibn Majah, Malik, Nawawi, Qudsi) | ara, ben, eng, fra, ind, tur, urd (French missing for Tirmidhi; ind/urd missing for Nawawi) | **Not reliable.** French Bukhari 6306 is a re-translation of the English (copyrighted Darussalam) text, keeping its English transliteration ("Rapporté par Shaddad bin Aus… A`udhu"). Bengali Bukhari 6306 holds Arabic chapter text, so numbering is misaligned | The repo says Unlicense, but its texts are scraped from sunnah.com, hadithbd, urdupoint and others. The repo cannot license translations it does not own | **Do not use** for translations. Its Arabic text and its grades (al-Albani, Arna'ut and others, named per hadith) are usable as a cross-check |
| **sunnah.com API** | The six books and more | Arabic and English (a few others partly) | Good, published translations | API key on request; no offline dump; reuse terms not published | Not usable offline in 7 languages |
| **Dorar.net** | Very large | Arabic only | Grades by named scholars | Website / search API | Cross-check for grades only |

**Result:** no database has "almost every authentic hadith" in all 7 languages with clean licences and human translations. The largest that does is HadeethEnc. A bigger collection would have to show the Arabic with a "no translation in your language" note for most hadith, which is the rule the app already follows.

## Madhab and hadith
- The four Sunni schools (Hanafi, Shafi'i, Maliki, Hanbali) share the same creed and accept the same authentic hadith. They differ in **fiqh** (how a ruling is derived), not in which duas are allowed. The adhkar of Hisn al-Muslim are said by followers of all four schools.
- In Waqt the school changes the Asr time and the zenith restricted time (done; see `docs/moment-rules.md`). Any text that gives a *ruling* (how to pray, what breaks a fast) needs a per-school check. The current texts are duas, adhkar and virtues, not rulings.
- Shia material: none was found in the bundled content. The Ja'fari (Tehran) prayer-time method was the only Shia-specific item, and it has been removed.

## Recommended plan (needs the owner's go-ahead)
1. **Keep HadeethEnc** for every hadith shown with a translation.
2. **Add a referenced layer for the gaps.** For a hadith or dua HadeethEnc lacks, show the Arabic from the collection itself, the reference (book and number), and the grade with the grader's name. Cross-check the Arabic and grade against fawazahmed0's Arabic and Dorar. Show the meaning only from a licensed human translation; otherwise show the Arabic with the existing note. This extends `lib/data/sources/referenced.dart`.
3. **Ask for translations with permission:**
   - IslamHouse / the Hisn al-Muslim publishers, for the book's translations into ur, bn, id, tr and fr.
   - Sunnah.com, for English.
4. **Scholar review gate:** release builds show only items a reviewer has marked `approved` (the pipeline already supports draft → checked → approved). The reviewer also confirms nothing contradicts any of the four schools.

## Duas added in Nov 2026 (HadeethEnc ids)
Asking: 5502 (rabbana atina), 3142 (ya muqallib al-qulub), 3596 (al-huda wat-tuqa), 5915 (ihdini wa saddidni), 3293 (istikhara). Weather: 8956 (strong wind), 65527 (rain, Arabic only). People: 3433 (sneezing), 6032 (newlywed), 66257 (leaving a gathering, Arabic only). Salah: 10905 (opening), 65104 (between the sajdahs). Hardship: 6018 (pain). Protection: 5473 (fearing people), 6047 (serious illness). Loss: 65772 (calamity), 5021 (funeral prayer), 10407 (graves), 3290 (condolence).
Quran tab passages: 65059 (Ayat al-Kursi), 6274, 10112 (al-Fatihah), 6265, 6260, 6082, 65261 (al-Ikhlas), 6208 (al-Baqarah).
Looked for and left out because HadeethEnc lacks them or has no translation of the words: the new-garment dua, the market dua, hamm and hazan, returning from travel (its words sit inside the journey hadith), the bad-dream instruction.
