"""Special-day guides: what the Sunnah teaches for each occasion, each item
tied to one hadith in the bundled database.

    python tool/build_days.py   (after tool/import_sources.py)

The titles are short labels we write to name the action. The hadith itself,
its reference and its grade are read from assets/sources/hadith.db.gz, and the
build fails if any reference is missing or graded weak, so nothing reaches the
app that the source does not contain.
"""

import gzip
import json
import os
import sqlite3
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# occasion id (OccasionId in lib/domain/occasions/occasions.dart) -> items
DAYS = {
    "eidAlFitr": [
        ("Eat an odd number of dates before the prayer", "bukhari", "953", "morning"),
        ("Pay Zakat al-Fitr before the Eid prayer", "bukhari", "1509", "morning"),
        ("Bathe (ghusl) before going out, as Ibn Umar did", "malik", "432", "morning"),
        ("Wear your best clothes", "bukhari", "948", "morning"),
        ("Say the takbir with everyone at the prayer", "bukhari", "971", "morning"),
        ("Return home by a different way", "bukhari", "986", "morning"),
        ("Do not fast today", "bukhari", "1990"),
        ("Then fast six days of Shawwal", "muslim", "1164a"),
    ],
    "eidAlAdha": [
        ("Eat nothing until after the prayer", "tirmidhi", "542", "morning"),
        ("Offer the sacrifice after the prayer", "bukhari", "955"),
        ("Say the takbir with everyone at the prayer", "bukhari", "971", "morning"),
        ("Return home by a different way", "bukhari", "986", "morning"),
        ("Do not fast today", "bukhari", "1990"),
    ],
    "firstTenDhulHijjah": [
        ("No days are better for good deeds", "bukhari", "969"),
        ("If you will sacrifice, leave your hair and nails", "nasai", "4361"),
    ],
    "arafah": [
        ("Fast the Day of Arafah", "muslim", "1162a"),
        ("No days are better for good deeds", "bukhari", "969"),
    ],
    "tashreeq": [
        ("Days of eating, drinking and remembering Allah", "muslim", "1141a"),
        ("Do not fast on these days", "bukhari", "1997"),
    ],
    "tasua": [
        ("Fast the ninth along with Ashura", "muslim", "1134a"),
        ("The best fasting after Ramadan is in Muharram", "muslim", "1163a"),
    ],
    "ashura": [
        ("Fast the Day of Ashura", "muslim", "1162a"),
        ("Why the Prophet fasted Ashura", "bukhari", "2004"),
        ("The best fasting after Ramadan is in Muharram", "muslim", "1163a"),
    ],
    "ramadan": [
        ("Eat suhoor, there is blessing in it", "bukhari", "1923", "suhoor"),
        ("Take suhoor late, close to Fajr", "bukhari", "1921", "suhoor"),
        ("Fast with faith, hoping for reward", "bukhari", "38", "day"),
        ("Guard your tongue and your actions", "bukhari", "1903", "day"),
        ("Make dua before you break your fast", "tirmidhi", "3598", "iftar"),
        ("Break the fast as soon as the sun sets", "bukhari", "1957", "iftar"),
        ("Break it with dates, or else water", "abudawud", "2356", "iftar"),
        ("Say the dua of iftar", "abudawud", "2357", "iftar"),
        ("Feed someone who is fasting", "tirmidhi", "807", "iftar"),
        ("Pray at night (taraweeh)", "bukhari", "2009", "night"),
        ("Read and study the Qur'an, give generously", "bukhari", "6", "day"),
    ],
    "lastTenNights": [
        ("Strive in worship and wake your family", "bukhari", "2024", "night"),
        ("Seek Laylat al-Qadr in the odd nights", "bukhari", "2017", "night"),
        ("Stand in prayer on Laylat al-Qadr", "bukhari", "2014", "night"),
        ("The dua for Laylat al-Qadr", "tirmidhi", "3513", "night"),
        ("I'tikaf in the last ten days", "bukhari", "2026", "day"),
    ],
    "ayyamAlBid": [
        ("Fast the 13th, 14th and 15th", "tirmidhi", "761"),
    ],
    "mondayFast": [
        ("Fast Monday: deeds are presented", "tirmidhi", "747"),
        ("The Prophet was born on a Monday", "abudawud", "2426"),
    ],
    "thursdayFast": [
        ("Fast Thursday: deeds are presented", "tirmidhi", "747"),
    ],
    "jumuah": [
        ("The best day the sun rises on", "muslim", "854a"),
        ("Bathe, perfume, go early and listen", "bukhari", "883"),
    ],
}

# moment id (MomentId in lib/domain/moments/moment.dart) -> items shown while
# that moment is active, on Home and in the Duas tab.
MOMENTS = {
    "duha": [
        ("Pray Duha: it is charity for every joint", "muslim", "720"),
        ("Best when the sun is high and hot", "muslim", "748a"),
        ("Two rak'ahs of Duha, as the Prophet advised", "bukhari", "1981"),
    ],
    "lastThird": [
        ("Allah descends: call on Him, ask, seek forgiveness", "bukhari", "1145"),
        ("He gives until the dawn breaks", "muslim", "758a"),
    ],
    "fridayLastHour": [
        ("An hour in which dua is answered", "bukhari", "935"),
        ("Seek it in the last hour after Asr", "abudawud", "1048"),
        ("Send blessings on the Prophet", "abudawud", "1047"),
    ],
    "afterSalah": [
        ("Seek forgiveness three times", "muslim", "591"),
        ("SubhanAllah, Alhamdulillah, Allahu Akbar, 33 each", "muslim", "597a"),
    ],
    "betweenAdhanIqamah": [
        ("Dua now is not turned back", "abudawud", "521"),
        ("Repeat the adhan, then send blessings", "muslim", "384"),
        ("The dua after the adhan", "bukhari", "614"),
    ],
    "bedtime": [
        ("Wudu, and lie on your right side", "bukhari", "247"),
        ("Say the dua before sleep", "bukhari", "6324"),
        ("The three Quls, then wipe over the body", "bukhari", "5017"),
        ("Recite Ayat al-Kursi", "bukhari", "2311"),
        ("Tasbih of Fatimah: 33, 33, 34", "bukhari", "3705"),
    ],
    "jumuah": [
        ("Bathe, perfume, go early and listen", "bukhari", "883"),
        ("Send abundant blessings on the Prophet", "abudawud", "1047"),
        ("The best day the sun rises on", "muslim", "854a"),
    ],
    "morningAdhkar": [
        ("The master supplication for forgiveness", "bukhari", "6306"),
        ("Bismillahilladhi la yadurru, three times", "abudawud", "5088"),
        ("SubhanAllah wa bihamdihi, a hundred times", "muslim", "2692"),
    ],
    "eveningAdhkar": [
        ("The master supplication for forgiveness", "bukhari", "6306"),
        ("Bismillahilladhi la yadurru, three times", "abudawud", "5088"),
        ("SubhanAllah wa bihamdihi, a hundred times", "muslim", "2692"),
    ],
    "restrictedSunrise": [
        ("No prayer while the sun rises", "muslim", "831"),
        ("None after Fajr until the sun is up", "bukhari", "586"),
    ],
    "restrictedZawal": [("No prayer when the sun is at its height", "muslim", "831")],
    "restrictedSunset": [
        ("No prayer while the sun sets", "muslim", "831"),
        ("None after Asr until the sun has set", "bukhari", "586"),
    ],
    "suhoor": [
        ("Eat suhoor, there is blessing in it", "bukhari", "1923"),
        ("Take suhoor late, close to Fajr", "bukhari", "1921"),
    ],
    "iftar": [
        ("Make dua before you break your fast", "tirmidhi", "3598"),
        ("Break the fast as soon as the sun sets", "bukhari", "1957"),
        ("Break it with dates, or else water", "abudawud", "2356"),
        ("Say the dua of iftar", "abudawud", "2357"),
    ],
    "taraweeh": [
        ("Pray at night in Ramadan", "bukhari", "2009"),
        ("Read and study the Qur'an, give generously", "bukhari", "6"),
    ],
    "laylatAlQadr": [
        ("Stand in prayer on Laylat al-Qadr", "bukhari", "2014"),
        ("The dua for Laylat al-Qadr", "tirmidhi", "3513"),
        ("Strive in worship and wake your family", "bukhari", "2024"),
    ],
}

# Days on which fasting is the Sunnah (for the fasting badge on Home).
FASTS = ["arafah", "ashura", "tasua", "ayyamAlBid", "mondayFast", "thursdayFast"]
WEAK = ("da'if", "da’if", "daif", "mawdu", "munkar")


def main():
    path = os.path.join(tempfile.mkdtemp(), "h.db")
    with gzip.open(os.path.join(ROOT, "tool", "data", "hadith.db.gz")) as f, open(path, "wb") as out:
        out.write(f.read())
    db = sqlite3.connect(path)
    def rows(name, items):
        out = []
        for title, col, num, *when in items:
            r = db.execute("SELECT ref, grade FROM hadith WHERE col=? AND num=?", (col, num)).fetchone()
            if r is None:
                raise SystemExit(f"{name}: {col} {num} not in the database")
            ref, grade = r
            if grade and grade.lower().startswith(WEAK):
                raise SystemExit(f"{name}: {ref} is graded {grade}")
            row = {"title": title, "col": col, "num": num, "ref": ref, "grade": grade}
            if when:
                row["when"] = when[0]  # suhoor, morning (until Dhuhr), day, iftar or night
            out.append(row)
        return out

    days = {occ: rows(occ, items) for occ, items in DAYS.items()}
    moments = {m: rows(m, items) for m, items in MOMENTS.items()}
    with open(os.path.join(ROOT, "assets", "sources", "days.json"), "w", encoding="utf8") as f:
        json.dump({"fasts": FASTS, "days": days, "moments": moments}, f, ensure_ascii=False, indent=1)
    print(sum(len(v) for v in days.values()), "items for", len(days), "occasions;", len(moments), "moments")


if __name__ == "__main__":
    main()
