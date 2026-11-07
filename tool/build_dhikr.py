"""The counter's dhikr list, each phrase checked against the hadith database.

    python tool/build_dhikr.py   (after tool/import_sources.py)

For every dhikr the build checks that
  - its reference exists in the database and is not graded weak, and
  - its Arabic words occur, letter for letter (vowel marks aside), in the
    Arabic of a hadith (the virtue hadith unless `text` names another).
It then writes lib/features/counter/dhikr_data.dart. The virtue lines are
short labels we write; the hadith itself opens from the counter.
"""

import gzip
import os
import re
import sqlite3
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WEAK = ("da", "maudu", "mawdu", "munkar", "fabricated")

# Built-in dhikrs, in the picker's order.
# (id, arabic, latin, target, virtue, (col, num) of the virtue, [(col, num) holding the words])
DHIKR = [
    ("subhanallah", "سُبْحَانَ اللّٰهِ", "SubhanAllah", 33,
     "Said 100 times: a thousand good deeds", ("muslim", "2698"), ("muslim", "2137a")),
    ("alhamdulillah", "الْحَمْدُ لِلّٰهِ", "Alhamdulillah", 33,
     "Fills the scale", ("muslim", "223"), None),
    ("allahuakbar", "اللّٰهُ أَكْبَرُ", "Allahu Akbar", 34,
     "Among the four phrases dearest to Allah", ("muslim", "2137a"), None),
    ("subhanallah_wabihamdihi", "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ", "SubhanAllahi wa bihamdihi", 100,
     "Said 100 times a day: sins forgiven, even like the foam of the sea", ("bukhari", "6405"), None),
    ("two_words", "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ، سُبْحَانَ اللّٰهِ الْعَظِيمِ",
     "SubhanAllahi wa bihamdihi, SubhanAllahil Azim", 33,
     "Light on the tongue, heavy on the scale, beloved to the Most Merciful", ("muslim", "2694"), None),
    ("four_words", "سُبْحَانَ اللّٰهِ، وَالْحَمْدُ لِلّٰهِ، وَلَا إِلٰهَ إِلَّا اللّٰهُ، وَاللّٰهُ أَكْبَرُ",
     "SubhanAllah, walhamdulillah, wa la ilaha illallah, wallahu akbar", 33,
     "Dearer to the Prophet ﷺ than all the sun rises over", ("muslim", "2695"), None),
    ("tahlil", "لَا إِلٰهَ إِلَّا اللّٰهُ", "La ilaha illallah", 100,
     "The best remembrance", ("tirmidhi", "3383"), None),
    ("tahlil_full",
     "لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ",
     "La ilaha illallahu wahdahu la sharika lah, lahul mulku wa lahul hamd, wa huwa ala kulli shayin qadir", 100,
     "Said 100 times a day: like freeing ten slaves, and a shield from Shaytan until evening", ("bukhari", "3293"), None),
    ("hawqala", "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ", "La hawla wa la quwwata illa billah", 33,
     "A treasure from the treasures of Paradise", ("bukhari", "6384"), None),
    ("istighfar", "أَسْتَغْفِرُ اللّٰهَ وَأَتُوبُ إِلَيْهِ", "Astaghfirullaha wa atubu ilayh", 100,
     "The Prophet ﷺ said it more than seventy times a day", ("bukhari", "6307"), None),
    ("salawat", "اللّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ", "Allahumma salli ala Muhammad", 10,
     "Send one blessing, Allah sends you ten", ("muslim", "408"), ("bukhari", "3370")),
    ("hasbunallah", "حَسْبُنَا اللّٰهُ وَنِعْمَ الْوَكِيلُ", "Hasbunallahu wa nimal wakil", 33,
     "Said by Ibrahim in the fire, and by the Prophet ﷺ", ("bukhari", "4563"), None),
    ("yunus", "لَا إِلٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ",
     "La ilaha illa anta subhanaka inni kuntu minaz-zalimin", 33,
     "The supplication of Yunus: whoever calls with it is answered", ("tirmidhi", "3505"), None),
    ("juwairiya",
     "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ",
     "SubhanAllahi wa bihamdihi, adada khalqihi, wa rida nafsihi, wa zinata arshihi, wa midada kalimatihi", 3,
     "Three times outweighs a whole morning of dhikr", ("muslim", "2726a"), None),
]

# The tasbih after every prayer: Muslim 596.
AFTER_SALAH = (("Never disappointed: after every prescribed prayer"), ("muslim", "596a"))

MARKS = re.compile("[ؐ-ًؚ-ٰٟۖ-ۭـ]")


def norm(s):
    s = MARKS.sub("", s)
    s = re.sub("[أإآٱ]", "ا", s).replace("ى", "ي").replace("ؤ", "و").replace("ئ", "ي")
    s = re.sub("[^ء-ي ]", " ", s)
    return " ".join(s.split())


def dart(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


def main():
    path = os.path.join(tempfile.mkdtemp(), "h.db")
    with gzip.open(os.path.join(ROOT, "tool", "data", "hadith.db.gz")) as f, open(path, "wb") as out:
        out.write(f.read())
    db = sqlite3.connect(path)

    def hadith(col, num):
        r = db.execute("SELECT ref, grade, ar FROM hadith WHERE col=? AND num=?", (col, num)).fetchone()
        if r is None:
            raise SystemExit(f"{col} {num} not in the database")
        if r[1] and r[1].lower().startswith(WEAK):
            raise SystemExit(f"{r[0]} is graded {r[1]}")
        return r

    lines = []
    for id_, ar, latin, target, virtue, (col, num), text in DHIKR:
        ref, grade, _ = hadith(col, num)
        words = hadith(*(text or (col, num)))[2]
        if norm(ar) not in norm(words):
            raise SystemExit(f"{id_}: the Arabic is not in {text or (col, num)}")
        lines.append(
            f"  Dhikr({dart(id_)}, {dart(ar)}, {dart(latin)}, {target}, "
            f"virtue: {dart(virtue)}, source: DhikrSource({dart(col)}, {dart(num)}, {dart(ref)}, {dart(grade) if grade else 'null'})),"
        )
    v, (col, num) = AFTER_SALAH
    ref, grade, _ = hadith(col, num)
    out = f"""// Generated by tool/build_dhikr.py from the hadith database. Do not edit.
// ignore_for_file: lines_longer_than_80_chars

import 'dhikr.dart';

const builtInDhikr = <Dhikr>[
{chr(10).join(lines)}
];

const afterSalahVirtue = {dart(v)};
const afterSalahSource = DhikrSource({dart(col)}, {dart(num)}, {dart(ref)}, {dart(grade) if grade else 'null'});
"""
    with open(os.path.join(ROOT, "lib", "features", "counter", "dhikr_data.dart"), "w", encoding="utf8") as f:
        f.write(out)
    print(len(DHIKR), "dhikr checked")


if __name__ == "__main__":
    main()
