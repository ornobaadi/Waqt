"""Translations of the hadiths Waqt shows, from HadeethEnc.com.

    python tool/import_hadeethenc.py   (after build_days.py and build_dhikr.py)

HadeethEnc.com (Encyclopedia of Translated Prophetic Hadiths, by the team
behind QuranEnc and IslamHouse) publishes reviewed translations of
authentic hadiths in 70+ languages, with one SQLite file per language. Its
terms: no changes to the content, credit HadeethEnc.com with the version,
keep it updated, report errors to them. So this script copies its fields
as they are and keeps each hadith's version number.

Tying a HadeethEnc hadith to one of our references takes two checks:
  1. its references name the same book and number ("صحيح البخاري ... (6306)"),
     or, if none does, its quoted words cover at least half of our text; and
  2. always, its Arabic agrees with ours: a run of at least six words
     (vowel marks aside) of the Prophet's quoted words appears in our text.
Anything that fails stays in English. Nothing is guessed.

Writes assets/sources/hadeethenc.json.
"""

import datetime
import gzip
import io
import json
import os
import re
import sqlite3
import sys
import tempfile
import urllib.request
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LANGS = ["ar", "en", "ur", "bn", "id", "tr", "fr"]
URL = "https://hadeethenc.com/en/browse/download/{}/sqlite"
CACHE = os.path.join(tempfile.gettempdir(), "waqt-hadeethenc-sqlite")

# How HadeethEnc's references name each of our collections.
BOOK = {
    "bukhari": ["صحيح البخاري"],
    "muslim": ["صحيح مسلم"],
    "abudawud": ["سنن أبي داود"],
    "tirmidhi": ["سنن الترمذي", "جامع الترمذي"],
    "nasai": ["سنن النسائي"],
    "ibnmajah": ["سنن ابن ماجه"],
    "malik": ["موطأ مالك", "الموطأ"],
    "ahmad": ["مسند أحمد"],
    "darimi": ["سنن الدارمي"],
}

MARKS = re.compile("[ؐ-ًؚ-ٰٟۖ-ۭـ]")


def norm(s):
    s = MARKS.sub("", s or "")
    s = re.sub("[أإآٱ]", "ا", s).replace("ى", "ي").replace("ؤ", "و").replace("ئ", "ي").replace("ة", "ه")
    s = re.sub("[^ء-ي ]", " ", s)
    return " ".join(s.split())


def language(lang):
    """One language's SQLite, downloaded once (a zip of a few MB)."""
    os.makedirs(CACHE, exist_ok=True)
    path = os.path.join(CACHE, f"{lang}.sqlite")
    if not os.path.exists(path):
        req = urllib.request.Request(URL.format(lang), headers={"User-Agent": "waqt-data-importer"})
        data = urllib.request.urlopen(req, timeout=300).read()
        with zipfile.ZipFile(io.BytesIO(data)) as z:
            name = next(n for n in z.namelist() if n.endswith(".sqlite"))
            with open(path, "wb") as f:
                f.write(z.read(name))
    db = sqlite3.connect(path)
    db.row_factory = sqlite3.Row
    cols = {r[1] for r in db.execute("PRAGMA table_info(hadeeths)")}
    where = " WHERE current = 1" if "current" in cols else ""
    return {str(r["id"]): r for r in db.execute("SELECT * FROM hadeeths" + where)}


def quoted(text):
    parts = re.findall("«([^»]+)»", text or "")
    return [norm(p) for p in parts] or [norm(text)]


def agrees(ours, theirs, run=6):
    """A run of `run` consecutive words of their quoted text is in ours."""
    words = ours.split()
    grams = {" ".join(words[i:i + run]) for i in range(len(words) - run + 1)}
    for part in theirs:
        w = part.split()
        if len(w) < run and part and part in ours:
            return True
        if any(" ".join(w[i:i + run]) in grams for i in range(len(w) - run + 1)):
            return True
    return False


def cites(reference, col, num):
    base = re.match(r"\d+", num).group(0)
    for line in (reference or "").splitlines():
        line = line.strip()
        if any(line.startswith(b) for b in BOOK.get(col, [])) and re.search(rf"\({base}\)\s*\.?\s*$", line):
            return True
    return False


def our_references():
    """(col, num) of every hadith the app shows: days, moments, dhikr."""
    refs = set()
    days = json.load(open(os.path.join(ROOT, "assets", "sources", "days.json"), encoding="utf8"))
    for group in ("days", "moments"):
        for items in days.get(group, {}).values():
            refs.update((i["col"], i["num"]) for i in items)
    dart = open(os.path.join(ROOT, "lib", "features", "counter", "dhikr_data.dart"), encoding="utf8").read()
    refs.update(re.findall(r"DhikrSource\('(\w+)', '(\w+)'", dart))
    return sorted(refs)


def main():
    path = os.path.join(tempfile.mkdtemp(), "h.db")
    with gzip.open(os.path.join(ROOT, "tool", "data", "hadith.db.gz")) as f, open(path, "wb") as out:
        out.write(f.read())
    db = sqlite3.connect(path)

    langs = {lang: language(lang) for lang in LANGS}
    ar = langs["ar"]
    print(len(ar), "HadeethEnc hadiths")
    result, missing, rejected = {}, [], []
    for col, num in our_references():
        ours = norm(db.execute("SELECT ar FROM hadith WHERE col=? AND num=?", (col, num)).fetchone()[0])
        match = None
        by_number = [i for i, r in ar.items() if cites(r["reference"], col, num)]
        for i in by_number:
            if agrees(ours, quoted(ar[i]["hadeeth"])):
                match = i
                break
        if by_number and match is None:
            rejected.append(f"{col} {num} (number matches HadeethEnc {by_number}, Arabic does not)")
        if match is None and not by_number:
            # No numbered reference: the quoted words must cover half our text.
            n = len(ours.split())
            for i, r in ar.items():
                parts = quoted(r["hadeeth"])
                if any(b in (r["reference"] or "") for b in BOOK.get(col, [])) and any(
                    len(p.split()) >= 6 and p in ours and 2 * len(p.split()) >= n for p in parts
                ):
                    match = i
                    break
        if match is None:
            missing.append(f"{col} {num}")
            continue
        entry = {"heId": match}
        for lang, rows in langs.items():
            r = rows.get(match)
            if r is None or not r["hadeeth"]:
                continue
            entry[lang] = {
                "title": r["title"],
                "hadeeth": r["hadeeth"],
                "attribution": r["attribution"],
                "grade": r["grade"],
                "explanation": r["explanation"],
                # The Arabic version this translation follows.
                "version": r["version"] if "version" in r.keys() else r["ar_version"],
            }
        result[f"{col}:{num}"] = entry
    out = {
        "source": "HadeethEnc.com",
        "url": "https://hadeethenc.com",
        "retrieved": datetime.date.today().isoformat(),
        "items": result,
    }
    with open(os.path.join(ROOT, "assets", "sources", "hadeethenc.json"), "w", encoding="utf8") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))
    print(f"{len(result)} matched; {len(missing)} not in HadeethEnc: {', '.join(missing)}")
    for r in rejected:
        print("rejected:", r)


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
