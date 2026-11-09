"""Play Store art: the feature graphic (1024x500) and phone screenshots (1080x1920), built around real
app screens from the golden tests, some shown as angled 3D phones.

    flutter test --tags screenshots --update-goldens   # refresh the app screens first
    python tool/brand/store_screens.py

Output: docs/store/feature-graphic.png, docs/store/screenshots/NN_name.png
The app icon is not touched here (see waqt_icon.py).
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from waqt_icon import ROOT, render  # noqa: E402

GOLDENS = ROOT / 'test/screenshots/goldens'
OUT = ROOT / 'docs/store/screenshots'
STORE = ROOT / 'docs/store'

NIGHT = ('#1E2656', '#0A0E2A', '#FBF3E2', '#CDBF9C')  # top, bottom, title, subtitle
DAWN = ('#F7E7C8', '#EFD3A6', '#1C1814', '#5E5240')

# (title, subtitle, palette, layout, screens)
SHOTS = [
    ('The right dua, right now', 'for the moment you are in', NIGHT, 'tilt', ['40_now_salah_ticks']),
    ('Changes with the sky', 'from Fajr to the last third of the night', DAWN, 'pair', ['03_now_dhuhr', '12_now_last_third']),
    ('Every hadith sourced', 'Arabic, meaning and grade, every time', NIGHT, 'tilt-r', ['17b_dua_sheet_short']),
    ('Track your salah, gently', 'one tap a prayer, no guilt', DAWN, 'pair', ['42_today_ring', '43_progress']),
    ('Ramadan, made easy', 'suhoor, iftar and the last ten nights', NIGHT, 'tilt-r', ['21_now_ramadan_qadr']),
    ('Find the Qibla', 'turn until it glows', NIGHT, 'straight', ['30_qibla_turn']),
    ('Face the Qibla at night', 'turn, and the screen glows blue', NIGHT, 'pair', ['34_qibla_night_turn', '34b_qibla_night_aligned']),
    ('A tasbih that remembers', 'your count and today\'s total', DAWN, 'tilt', ['22_counter']),
    ('In seven languages', 'English, العربية, اردو, বাংলা and more', NIGHT, 'pair', ['07_now_arabic_rtl', '30_now_bn']),
]


def fonts() -> str:
    f = lambda n: (ROOT / f'assets/fonts/{n}.ttf').as_uri()  # noqa: E731
    return (f'<style>.r div{{width:auto;height:auto}}@font-face{{font-family:Disp;src:url("{f("BricolageGrotesque")}")}}'
            f'@font-face{{font-family:Inter;src:url("{f("Inter")}")}}'
            f'@font-face{{font-family:Naskh;src:url("{f("NotoNaskhArabic")}")}}'
            f'@font-face{{font-family:Nast;src:url("{f("NotoNastaliqUrdu")}")}}'
            f'@font-face{{font-family:Beng;src:url("{f("NotoSansBengali")}")}}</style>')


def phone(name: str, w: int, x: int, y: int, transform: str = '', z: int = 1, shadow: float = .45) -> str:
    """A phone with a thin dark bezel showing one app screen; `transform` gives the 3D angle."""
    h = round(w * 2532 / 1170)
    b = round(w * .028)
    return (f'<div style="position:absolute;left:{x}px;top:{y}px;width:{w + 2 * b}px;height:{h + 2 * b}px;z-index:{z};'
            f'transform:{transform or "none"};transform-origin:50% 50%;border-radius:{round(w * .13)}px;'
            f'background:linear-gradient(135deg,#3A3F52,#0E1018 40%,#262A38);padding:{b}px;box-sizing:border-box;'
            f'box-shadow:0 {round(w * .06)}px {round(w * .16)}px rgba(0,0,0,{shadow}),'
            f'inset 0 0 0 2px rgba(255,255,255,.10)">'
            f'<img src="{(GOLDENS / f"{name}.png").as_uri()}" style="display:block;width:{w}px;height:{h}px;'
            f'border-radius:{round(w * .13) - b}px"></div>')


def frame(title: str, sub: str, pal, layout: str, screens) -> str:
    top, bottom, ink, soft = pal
    persp = 'perspective:2600px;'
    if layout == 'straight':
        body = phone(screens[0], 640, 200, 380)
    elif layout in ('tilt', 'tilt-r'):
        s = -1 if layout == 'tilt' else 1
        body = phone(screens[0], 640, 200, 400, f'rotateY({s * 16}deg) rotateX(5deg) rotateZ({-s * 2}deg)')
    else:  # pair: back phone angled one way, front phone the other
        body = (phone(screens[0], 520, 70, 520, 'rotateY(18deg) rotateZ(-5deg) translateZ(-120px)', 1, .35)
                + phone(screens[1], 540, 470, 410, 'rotateY(-14deg) rotateZ(3deg)', 2))
    glow = 'rgba(255,236,190,.16)' if pal is NIGHT else 'rgba(255,255,255,.55)'
    return f'''{fonts()}<div class="r"><div style="position:relative;width:1080px;height:1920px;overflow:hidden;
  background:radial-gradient(900px 700px at 50% 62%,{glow},transparent 70%),linear-gradient(170deg,{top},{bottom});
  font-family:Inter,Naskh,Nast,Beng">
<div style="position:absolute;left:80px;right:80px;top:118px;text-align:center;color:{ink};font-family:Disp,Naskh;
  font-weight:800;font-size:84px;line-height:1.02;letter-spacing:-2.5px;font-variation-settings:'opsz' 96">{title}</div>
<div style="position:absolute;left:80px;right:80px;top:226px;text-align:center;color:{soft};font-size:38px;font-weight:500">{sub}</div>
<div style="position:absolute;inset:0;{persp}">{body}</div>
</div></div>'''


def feature_graphic() -> str:
    top, bottom, ink, soft = NIGHT
    icon = (STORE / 'play-icon-512.png').as_uri()
    phones = (phone('06_now_night', 250, 590, 70, 'rotateY(22deg) rotateZ(-6deg) translateZ(-80px)', 1, .5)
              + phone('40_now_salah_ticks', 270, 760, 36, 'rotateY(-18deg) rotateZ(4deg)', 2, .55))
    return f'''{fonts()}<div class="r"><div style="position:relative;width:1024px;height:500px;overflow:hidden;
  background:radial-gradient(520px 420px at 78% 40%,rgba(255,236,190,.18),transparent 70%),linear-gradient(150deg,{top},{bottom});
  font-family:Inter">
<img src="{icon}" style="position:absolute;left:72px;top:96px;width:96px;height:96px;border-radius:24px;
  box-shadow:0 12px 30px rgba(0,0,0,.4)">
<div style="position:absolute;left:66px;top:200px;color:{ink};font-family:Disp;font-weight:800;font-size:116px;
  letter-spacing:-4px;line-height:1;font-variation-settings:'opsz' 96">Waqt</div>
<div style="position:absolute;left:72px;top:330px;width:440px;color:{soft};font-size:30px;font-weight:500;line-height:1.3">
  The right dua for every moment of your day</div>
<div style="position:absolute;inset:0;perspective:1800px">{phones}</div>
</div></div>'''


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.glob('*.png'):
        old.unlink()
    render(feature_graphic(), STORE / 'feature-graphic.png', 1024, 500, transparent=False)
    for i, (title, sub, pal, layout, screens) in enumerate(SHOTS, 1):
        render(frame(title, sub, pal, layout, screens), OUT / f'{i:02d}_{screens[0]}.png', 1080, 1920, transparent=False)


if __name__ == '__main__':
    main()
