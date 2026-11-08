"""Play Store phone screenshots: a caption over a real app screen (from the golden tests), 1080x1920.

    flutter test --tags screenshots --update-goldens   # refresh the app screens first
    python tool/brand/store_screens.py

Output: docs/store/screenshots/NN_name.png
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from waqt_icon import ROOT, render, lattice, NAVY_TOP, NAVY_BOTTOM, CREAM, GOLD_LINE  # noqa: E402

GOLDENS = ROOT / 'test/screenshots/goldens'
OUT = ROOT / 'docs/store/screenshots'

SHOTS = [
    ('12_now_last_third', 'The right dua', 'for the moment you are in'),
    ('17_dua_sheet', 'Every hadith sourced', 'with its book, number and grade'),
    ('11_today_timeline', 'Your whole day', 'every prayer and moment, in order'),
    ('21_now_ramadan_qadr', 'Ramadan, made easy', 'suhoor, iftar, the last ten nights, Eid'),
    ('30_qibla_turn', 'Find the Qibla', 'turn until it glows'),
    ('22_counter', 'A tasbih that remembers', 'your count and today\'s total'),
    ('63_calendar', 'Hijri calendar', 'with the days worth knowing'),
    ('07_now_arabic_rtl', 'In seven languages', 'English, العربية, اردو, বাংলা and more'),
]


def frame(img: Path, title: str, sub: str) -> str:
    inter = (ROOT / 'assets/fonts/Inter.ttf').as_uri()
    disp = (ROOT / 'assets/fonts/SchibstedGrotesk.ttf').as_uri()
    naskh = (ROOT / 'assets/fonts/NotoNaskhArabic.ttf').as_uri()
    nast = (ROOT / 'assets/fonts/NotoNastaliqUrdu.ttf').as_uri()
    beng = (ROOT / 'assets/fonts/NotoSansBengali.ttf').as_uri()
    w, h = 702, 1520
    return f'''<div style="position:relative;width:1080px;height:1920px;overflow:hidden;
  background:linear-gradient(160deg,{NAVY_TOP},{NAVY_BOTTOM});font-family:Inter,Naskh,Nast,Beng">
<style>
@font-face{{font-family:Inter;src:url("{inter}")}}@font-face{{font-family:Disp;src:url("{disp}")}}
@font-face{{font-family:Naskh;src:url("{naskh}")}}@font-face{{font-family:Nast;src:url("{nast}")}}@font-face{{font-family:Beng;src:url("{beng}")}}
</style>
<svg width="1080" height="1920" viewBox="0 0 1080 1920" style="position:absolute;inset:0">{lattice(GOLD_LINE, .07, -32, 1150, -32, 1990)}</svg>
<div style="position:absolute;left:0;right:0;top:120px;text-align:center;color:{CREAM};font-family:Disp,Naskh;font-weight:800;font-size:76px;letter-spacing:-2px">{title}</div>
<div style="position:absolute;left:0;right:0;top:222px;text-align:center;color:#D9CBA6;font-size:38px;font-weight:500">{sub}</div>
<img src="{img.as_uri()}" style="position:absolute;left:{(1080 - w) // 2}px;top:330px;width:{w}px;height:{h}px;border-radius:56px;
  box-shadow:0 30px 80px rgba(0,0,0,.45);outline:10px solid rgba(255,255,255,.08)">
</div>'''


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for i, (name, title, sub) in enumerate(SHOTS, 1):
        render(frame(GOLDENS / f'{name}.png', title, sub), OUT / f'{i:02d}_{name}.png', 1080, 1920, transparent=False)


if __name__ == '__main__':
    main()
