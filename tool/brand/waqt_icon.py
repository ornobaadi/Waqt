"""Waqt brand artwork: the app icon (a believer in sujood under the crescent's light) and its variants.

Writes SVG masters to assets/brand/ and renders every PNG the app and Play Console need, using
headless Chrome (no Python packages required):

    python tool/brand/waqt_icon.py

Outputs
  assets/brand/*.svg                         masters (full icon, adaptive layers, monochrome, splash mark)
  android/app/src/main/res/mipmap-*/          legacy + adaptive launcher PNGs
  android/app/src/main/res/drawable-*/        splash mark + notification icon
  docs/store/play-icon-512.png               Play Console icon
  docs/store/feature-graphic.png             Play Console feature graphic (1024x500)
  web/icons/*, web/favicon.png               web app icons
"""
import math
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RES = ROOT / 'android/app/src/main/res'
BRAND = ROOT / 'assets/brand'
STORE = ROOT / 'docs/store'

NAVY_TOP, NAVY_BOTTOM = '#1C2350', '#0B1030'
CREAM = '#FBF3E2'
GOLD_LINE = '#C9A55A'

_n = [0]


def uid(p):
    _n[0] += 1
    return f'{p}{_n[0]}'


# ---------------------------------------------------------------- primitives

def crescent(cx, cy, r, fill, thin=0.84, shift=0.36):
    m = uid('m')
    hx, hy = cx + shift * r, cy - shift * r * 0.45
    return (f'<mask id="{m}" maskUnits="userSpaceOnUse" x="-50" y="-50" width="400" height="400">'
            f'<rect x="-50" y="-50" width="400" height="400" fill="#fff"/>'
            f'<circle cx="{hx:.2f}" cy="{hy:.2f}" r="{thin * r:.2f}" fill="#000"/></mask>'
            f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}" mask="url(#{m})"/>')


def star8(cx, cy, s):
    R = s * math.sqrt(2)
    r = s / math.cos(math.radians(22.5))
    return ' '.join(f'{cx + (R if k % 2 == 0 else r) * math.cos(math.radians(-90 + k * 22.5)):.1f},'
                    f'{cy + (R if k % 2 == 0 else r) * math.sin(math.radians(-90 + k * 22.5)):.1f}' for k in range(16))


def stars(lst, fill=CREAM):
    return ''.join(f'<polygon points="{star8(x, y, s)}" fill="{fill}" opacity=".9"/>' for x, y, s in lst)


def lattice(color, op, x0=-32, x1=300, y0=-32, y1=300):
    out = ''.join(f'<polygon points="{star8(x, y, 14)}" fill="none" stroke="{color}" stroke-width="1.2"/>'
                  for y in range(y0, y1, 64) for x in range(x0, x1, 64))
    return f'<g opacity="{op}">{out}</g>'


def ray(mx, my, x1, x2, by, op=.38):
    m = uid('r')
    return (f'<linearGradient id="{m}" gradientUnits="userSpaceOnUse" x1="{mx}" y1="{my}" x2="{(x1 + x2) / 2}" y2="{by}">'
            f'<stop offset="0" stop-color="#F5DFA0" stop-opacity="{op}"/><stop offset="1" stop-color="#F5DFA0" stop-opacity="0.10"/></linearGradient>'
            f'<path d="M{mx - 12} {my} L{mx + 12} {my} L{x2} {by} L{x1} {by} Z" fill="url(#{m})"/>')


def sujood(cx, ground, size, fill):
    """Believer in sujood facing the light. Body and arm are one smooth outline; the head is separate.
    Drawn in a 640-unit box with the floor at y=600."""
    k = size / 640
    tx, ty = cx - 320 * k, ground - 600 * k
    body = ('M96 600 L300 600 C328 600 342 582 338 558 C334 530 318 500 314 474 C312 456 330 446 352 452 '
            'L388 468 C384 500 388 530 398 550 C406 566 418 578 428 588 C434 596 440 600 450 600 L484 600 '
            'C494 600 496 586 486 584 L456 580 C448 576 444 566 446 556 C450 528 458 500 470 474 '
            'C478 452 468 436 448 426 L322 324 C276 292 206 296 186 346 C172 382 178 428 198 462 '
            'C210 486 206 520 172 530 L118 534 C90 536 76 556 80 580 C82 594 88 600 96 600 Z')
    hx, hy, hr = 560, 538, 62
    m = uid('sj')
    return (f'<g transform="translate({tx:.3f} {ty:.3f}) scale({k:.5f})">'
            f'<mask id="{m}" maskUnits="userSpaceOnUse" x="-100" y="-100" width="840" height="840">'
            f'<rect x="-100" y="-100" width="840" height="840" fill="#fff"/><circle cx="{hx}" cy="{hy}" r="{hr + 20}" fill="#000"/></mask>'
            f'<g mask="url(#{m})"><path d="{body}" fill="{fill}"/></g><circle cx="{hx}" cy="{hy}" r="{hr}" fill="{fill}"/></g>')


GOLD_DEF = ('<linearGradient id="gold" x1="0" y1="0" x2="0" y2="1">'
            '<stop offset="0" stop-color="#F5DFA0"/><stop offset="1" stop-color="#C99A45"/></linearGradient>')


def ground_defs():
    return (GOLD_DEF +
            f'<linearGradient id="navy" x1="0" y1="0" x2="0.4" y2="1"><stop offset="0" stop-color="{NAVY_TOP}"/>'
            f'<stop offset="1" stop-color="{NAVY_BOTTOM}"/></linearGradient>'
            '<radialGradient id="glow" cx=".5" cy=".38" r=".55"><stop offset="0" stop-color="#fff" stop-opacity=".10"/>'
            '<stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient>')


# ---------------------------------------------------------------- scene (256-unit canvas)

def sky():
    return (ray(186, 72, 40, 168, 204)
            + stars([(60, 66, 3), (40, 44, 3.5), (222, 116, 2), (42, 124, 2)]))


def believer(fill=CREAM, floor_op=.75):
    return (f'<rect x="36" y="204" width="184" height="5" rx="2.5" fill="{fill}" opacity="{floor_op}"/>'
            + sujood(122, 204, 186, fill))


def moon(fill='url(#gold)'):
    return crescent(186, 58, 18, fill)


def background_256():
    return (f'<rect width="256" height="256" fill="url(#navy)"/>' + lattice(GOLD_LINE, .10)
            + '<rect width="256" height="256" fill="url(#glow)"/>')


def svg(w, h, view, body, defs=''):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="{view}">'
            f'<defs>{defs}</defs>{body}</svg>')


def full_icon():
    """Square, full-bleed: Play Console and launchers apply their own corner mask."""
    return svg(512, 512, '0 0 256 256', background_256() + sky() + believer() + moon(), ground_defs())


# Adaptive icons: 108dp canvas, only the centre 66dp circle is guaranteed visible.
# The 256-unit scene is centred on (128, 132) and scaled so its artwork spans ~64dp.
ADAPT = 'translate(54 54) scale(0.285) translate(-130 -134)'


def adaptive_background():
    body = (f'<rect width="108" height="108" fill="url(#navy)"/>'
            f'<g transform="scale(0.421875)">{lattice(GOLD_LINE, .10)}</g>'
            '<rect width="108" height="108" fill="url(#glow)"/>')
    return svg(432, 432, '0 0 108 108', body, ground_defs())


def adaptive_foreground():
    return svg(432, 432, '0 0 108 108', f'<g transform="{ADAPT}">{sky()}{believer()}{moon()}</g>', ground_defs())


def monochrome():
    """Themed icons (Android 13+): one colour, the system tints it."""
    body = f'<g transform="{ADAPT}">{believer("#FFFFFF", 1)}{moon("#FFFFFF")}</g>'
    return svg(432, 432, '0 0 108 108', body)


def splash_mark():
    """Android 12+ splash: icon shown in a 240dp canvas, keep inside the centre 160dp circle."""
    body = f'<g transform="translate(144 144) scale(0.84) translate(-130 -134)">{sky()}{believer()}{moon()}</g>'
    return svg(288, 288, '0 0 288 288', body, ground_defs())


def notification_icon():
    """Status-bar icon: white silhouette on transparent, 24dp."""
    body = f'<g transform="translate(12 12) scale(0.118) translate(-130 -140)">{believer("#FFFFFF", 1)}{moon("#FFFFFF")}</g>'
    return svg(96, 96, '0 0 24 24', body)


def feature_graphic():
    font = (ROOT / 'assets/fonts/SchibstedGrotesk.ttf').as_uri()
    inter = (ROOT / 'assets/fonts/Inter.ttf').as_uri()
    scene = (f'<g transform="translate(560 -6) scale(1.95)">{sky()}{believer()}{moon()}</g>')
    body = (f'<rect width="1024" height="500" fill="url(#navyw)"/>'
            f'<g transform="scale(1.0)">{lattice(GOLD_LINE, .08, -32, 1100, -32, 560)}</g>'
            '<rect width="1024" height="500" fill="url(#glowfg)"/>'
            + scene +
            f'<text x="72" y="214" font-family="Schibsted" font-weight="800" font-size="104" fill="{CREAM}" letter-spacing="-3">Waqt</text>'
            f'<text x="76" y="276" font-family="Inter" font-weight="500" font-size="32" fill="#E9DDBF">The right dua for every moment</text>'
            f'<text x="76" y="340" font-family="Inter" font-weight="600" font-size="21" fill="#C9A55A" letter-spacing="1.5">'
            'PRAYER TIMES  ·  DUAS  ·  QIBLA  ·  HIJRI</text>')
    defs = (ground_defs()
            + f'<linearGradient id="navyw" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{NAVY_TOP}"/>'
              f'<stop offset="1" stop-color="{NAVY_BOTTOM}"/></linearGradient>'
              '<radialGradient id="glowfg" cx=".78" cy=".3" r=".6"><stop offset="0" stop-color="#fff" stop-opacity=".09"/>'
              '<stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient>'
              f'<style>@font-face{{font-family:Schibsted;src:url("{font}")}}@font-face{{font-family:Inter;src:url("{inter}")}}</style>')
    return svg(1024, 500, '0 0 1024 500', body, defs)


# ---------------------------------------------------------------- rendering

def chrome():
    for c in [r'C:\Program Files\Google\Chrome\Application\chrome.exe',
              r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
              shutil.which('google-chrome') or '', shutil.which('chromium') or '']:
        if c and Path(c).exists():
            return c
    sys.exit('Need Chrome or Edge to render PNGs.')


def render(svg_text, out, w, h, transparent=True, rounded=None):
    out = Path(out)
    out.parent.mkdir(parents=True, exist_ok=True)
    clip = f'border-radius:{rounded};overflow:hidden;' if rounded else ''
    html = (f'<!doctype html><html><head><style>html,body{{margin:0;background:transparent}}'
            f'div{{width:{w}px;height:{h}px;{clip}}}svg{{display:block;width:{w}px;height:{h}px}}</style></head>'
            f'<body><div>{svg_text}</div></body></html>')
    with tempfile.TemporaryDirectory() as d:
        page = Path(d) / 'p.html'
        page.write_text(html, encoding='utf-8')
        args = [chrome(), '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1',
                f'--window-size={w},{h}', f'--screenshot={out}', '--virtual-time-budget=3000', '--allow-file-access-from-files']
        if transparent:
            args.append('--default-background-color=00000000')
        subprocess.run(args + [page.as_uri()], check=True, capture_output=True)
    print('  ', out.relative_to(ROOT))


def main():
    BRAND.mkdir(parents=True, exist_ok=True)
    masters = {
        'waqt-icon.svg': full_icon(), 'adaptive-background.svg': adaptive_background(),
        'adaptive-foreground.svg': adaptive_foreground(), 'monochrome.svg': monochrome(),
        'splash-mark.svg': splash_mark(), 'notification.svg': notification_icon(), 'feature-graphic.svg': feature_graphic(),
    }
    for name, text in masters.items():
        (BRAND / name).write_text(text, encoding='utf-8')
    print('masters -> assets/brand/')

    densities = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
    for d, s in densities.items():
        render(masters['waqt-icon.svg'], RES / f'mipmap-{d}/ic_launcher.png', round(48 * s), round(48 * s), rounded='22%')
        render(masters['waqt-icon.svg'], RES / f'mipmap-{d}/ic_launcher_round.png', round(48 * s), round(48 * s), rounded='50%')
        for layer in ('foreground', 'background'):
            render(masters[f'adaptive-{layer}.svg'], RES / f'mipmap-{d}/ic_launcher_{layer}.png', round(108 * s), round(108 * s))
        render(masters['monochrome.svg'], RES / f'mipmap-{d}/ic_launcher_monochrome.png', round(108 * s), round(108 * s))
        render(masters['splash-mark.svg'], RES / f'drawable-{d}/splash_mark.png', round(288 * s), round(288 * s))
        render(masters['notification.svg'], RES / f'drawable-{d}/ic_notification.png', round(24 * s), round(24 * s))

    render(masters['waqt-icon.svg'], STORE / 'play-icon-512.png', 512, 512, transparent=False)
    web = ROOT / 'web'
    for name, px in [('icons/Icon-192.png', 192), ('icons/Icon-512.png', 512),
                     ('icons/Icon-maskable-192.png', 192), ('icons/Icon-maskable-512.png', 512)]:
        render(masters['waqt-icon.svg'], web / name, px, px, transparent=False)
    render(masters['waqt-icon.svg'], web / 'favicon.png', 32, 32, rounded='22%')
    render(masters['feature-graphic.svg'], STORE / 'feature-graphic.png', 1024, 500, transparent=False)


if __name__ == '__main__':
    main()
