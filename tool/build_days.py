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
        ("Eat an odd number of dates before the prayer", "bukhari", "953"),
        ("Pay Zakat al-Fitr before the Eid prayer", "bukhari", "1509"),
        ("Bathe (ghusl) before going out, as Ibn Umar did", "malik", "432"),
        ("Wear your best clothes", "bukhari", "948"),
        ("Say the takbir with everyone at the prayer", "bukhari", "971"),
        ("Return home by a different way", "bukhari", "986"),
        ("Do not fast today", "bukhari", "1990"),
        ("Then fast six days of Shawwal", "muslim", "1164a"),
    ],
    "eidAlAdha": [
        ("Eat nothing until after the prayer", "tirmidhi", "542"),
        ("Offer the sacrifice after the prayer", "bukhari", "955"),
        ("Say the takbir with everyone at the prayer", "bukhari", "971"),
        ("Return home by a different way", "bukhari", "986"),
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

# Days on which fasting is the Sunnah (for the fasting badge on Home).
FASTS = ["arafah", "ashura", "tasua", "ayyamAlBid", "mondayFast", "thursdayFast"]
WEAK = ("da'if", "da’if", "daif", "mawdu", "munkar")


def main():
    path = os.path.join(tempfile.mkdtemp(), "h.db")
    with gzip.open(os.path.join(ROOT, "assets", "sources", "hadith.db.gz")) as f, open(path, "wb") as out:
        out.write(f.read())
    db = sqlite3.connect(path)
    days = {}
    for occ, items in DAYS.items():
        rows = []
        for title, col, num, *when in items:
            r = db.execute("SELECT ref, grade FROM hadith WHERE col=? AND num=?", (col, num)).fetchone()
            if r is None:
                raise SystemExit(f"{occ}: {col} {num} not in the database")
            ref, grade = r
            if grade and grade.lower().startswith(WEAK):
                raise SystemExit(f"{occ}: {ref} is graded {grade}")
            row = {"title": title, "col": col, "num": num, "ref": ref, "grade": grade}
            if when:
                row["when"] = when[0]  # suhoor, day, iftar or night: when it is most relevant
            rows.append(row)
        days[occ] = rows
    with open(os.path.join(ROOT, "assets", "sources", "days.json"), "w", encoding="utf8") as f:
        json.dump({"fasts": FASTS, "days": days}, f, ensure_ascii=False, indent=1)
    print(sum(len(v) for v in days.values()), "items for", len(days), "occasions")


if __name__ == "__main__":
    main()
