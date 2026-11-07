"""Compile open source texts into Waqt's bundled assets.

Source: open-hadith-data v1.1.0 (https://github.com/Jaguar16/open-hadith-data)
  Structured data CC0 1.0. Arabic and English texts as published on sunnah.com.
  Download collections-json.zip from the release and unzip it, then:

    python tool/import_sources.py path/to/unzipped

Outputs
  assets/sources/hisn.json      Hisn al-Muslim: chapters and duas, with the
                                 book's own source notes for each dua.
  tool/data/hadith.db.gz        SQLite of every hadith collection, published as
                                 a release of github.com/ornobaadi/waqt-data and
                                 downloaded by the app on first use. The phone
                                 decompresses it and builds the search index
                                 once (see lib/data/sources/hadith_db.dart),
                                 which keeps the APK about 12 MB smaller.

Nothing is written or rephrased here: texts are copied as published.
"""

import gzip
import json
import os
import sqlite3
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "sources")
SOURCE = "open-hadith-data v1.1.0 (sunnah.com texts)"

# Display order: the two Sahihs, the four Sunan, then the rest.
ORDER = [
    "bukhari", "muslim", "abudawud", "tirmidhi", "nasai", "ibnmajah",
    "malik", "ahmad", "darimi", "riyadussalihin", "nawawi40", "qudsi40",
    "bulugh", "adab", "shamail", "mishkat", "shahwaliullah40",
]

def hadiths(d):
    if d.get("books"):
        for b in d["books"]:
            yield from b.get("hadiths") or []
    else:
        yield from d.get("hadiths") or []


def build_hisn(src):
    d = json.load(open(os.path.join(src, "hisn.json"), encoding="utf8"))
    out = {
        "source": SOURCE,
        "title": {"en": d["collection"]["name_en"], "ar": d["collection"]["name_ar"]},
        "author": {"en": d["collection"]["author_en"], "ar": d["collection"]["author_ar"]},
        "chapters": [
            {"n": c["chapter_number"], "en": c["name_en"], "ar": c["name_ar"]} for c in d["chapters"]
        ],
        "duas": [
            {
                "n": x["dua_number"],
                "ch": x["chapter_number"],
                "ar": x["text_ar"],
                "tr": x.get("transliteration"),
                "en": x.get("translation"),
                "ctx": x.get("context_en"),
                "ref": x.get("hisn_reference"),
                "url": x.get("url_source"),
            }
            for x in d["duas"]
        ],
    }
    with open(os.path.join(OUT, "hisn.json"), "w", encoding="utf8") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))
    return len(out["duas"])


def build_hadith(src):
    path = os.path.join(tempfile.mkdtemp(), "hadith.db")
    db = sqlite3.connect(path)
    db.executescript(
        """
        CREATE TABLE collection(id TEXT PRIMARY KEY, ord INTEGER, name_en TEXT, name_ar TEXT, count INTEGER);
        CREATE TABLE hadith(id INTEGER PRIMARY KEY, col TEXT, num TEXT, ref TEXT, ar TEXT, en TEXT, grade TEXT, url TEXT);
        """
    )
    total = 0
    for i, cid in enumerate(ORDER):
        f = os.path.join(src, f"{cid}.json")
        if not os.path.exists(f):
            continue
        d = json.load(open(f, encoding="utf8"))
        c = d["collection"]
        n = 0
        for h in hadiths(d):
            # The matn (the words themselves); the chain is left to the source link.
            ar = h.get("matn_ar") or h.get("text_ar") or ""
            en = h.get("text_en") or ""
            if not ar and not en:
                continue
            db.execute(
                "INSERT INTO hadith(col,num,ref,ar,en,grade,url) VALUES(?,?,?,?,?,?,?)",
                (cid, h.get("hadith_number"), h.get("reference"), ar, en, h.get("grade_en"), h.get("url_source")),
            )
            n += 1
        db.execute(
            "INSERT INTO collection VALUES(?,?,?,?,?)", (cid, i, c.get("name_en"), c.get("name_ar"), n)
        )
        total += n
    db.commit()
    db.execute("VACUUM")
    db.close()
    with open(path, "rb") as fin, gzip.open(os.path.join(ROOT, "tool", "data", "hadith.db.gz"), "wb", 9) as fout:
        fout.write(fin.read())
    return total


if __name__ == "__main__":
    src = sys.argv[1]
    os.makedirs(OUT, exist_ok=True)
    print("hisn duas", build_hisn(src))
    print("hadiths", build_hadith(src))
    print("hadith.db.gz", round(os.path.getsize(os.path.join(ROOT, "tool", "data", "hadith.db.gz")) / 1e6, 1), "MB")
