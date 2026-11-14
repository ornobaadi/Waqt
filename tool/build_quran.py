"""The Quran text Waqt bundles, from Tanzil.net.

    python tool/build_quran.py

Writes
  assets/quran/quran-uthmani.txt  Tanzil Uthmani text, verbatim, with its
                                  copyright block (CC BY 3.0, no changes).
  assets/quran/meta.json          surah names, ayah counts, revelation place,
                                  juz and page starts, from Tanzil's
                                  quran-data.xml (CC BY), notice included.
  assets/fonts/AmiriQuran.ttf     Amiri Quran 1.003 (SIL OFL 1.1), with OFL.txt.
  assets/quran/quran-indopak.json DigitalKhatt IndoPak text (MIT), cut into ayat.
  assets/fonts/IndoPak.otf        DigitalKhatt IndoPak font (SIL OFL 1.1).

Translations are not bundled: the app downloads QuranEnc.com's file for the
reader's language on request, shown unchanged with its version.
"""

import io
import json
import os
import re
import sys
import unicodedata
import tempfile
import urllib.request
import xml.etree.ElementTree as ET
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE = os.path.join(tempfile.gettempdir(), "waqt-quran-src")
TEXT = "https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=txt-2&agree=true"
META = "https://tanzil.net/res/text/metadata/quran-data.xml"
AMIRI = "https://github.com/aliftype/amiri/releases/download/1.003/Amiri-1.003.zip"
TRANSLIT = "https://tanzil.net/trans/?transID=en.transliteration&type=txt-2"
DK_COMMIT = "78372d7a1e211bbab677cc0304384f278f508657"
INDOPAK_TEXT = (
    f"https://raw.githubusercontent.com/DigitalKhatt/digitalkhatt-js/{DK_COMMIT}"
    "/apps/site-angular/src/app/services/quran_text_indopak_15.ts"
)
INDOPAK_TEXT_LICENSE = f"https://raw.githubusercontent.com/DigitalKhatt/digitalkhatt-js/{DK_COMMIT}/LICENSE"
INDOPAK_FONT = "https://github.com/DigitalKhatt/indopakfont/releases/download/v1.0.0-beta.1/indopak.otf"
INDOPAK_FONT_LICENSE = "https://raw.githubusercontent.com/DigitalKhatt/indopakfont/master/LICENSE"


def fetch(url, name):
    os.makedirs(CACHE, exist_ok=True)
    path = os.path.join(CACHE, name)
    if not os.path.exists(path):
        req = urllib.request.Request(url, headers={"User-Agent": "waqt-data-builder"})
        with open(path, "wb") as f:
            f.write(urllib.request.urlopen(req, timeout=300).read())
    return path


def main():
    out = os.path.join(ROOT, "assets", "quran")
    os.makedirs(out, exist_ok=True)

    raw = open(fetch(TEXT, "uthmani.txt"), "rb").read()
    lines = [l for l in raw.decode("utf-8").splitlines() if l and not l.startswith("#")]
    if len(lines) != 6236:
        raise SystemExit(f"expected 6236 ayat, got {len(lines)}")
    if "Tanzil" not in raw.decode("utf-8") or "CHANGING IT IS NOT ALLOWED" not in raw.decode("utf-8"):
        raise SystemExit("Tanzil copyright block missing")
    with open(os.path.join(out, "quran-uthmani.txt"), "wb") as f:
        f.write(raw)  # verbatim

    root = ET.parse(fetch(META, "quran-data.xml")).getroot()
    suras = [
        {
            "n": int(s.get("index")),
            "ayas": int(s.get("ayas")),
            "start": int(s.get("start")),
            "ar": s.get("name"),
            "tname": s.get("tname"),
            "en": s.get("ename"),
            "type": "makki" if s.get("type") == "Meccan" else "madani",
        }
        for s in root.find("suras")
    ]
    if len(suras) != 114 or sum(s["ayas"] for s in suras) != 6236:
        raise SystemExit("surah metadata does not add up")
    marks = lambda tag: [[int(e.get("sura")), int(e.get("aya"))] for e in root.find(tag + "s")]
    meta = {
        "notice": "Quran metadata from Tanzil Project (tanzil.net), quran-data.xml, CC BY 3.0. "
        "Text: Tanzil Quran Text (Uthmani, Version 1.1), verbatim; see quran-uthmani.txt.",
        "suras": suras,
        "juz": marks("juz"),
        "pages": marks("page"),
    }
    if len(meta["juz"]) != 30 or len(meta["pages"]) != 604:
        raise SystemExit("juz or page metadata does not add up")
    meta["names"] = surah_names(suras)
    meta["notice"] += (" Surah names and meanings in Urdu, Bangla, Indonesian, Turkish and French: Quran.com API;"
                       " Bangla spellings of the names: Waqt (tool/surah_names_bn.py).")
    with open(os.path.join(out, "meta.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, separators=(",", ":"))

    with zipfile.ZipFile(fetch(AMIRI, "amiri.zip")) as z:
        fonts = os.path.join(ROOT, "assets", "fonts")
        with open(os.path.join(fonts, "AmiriQuran.ttf"), "wb") as f:
            f.write(z.read("Amiri-1.003/AmiriQuran.ttf"))
        with open(os.path.join(fonts, "AmiriQuran-OFL.txt"), "wb") as f:
            f.write(z.read("Amiri-1.003/OFL.txt"))

    indopak(out, suras, lines)
    transliteration(out)
    print(f"{len(lines)} ayat, {len(suras)} surahs, {len(meta['pages'])} pages")


def transliteration(out):
    """Tanzil's English transliteration (non-commercial use, credited), made
    plain to read: letters Tanzil marks as not pronounced (assimilated, or a
    vowel dropped at a stop) are left out, the other markup goes, and its
    "AA" for the letter 'ayn becomes ‘."""
    raw = open(fetch(TRANSLIT, "en.transliteration.txt"), encoding="utf-8").read()
    rows = [l.split("|", 2) for l in raw.splitlines() if l and not l.startswith("#")]
    if len(rows) != 6236:
        raise SystemExit(f"transliteration: expected 6236 ayat, got {len(rows)}")

    def clean(t):
        t = re.sub(r"<b>.*?</b>", "", t, flags=re.I)
        t = re.sub(r"<[^>]+>", "", t)
        t = t.replace("AA", "‘")
        return " ".join(t.split())

    notice = [l for l in raw.splitlines() if l.startswith("#")]
    nl = chr(10)
    lines = [
        "# English transliteration from Tanzil.net (en.transliteration), for non-commercial use.",
        "# Markup removed: letters marked as not pronounced are left out; AA (the letter 'ayn) is ‘.",
        *(f"{sura}|{aya}|{clean(text)}" for sura, aya, text in rows),
        *notice,
    ]
    with open(os.path.join(out, "quran-translit.txt"), "w", encoding="utf-8", newline=nl) as f:
        f.write(nl.join(lines) + nl)
    print("Transliteration: 6236 ayat")


def surah_names(suras):
    """Per language, [name, meaning] for each surah, as readers of that
    language know them. en: the common Latin spelling and Tanzil's meaning;
    ar: the Arabic; ur: the Arabic name (read as is in Urdu); bn: Bangla
    script; id, fr: the common Latin spelling; tr: the Turkish spelling."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from surah_names_bn import BN_NAMES

    def chapters(lang):
        raw = open(fetch(f"https://api.quran.com/api/v4/chapters?language={lang}", f"chapters-{lang}.json"),
                   encoding="utf-8").read()
        cs = json.loads(raw)["chapters"]
        if len(cs) != 114:
            raise SystemExit(f"Quran.com chapters ({lang}): {len(cs)}")
        return cs

    def meaning(c, lang):
        t = c["translated_name"]
        return t["name"] if t["language_name"] != "english" or lang == "en" else ""

    out = {}
    en = chapters("en")
    out["en"] = [[c["name_simple"], s["en"]] for c, s in zip(en, suras)]
    out["ar"] = [[s["ar"], ""] for s in suras]
    ur = chapters("ur")
    out["ur"] = [[s["ar"], meaning(c, "ur")] for c, s in zip(ur, suras)]
    bn = chapters("bn")
    out["bn"] = [[name, meaning(c, "bn")] for name, c in zip(BN_NAMES, bn)]
    for lang in ("id", "fr"):
        cs = chapters(lang)
        out[lang] = [[c["name_simple"], meaning(c, lang)] for c in cs]
    out["tr"] = [[c["translated_name"]["name"], ""] for c in chapters("tr")]
    # A "meaning" that only repeats the name (Ya-Sin, "Yaseen") says nothing.
    def plain(x):
        x = "".join(c for c in unicodedata.normalize("NFKD", x.lower()) if not unicodedata.category(c).startswith("M"))
        x = re.sub(r"[\W_]", "", x.replace("ی", "ي").replace("ee", "i"))
        return re.sub(r"(.)+", r"", x)
    for rows in out.values():
        for r in rows:
            if r[1] and plain(r[1]) == plain(r[0]):
                r[1] = ""
    return out


def indopak(out, suras, uthmani):
    """IndoPak script: DigitalKhatt's 15-line IndoPak text (MIT), cut into ayat
    at its own ayah marks, each ayah kept verbatim with its mark and pause
    signs; DigitalKhatt IndoPak font (OFL 1.1)."""
    src = open(fetch(INDOPAK_TEXT, "indopak-%s.ts" % DK_COMMIT[:8]), encoding="utf-8").read()
    body = src[src.index("["): src.rindex("]") + 1]
    pages = json.loads(re.sub(r",\s*\]", "]", body).replace("'", '"'))
    digits = "٠١٢٣٤٥٦٧٨٩"
    # An ayah ends at ۝ + its number, plus the pause signs written after it.
    end = re.compile("۝([" + digits + "]+)\\S*")
    heading, basmala = "سُورَةُ", None
    surahs, buf = [], ""
    for line in (l for p in pages for l in p):
        if line.startswith(heading):
            if surahs and buf.strip():
                raise SystemExit(f"text left over in surah {len(surahs)}: {buf!r}")
            surahs.append([])
            buf = ""
            continue
        if not surahs[-1] and not buf and line.endswith("۝") and "۝" not in line[:-1]:
            if basmala not in (None, line):
                raise SystemExit("two different basmala headings")
            basmala = line
            continue
        buf += (" " if buf else "") + line
        while m := end.search(buf):
            n = int("".join(str(digits.index(c)) for c in m.group(1)))
            surahs[-1].append((n, buf[: m.end()].strip()))
            buf = buf[m.end():].lstrip()
    if len(surahs) != 114 or basmala is None:
        raise SystemExit("IndoPak text: expected 114 surahs and a basmala heading")
    # Al-Fatihah: this mushaf numbers from al-hamdu and marks "an'amta 'alayhim"
    # (a different count) without ۝; the app follows Hafs, where the basmala is
    # ayah 1. So ayah 1 is the basmala as printed, and the rest move up by one.
    fatiha = surahs[0]
    if [n for n, _ in fatiha] != [1, 2, 3, 4, 5, 7] or "‮" not in fatiha[-1][1]:
        raise SystemExit("IndoPak al-Fatihah is not laid out as expected")
    surahs[0] = [(1, basmala)] + [(i + 2, t) for i, (_, t) in enumerate(fatiha)]
    for s, meta in zip(surahs, suras):
        if [n for n, _ in s] != list(range(1, meta["ayas"] + 1)):
            raise SystemExit(f"IndoPak surah {meta['n']}: ayah numbers do not match Tanzil")
    data = {
        "notice": "IndoPak Quran text from DigitalKhatt (github.com/DigitalKhatt/digitalkhatt-js, "
        f"commit {DK_COMMIT[:12]}, MIT licence), based on the Quraan Al Majeed 13-line IndoPak mushaf, "
        "each ayah verbatim. Al-Fatihah numbered as in Hafs (basmala = 1). Font: DigitalKhatt IndoPak (OFL 1.1).",
        "basmala": basmala,
        "ayat": [[t for _, t in s] for s in surahs],
    }
    with open(os.path.join(out, "quran-indopak.json"), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
    fonts = os.path.join(ROOT, "assets", "fonts")
    with open(os.path.join(fonts, "IndoPak.otf"), "wb") as f:
        f.write(open(fetch(INDOPAK_FONT, "indopak.otf"), "rb").read())
    with open(os.path.join(fonts, "IndoPak-OFL.txt"), "wb") as f:
        f.write(open(fetch(INDOPAK_FONT_LICENSE, "indopak-LICENSE.txt"), "rb").read())
    with open(os.path.join(out, "quran-indopak-LICENSE.txt"), "wb") as f:
        f.write(open(fetch(INDOPAK_TEXT_LICENSE, "digitalkhatt-js-LICENSE.txt"), "rb").read())
    # Same words as Tanzil, other spelling: word counts should nearly always agree.
    words = lambda t: len([w for w in t.split() if any("ء" <= c <= "ي" for c in w)])
    off = []
    for (sura, aya, text), (_, ip) in zip(
        (l.split("|", 2) for l in uthmani), (x for s in surahs for x in s)
    ):
        # Tanzil writes the basmala inside ayah 1 (not for al-Fatihah, where it is the ayah, or at-Tawbah).
        n = words(text) - (4 if aya == "1" and sura not in ("1", "9") else 0)
        if abs(words(ip) - n) > 1:
            off.append(f"{sura}:{aya}")
    if off:
        raise SystemExit(f"IndoPak ayat differ from Tanzil by more than one word: {off[:10]}")
    print("IndoPak: 6236 ayat, every one within a word of Tanzil")


if __name__ == "__main__":
    main()
