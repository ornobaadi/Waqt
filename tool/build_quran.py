"""The Quran text Waqt bundles, from Tanzil.net.

    python tool/build_quran.py

Writes
  assets/quran/quran-uthmani.txt  Tanzil Uthmani text, verbatim, with its
                                  copyright block (CC BY 3.0, no changes).
  assets/quran/meta.json          surah names, ayah counts, revelation place,
                                  juz and page starts, from Tanzil's
                                  quran-data.xml (CC BY), notice included.
  assets/fonts/AmiriQuran.ttf     Amiri Quran 1.003 (SIL OFL 1.1), with OFL.txt.

Translations are not bundled: the app downloads QuranEnc.com's file for the
reader's language on request, shown unchanged with its version.
"""

import io
import json
import os
import tempfile
import urllib.request
import xml.etree.ElementTree as ET
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE = os.path.join(tempfile.gettempdir(), "waqt-quran-src")
TEXT = "https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=txt-2&agree=true"
META = "https://tanzil.net/res/text/metadata/quran-data.xml"
AMIRI = "https://github.com/aliftype/amiri/releases/download/1.003/Amiri-1.003.zip"


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
    with open(os.path.join(out, "meta.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, separators=(",", ":"))

    with zipfile.ZipFile(fetch(AMIRI, "amiri.zip")) as z:
        fonts = os.path.join(ROOT, "assets", "fonts")
        with open(os.path.join(fonts, "AmiriQuran.ttf"), "wb") as f:
            f.write(z.read("Amiri-1.003/AmiriQuran.ttf"))
        with open(os.path.join(fonts, "AmiriQuran-OFL.txt"), "wb") as f:
            f.write(z.read("Amiri-1.003/OFL.txt"))

    print(f"{len(lines)} ayat, {len(suras)} surahs, {len(meta['pages'])} pages")


if __name__ == "__main__":
    main()
