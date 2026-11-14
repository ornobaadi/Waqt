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

# Crops are in the 924-wide preview of each golden (the app screens are 1170x2532).
K = 1170 / 924

# (title, subtitle, palette, layout, screens, floats). Play takes at most 8. A float is one of:
#   ('crop', screen, (x0, y0, x1, y1), width, x, y, transform[, radius, pad, bg])  a piece of a screen, anywhere
#   ('lift', screen, (x0, y0, x1, y1), pad, bg, lift)  a piece lifted straight off the tilted phone, same angle
#   ('langs',)  the seven languages as pills around the phones
PAGE = '#F8F4E8'  # the app's page
ROW = '#F0ECE0'  # a row group on the page
SHOTS = [
    ('The right dua, right now', 'for the moment you are in', NIGHT, 'tilt', ['40_now_salah_ticks'],
     [('crop', '42d_today_store', (48, 150, 876, 566), 640, 30, 1400,
       'rotateY(16deg) rotateZ(-4deg) translateZ(140px)')]),
    ('The Quran, ayah by ayah', 'Arabic, how to say it, and its meaning', DAWN, 'tilt-r', ['71d_quran_reciting'],
     [('crop', '71d_quran_reciting', (48, 300, 876, 755), 760, 30, 860,
       'rotateY(-10deg) rotateZ(-3deg) translateZ(180px)'),
      ('crop', '71d_quran_reciting', (30, 1820, 895, 1970), 820, 150, 1620,
       'rotateX(8deg) rotateZ(2deg) translateZ(220px)')]),
    ('Ayat al-Kursi in one tap', 'and what to read right now', NIGHT, 'straight', ['70_quran'],
     [('crop', '70c_quran_passages', (70, 1015, 860, 1122), 700, 150, 1290,
       'rotateX(4deg) rotateZ(-3deg) translateZ(200px)', 44, 36, ROW)]),
    ('Duas for all you do', 'travel, rain, worry, and 11 more', DAWN, 'pair', ['16_duas_library', '16f_dua_page'],
     [('crop', '16_duas_library', (477, 503, 876, 862), 420, 520, 1380,
       'rotateY(-18deg) rotateZ(6deg) translateZ(240px)')]),
    ('Track your salah, gently', 'one tap a prayer, no guilt', NIGHT, 'pair', ['42d_today_store', '43_progress'],
     [('crop', '43_progress', (48, 152, 876, 338), 640, 40, 1560,
       'rotateY(14deg) rotateZ(-4deg) translateZ(220px)')]),
    ('Every hadith sourced', 'Arabic, meaning and grade, every time', DAWN, 'tilt', ['16f_dua_page'],
     [('lift', '16f_dua_page', (40, 1548, 890, 1745), 28, PAGE, 110)]),
    ('Face the Qibla', 'turn until it glows', NIGHT, 'pair', ['34_qibla_night_turn', '34b_qibla_night_aligned'], []),
    ('In seven languages', 'English, ⁨العربية⁩, ⁨اردو⁩, বাংলা and more', NIGHT, 'pair',
     ['07_now_arabic_rtl', '30_now_bn'], [('langs',)]),
]

# Where the single phone sits in 'straight' and 'tilt' shots: left, top, screen width.
PHONE = (220, 390, 600)


def tilt(layout: str) -> str:
    s = -1 if layout == 'tilt' else 1
    return f'rotateY({s * 16}deg) rotateX(5deg) rotateZ({-s * 2}deg)'


def fonts() -> str:
    f = lambda n: (ROOT / f'assets/fonts/{n}.ttf').as_uri()  # noqa: E731
    return (f'<style>.r div{{width:auto;height:auto}}@font-face{{font-family:Disp;src:url("{f("BricolageGrotesque")}")}}'
            f'@font-face{{font-family:Inter;src:url("{f("Inter")}")}}'
            f'@font-face{{font-family:Naskh;src:url("{f("NotoNaskhArabic")}")}}'
            f'@font-face{{font-family:Nast;src:url("{f("NotoNastaliqUrdu")}")}}'
            f'@font-face{{font-family:Beng;src:url("{f("AnekBangla")}")}}</style>')


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


def crop(name: str, box, w: int, x: int, y: int, transform: str, radius: int = 40, pad: int = 0, bg: str = '',
         origin: str = '50% 50%') -> str:
    """A piece of a real app screen, lifted off the phone and floating in front of it. With `pad`, it sits on a
    card of the screen's own colour, so its text has room around it."""
    x0, y0, x1, y1 = (round(v * K) for v in box)
    scale = w / (x1 - x0)
    h = round((y1 - y0) * scale)
    inner = max(radius - pad, 14) if pad else radius
    img = (f'<div style="position:relative;width:{w}px;height:{h}px;overflow:hidden;border-radius:{inner}px">'
           f'<img src="{(GOLDENS / f"{name}.png").as_uri()}" style="position:absolute;left:{-x0 * scale}px;'
           f'top:{-y0 * scale}px;width:{1170 * scale}px;height:{2532 * scale}px;max-width:none"></div>')
    return (f'<div style="position:absolute;left:{x - pad}px;top:{y - pad}px;width:{w}px;height:{h}px;padding:{pad}px;'
            f'z-index:5;border-radius:{radius}px;background:{bg or "transparent"};transform:{transform};'
            f'transform-origin:{origin};box-shadow:0 50px 90px rgba(0,0,0,.40),0 14px 30px rgba(0,0,0,.22),'
            f'0 0 0 2px rgba(255,255,255,.55)">{img}</div>')


def lift(layout: str, name: str, box, pad: int, bg: str, up: int) -> str:
    """A piece of the tilted phone's screen, at its own place on the screen and at the phone's own angle, raised
    `up` px off the glass towards the viewer."""
    left, top, w = PHONE
    b = round(w * .028)
    s = w / 1170
    x0, y0, x1, _ = (v * K for v in box)
    cx, cy = left + w / 2 + b, top + round(w * 2532 / 1170) / 2 + b  # the phone's centre, its 3D pivot
    x, y = left + b + x0 * s, top + b + y0 * s
    origin = f'{cx - x + pad}px {cy - y + pad}px'
    return crop(name, box, round((x1 - x0) * s), round(x), round(y), f'{tilt(layout)} translateZ({up}px)',
                34, pad, bg, origin)


def langs() -> str:
    """The seven languages as pills floating around the phones, each in its own script, each at its own depth."""
    pills = [('English', 'Inter', 40, 560, -8, 160), ('العربية', 'Naskh', 760, 470, 7, 220),
             ('اردو', 'Nast', 80, 1040, 6, 200), ('বাংলা', 'Beng', 740, 1000, -6, 240),
             ('Bahasa', 'Inter', 70, 1540, -5, 180), ('Türkçe', 'Inter', 730, 1560, 5, 210),
             ('Français', 'Inter', 380, 1700, -2, 260)]
    return ''.join(
        f'<div style="position:absolute;left:{x}px;top:{y}px;z-index:5;padding:22px 40px;border-radius:999px;'
        f'background:linear-gradient(160deg,#FFFBF2,#F1E6CC);color:#1C1814;font-family:{fam};font-size:46px;'
        f'font-weight:600;line-height:1.25;white-space:nowrap;transform:rotateY({-r}deg) rotateZ({r}deg) translateZ({z}px);'
        f'box-shadow:0 34px 60px rgba(0,0,0,.45),0 10px 20px rgba(0,0,0,.25),inset 0 2px 0 rgba(255,255,255,.9),'
        f'0 0 0 2px rgba(255,255,255,.5)">{t}</div>'
        for t, fam, x, y, r, z in pills)


def deco(night: bool) -> str:
    """Soft light behind the phones and a few sparks of it, so the cards float in air, not on a wall."""
    c = '255,224,160' if night else '255,255,255'
    orbs = (f'<div style="position:absolute;left:-180px;top:520px;width:620px;height:620px;border-radius:50%;'
            f'background:radial-gradient(circle,rgba({c},.30),transparent 68%)"></div>'
            f'<div style="position:absolute;left:540px;top:1150px;width:760px;height:760px;border-radius:50%;'
            f'background:radial-gradient(circle,rgba({c},.24),transparent 68%)"></div>')
    sparks = ''.join(
        f'<svg style="position:absolute;left:{x}px;top:{y}px;opacity:{o};width:{s}px;height:{s}px" viewBox="0 0 24 24">'
        f'<path d="M12 0C13 8 16 11 24 12C16 13 13 16 12 24C11 16 8 13 0 12C8 11 11 8 12 0Z" fill="rgb({c})"/></svg>'
        for x, y, s, o in [(120, 360, 34, .8), (930, 420, 26, .7), (980, 980, 40, .55), (70, 1180, 22, .6),
                           (860, 1830, 30, .5), (200, 1840, 20, .5)])
    return orbs + sparks


def frame(title: str, sub: str, pal, layout: str, screens, floats=()) -> str:
    top, bottom, ink, soft = pal
    night = pal is NIGHT
    persp = 'perspective:2600px;'
    px, py, pw = PHONE
    if layout == 'straight':
        body = phone(screens[0], pw, px, py, 'rotateX(4deg)')
    elif layout in ('tilt', 'tilt-r'):
        body = phone(screens[0], pw, px, py, tilt(layout))
    else:  # pair: back phone angled one way, front phone the other
        body = (phone(screens[0], 500, 70, 500, 'rotateY(18deg) rotateZ(-5deg) translateZ(-120px)', 1, .35)
                + phone(screens[1], 520, 480, 400, 'rotateY(-14deg) rotateZ(3deg)', 2))
    for f in floats:
        if f[0] == 'crop':
            body += crop(*f[1:])
        elif f[0] == 'lift':
            body += lift(layout, *f[1:])
        else:
            body += langs()
    glow = 'rgba(255,236,190,.16)' if night else 'rgba(255,255,255,.55)'
    return f'''{fonts()}<div class="r"><div style="position:relative;width:1080px;height:1920px;overflow:hidden;
  background:radial-gradient(900px 700px at 50% 62%,{glow},transparent 70%),linear-gradient(170deg,{top},{bottom});
  font-family:Inter,Naskh,Nast,Beng">
{deco(night)}
<div style="position:absolute;left:70px;right:70px;top:118px;text-align:center;color:{ink};font-family:Disp,Naskh;
  font-weight:800;font-size:84px;line-height:1.02;letter-spacing:-2.5px;font-variation-settings:'opsz' 96">{title}</div>
<div style="position:absolute;left:70px;right:70px;top:226px;text-align:center;color:{soft};font-size:38px;font-weight:500">{sub}</div>
<div style="position:absolute;inset:0;{persp}">{body}</div>
</div></div>'''


def feature_graphic() -> str:
    top, bottom, ink, soft = NIGHT
    icon = (STORE / 'play-icon-512.png').as_uri()
    # The Quran reader in front, Now behind it, and the player lifted off the reader.
    phones = (phone('40_now_salah_ticks', 250, 570, 70, 'rotateY(22deg) rotateZ(-6deg) translateZ(-80px)', 1, .5)
              + phone('71d_quran_reciting', 270, 750, 36, 'rotateY(-18deg) rotateZ(4deg)', 2, .55)
              + crop('71d_quran_reciting', (30, 1820, 895, 1970), 300, 640, 372,
                     'rotateY(-12deg) rotateZ(3deg) translateZ(120px)', 26))
    return f'''{fonts()}<div class="r"><div style="position:relative;width:1024px;height:500px;overflow:hidden;
  background:radial-gradient(520px 420px at 78% 40%,rgba(255,236,190,.18),transparent 70%),linear-gradient(150deg,{top},{bottom});
  font-family:Inter">
<svg style="position:absolute;left:520px;top:60px;opacity:.75;width:22px;height:22px" viewBox="0 0 24 24">
  <path d="M12 0C13 8 16 11 24 12C16 13 13 16 12 24C11 16 8 13 0 12C8 11 11 8 12 0Z" fill="#FFE0A0"/></svg>
<svg style="position:absolute;left:980px;top:300px;opacity:.6;width:18px;height:18px" viewBox="0 0 24 24">
  <path d="M12 0C13 8 16 11 24 12C16 13 13 16 12 24C11 16 8 13 0 12C8 11 11 8 12 0Z" fill="#FFE0A0"/></svg>
<img src="{icon}" style="position:absolute;left:72px;top:80px;width:96px;height:96px;border-radius:24px;
  box-shadow:0 12px 30px rgba(0,0,0,.4)">
<div style="position:absolute;left:66px;top:186px;color:{ink};font-family:Disp;font-weight:800;font-size:116px;
  letter-spacing:-4px;line-height:1;font-variation-settings:'opsz' 96">Waqt</div>
<div style="position:absolute;left:72px;top:316px;width:440px;color:{soft};font-size:30px;font-weight:500;line-height:1.3">
  Quran, duas and prayer times for every moment of your day</div>
<div style="position:absolute;inset:0;perspective:1800px">{phones}</div>
</div></div>'''


def beta_graphic() -> str:
    """Reddit / forum banner asking for closed-beta testers (same art, a tester call instead of the tagline)."""
    top, bottom, ink, soft = NIGHT
    icon = (STORE / 'play-icon-512.png').as_uri()
    phones = (phone('06_now_night', 250, 590, 70, 'rotateY(22deg) rotateZ(-6deg) translateZ(-80px)', 1, .5)
              + phone('40_now_salah_ticks', 270, 760, 36, 'rotateY(-18deg) rotateZ(4deg)', 2, .55))
    return f'''{fonts()}<div class="r"><div style="position:relative;width:1024px;height:500px;overflow:hidden;
  background:radial-gradient(520px 420px at 78% 40%,rgba(255,236,190,.18),transparent 70%),linear-gradient(150deg,{top},{bottom});
  font-family:Inter">
<div style="position:absolute;left:72px;top:70px;display:flex;align-items:center;gap:18px">
  <img src="{icon}" style="width:72px;height:72px;border-radius:18px;box-shadow:0 10px 26px rgba(0,0,0,.4)">
  <div style="color:{ink};font-family:Disp;font-weight:800;font-size:56px;letter-spacing:-2px;line-height:1">Waqt</div></div>
<div style="position:absolute;left:72px;top:176px;padding:8px 18px;border-radius:999px;background:#F2C46D;color:#1C1814;
  font-size:22px;font-weight:700;letter-spacing:2px">CLOSED BETA · ANDROID</div>
<div style="position:absolute;left:66px;top:226px;width:520px;color:{ink};font-family:Disp;font-weight:800;font-size:78px;
  letter-spacing:-3px;line-height:.98;font-variation-settings:'opsz' 96">Beta testers<br>wanted</div>
<div style="position:absolute;left:72px;top:400px;width:470px;color:{soft};font-size:24px;font-weight:500;line-height:1.3">
  Help test Waqt for 14 days. Free, no ads, no account.</div>
<div style="position:absolute;inset:0;perspective:1800px">{phones}</div>
</div></div>'''


def main():
    if '--beta' in sys.argv:
        render(beta_graphic(), STORE / 'beta-testers.png', 1024, 500, transparent=False)
        return
    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.glob('*.png'):
        old.unlink()
    render(feature_graphic(), STORE / 'feature-graphic.png', 1024, 500, transparent=False)
    for i, (title, sub, pal, layout, screens, floats) in enumerate(SHOTS, 1):
        render(frame(title, sub, pal, layout, screens, floats), OUT / f'{i:02d}_{screens[0]}.png', 1080, 1920,
               transparent=False)


if __name__ == '__main__':
    main()
