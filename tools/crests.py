"""Crest icons traced 1:1 from the official Digivice V-Pet crest dots (Wikimon), recoloured per crest,
plus pendant icons (empty + per-crest) drawn in the shape of the anime tag.
usage: crests.py REF_DIR OUT_CRESTS_DIR OUT_ITEMS_DIR"""
import json, os, sys
from PIL import Image
REF, OUT, ITEMS = sys.argv[1:4]; os.makedirs(OUT, exist_ok=True); os.makedirs(ITEMS, exist_ok=True)
def hexc(h): h = h.lstrip('#'); return tuple(int(h[i:i+2], 16) for i in (0, 2, 4)) + (255,)
def mix(a, b, t): return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3)) + (255,)
SIZE = 24
# line: (korean, wikimon crest key, stroke colour, glass tint sampled from the official pendant (tag) art)
CRESTS = {
 "agumon":   ("용기", "courage",    "#d8661a", "#e89848"),
 "gabumon":  ("우정", "friendship", "#2f5fc0", "#88a8e0"),
 "biyomon":  ("사랑", "love",       "#c83848", "#d86068"),
 "tentomon": ("지식", "knowledge",  "#7046a8", "#a890c8"),
 "palmon":   ("순수", "purity",     "#3a9a2a", "#b0e098"),
 "gomamon":  ("성실", "sincerity",  "#5e6670", "#b8bec6"),   # no official pendant (tag) art on Wikimon; neutral grey
 "patamon":  ("희망", "hope",       "#c09010", "#f0e090"),
 "tailmon":  ("빛",   "light",      "#c8448c", "#e090c0"),
}
def native_mask(path):
    g = Image.open(path).convert("RGB"); w, h = g.size; p = g.load()
    best = None
    for ox in (0, 1):
        for oy in (0, 1):   # find the 2x2 grid alignment (Love is offset by one pixel)
            bad = sum(1 for y in range(oy, h - 1, 2) for x in range(ox, w - 1, 2)
                      if len({p[x, y], p[x + 1, y], p[x, y + 1], p[x + 1, y + 1]}) > 1)
            if best is None or bad < best[0]: best = (bad, ox, oy)
    _, ox, oy = best
    m = {((x - ox) // 2, (y - oy) // 2) for y in range(oy, h - 1, 2) for x in range(ox, w - 1, 2) if sum(p[x, y]) < 200}
    xs = [a for a, _ in m]; ys = [b for _, b in m]
    x0, y0 = min(xs), min(ys); cw, ch = max(xs) - x0 + 1, max(ys) - y0 + 1
    dx, dy = (SIZE - cw) // 2, (SIZE - ch) // 2           # centre in a 24x24 box
    return {(x - x0 + dx, y - y0 + dy) for x, y in m}, best[0]

from PIL import ImageDraw
# Pendant = the anime "Tag": gold elongated hexagon, ring hole on top, glass window, engraved lower panel with grooves.
TW, TH = 40, 68
OL, G_D2, G_D, G, G_L, G_H = map(hexc, ("#3a2808", "#7a5a12", "#a8801e", "#d6ae38", "#f0d464", "#fff3b0"))
RING, RING_D = hexc("#c8ccd2"), hexc("#7c838e")
WX0, WY0, WX1, WY1 = 4, 28, 35, 53          # glass window (32x26)
def pendant(glass, mask=None, stroke=None):
    m = Image.new("L", (TW, TH), 0); d = ImageDraw.Draw(m)
    d.polygon([(15, 6), (24, 6), (38, 26), (38, 58), (33, 66), (6, 66), (1, 58), (1, 26)], fill=255)
    pm = m.load(); body = {(x, y) for x in range(TW) for y in range(TH) if pm[x, y] > 127}
    hole = {(x, y) for x in range(TW) for y in range(TH) if (x - 19.5) ** 2 + (y - 10.5) ** 2 <= 4.2}
    body -= hole
    im = Image.new("RGBA", (TW, TH), (0, 0, 0, 0)); px = im.load()
    N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))
    for (x, y) in body:
        if any((x + a, y + b) not in body for a, b in N4): px[x, y] = OL; continue
        c = G
        if x <= 3 or (y < 26 and x + 0.7 * y < 24): c = G_L               # lit left bevel / left shoulder
        if x >= 36 or (y < 26 and x - 0.7 * y > 16): c = G_D              # shaded right bevel / right shoulder
        if y >= 64: c = G_D
        px[x, y] = c
    # inner bevel line around the top panel (the recessed pentagon above the window)
    for y in range(9, 26):
        hw = 1.5 + (y - 9) * 0.7                                     # inner edge parallel to the shoulders
        for x in (int(19.5 - hw - 2), int(19.5 + hw + 2)):
            if (x, y) in body and px[x, y] not in (OL,): px[x, y] = G_D if x > 19 else G_H
    # glass window with a dark recessed rim
    for x in range(WX0 - 1, WX1 + 2):
        px[x, WY0 - 1] = OL; px[x, WY1 + 1] = G_H
    for y in range(WY0 - 1, WY1 + 2):
        px[WX0 - 1, y] = OL; px[WX1 + 1, y] = G_H
    for y in range(WY0, WY1 + 1):
        for x in range(WX0, WX1 + 1):
            c = glass; t = (x - WX0) + (y - WY0)
            if 30 <= t <= 32 or 36 <= t <= 37: c = mix(glass, (255, 255, 255), 0.6)   # diagonal reflections
            px[x, y] = c
    if mask:
        ox, oy = WX0 + 4, WY0 + 1
        for (x, y) in mask: px[ox + x, oy + y] = stroke
    # engraved circuit pattern under the window
    for (x, y) in [(6, 56), (7, 56), (8, 56), (8, 57), (8, 58), (9, 58), (10, 58), (13, 56), (13, 57), (14, 57), (15, 57), (16, 57), (16, 56),
                   (19, 56), (20, 56), (21, 56), (21, 57), (21, 58), (24, 58), (25, 58), (25, 57), (25, 56), (26, 56), (27, 56),
                   (30, 56), (30, 57), (31, 57), (32, 57), (33, 57)]:
        px[x, y] = G_D2
    for y in (60, 62):                                               # horizontal grooves
        for x in range(2, 38):
            if (x, y) in body and px[x, y] != OL: px[x, y] = G_D2
        for x in range(2, 38):
            if (x, y + 1) in body and px[x, y + 1] != OL: px[x, y + 1] = G_H if x < 36 else px[x, y + 1]
    # metal ring through the hole
    ring = {(x, y) for x in range(15, 25) for y in range(0, 14) if 2.2 <= ((x - 19.5) ** 2 / 1.0 + (y - 6) ** 2 / 2.2) ** 0.5 <= 3.4}
    for (x, y) in ring:
        if (x, y) in body and y >= 8 and not (x, y) in hole: continue    # ring goes behind the plate below the hole
        px[x, y] = RING if x < 20 else RING_D
    return im

meta = {}
for line, (ko, key, stroke, glass) in CRESTS.items():
    mask, bad = native_mask(os.path.join(REF, f"Crest_{key}_vpet_Digivice.gif"))
    s = hexc(stroke)
    ic = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0)); p = ic.load()
    for xy in mask: p[xy] = s
    ic.save(os.path.join(OUT, f"{line}.png")); ic.resize((SIZE * 8, SIZE * 8), Image.NEAREST).save(os.path.join(OUT, f"{line}@8x.png"))
    pendant(mix(hexc(glass), (255, 255, 255), 0.4), mask, mix(s, (0, 0, 0), 0.3)).save(os.path.join(ITEMS, f"pendant_{line}.png"))
    pendant(hexc("#c9dbe6"), mask, hexc("#8c97a3")).save(os.path.join(ITEMS, f"pendant_{line}_off.png"))  # crest set, not lit yet
    meta[line] = dict(ko=ko, key=key, color=stroke, glass=glass)
    print(line, key, "residual", bad)
pendant(hexc("#a9d6f0")).save(os.path.join(ITEMS, "pendant.png"))
json.dump(meta, open(os.path.join(OUT, "crests.json"), "w"), ensure_ascii=False, indent=1)
for f in os.listdir(OUT):
    if f.endswith("_8.png"): os.remove(os.path.join(OUT, f))
