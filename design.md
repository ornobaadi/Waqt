# Design — Waqt

Canvases: v1 https://claude.ai/artifact/39nPfwUPu7zBapMi2eZdGK · **v2 (current)** https://claude.ai/artifact/QPq4a1m6w5jHmQvfxhyzar

## Concept
"The sky is the interface." One fixed layout; the **moment** changes the sky, accent and content. Users learn where to look once, and every visit feels fresh.

## Signature element — the Sun Arc
- **Day:** a semicircle from sunrise (left) to sunset (right). Dots mark Dhuhr and Asr; a glowing sun sits at the real current position; the travelled part of the arc is filled with the accent.
- **Night:** becomes a horizontal bar Maghrib → Fajr split into thirds; the last third is highlighted; a white dot marks now. Crescent shows the real moon phase.
- Animate sun along the arc with a slow ease; on moment change, crossfade palette (600–900 ms).

## Home layout (390×844 reference)
1. Header: app name, city · Gregorian · Hijri, occasion pill (Jumu'ah / Ramadan 14 / Last third…)
2. Sun arc + big clock + "Current waqt · Next in X"
3. Prayer strip: 6 equal cells; past dimmed, current inverted
4. **Right Now card** (dark, elevated): label + "ends at…", title, one-line why, 2–3 action rows with reference chips
5. Contextual module: checklist (Jumu'ah/bedtime) or "coming up" tiles
6. Bottom nav: Now · Today · Quran · Duas · Settings (floating dock; the Quran reader and the dua pager open above it with their own bottom bars). Quran text in Amiri Quran (`WaqtFonts.quran`).

Other screens: Today timeline (v2), Dua detail sheet (v1 canvas, board 4), Bedtime checklist (v1, board 3).

## Tokens
**Type**
- Display: Bricolage Grotesque 800 (clock 60, titles 23–30, letter-spacing −0.03 to −0.04em)
- UI/body: Inter 400/500/600 (13–15)
- Arabic: Noto Naskh Arabic (28–34 on detail; line-height 1.6–1.7)
- **Always tabular figures** for clocks, times, countdowns.

**Moment palettes** (ground / ink / accent)
| Moment | Ground | Ink | Accent |
|---|---|---|---|
| Fajr | #F7EDE8 | #2A1A16 | #E9B9A0 |
| Dhuhr | #F8F4E8 | #1E1810 | #E6C66A |
| Asr / Friday | #F6F1E7 | #1E1810 | #E8A54B |
| Maghrib | #2A1416 | #FBEDE6 | #E07A5F |
| Night / Tahajjud | #0A0E26 | #E8EBFF | #9FB3FF |
| Bedtime | #17122A | #EEE8FA | #C9B8F0 |

**Shape & depth**: radii 14 (rows) / 18 (strips) / 24 (cards) — concentric (inner = outer − padding). Shadows layered: `0 0 0 1px ink@6%` + soft blur; hero card `0 10px 30px ink@18%`. No gradient washes on cards; gradients only in the sky.

**Spacing**: 4-pt grid; screen padding 16–24.

## UI-quality rules (from ui-skills.com playbook & skills)
- Touch targets ≥ 44×44 (we use 48 for rows/nav).
- `tabular-nums` for all numbers; balanced headings, pretty body wrap.
- Contrast ≥ 4.5:1 for all text incl. 11 px labels; don't rely on hue alone.
- Motion: purposeful, 150–300 ms for UI, springs for sheets; honour reduce-motion (static sky, no parallax).
- Visible focus states; semantic labels for TalkBack; icon buttons have labels.
- Prevent layout shift: fixed-size slots for countdown text.
- Polish: optical alignment of clock in arc, consistent icon stroke (1.75–2 px), no emoji in production UI.

## Motion & 3D (budget-Android friendly)
- Sky: fragment shader (gradient + stars + sun glow), 30 fps cap when idle.
- Subtle tilt parallax (sensors) on sky only.
- Rive objects: lantern (night), misbaha counter (dhikr, with haptics), prayer mat unroll (salah time).
- No human figures or faces.

## Content display rules
- Every action/dua shows a reference chip; tapping opens the detail sheet.
- Detail shows grade badge, grader, translator, link out, review status.
- Never show content whose `review_status != approved` in release builds.

## Name & brand
Name **Waqt (وقت, "time")** — decided. Package `com.ornobaadi.waqt`.
