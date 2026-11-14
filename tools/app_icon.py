"""App icon: drafts and the final icon set.

usage: app_icon.py OUT_DIR                      drafts: OUT_DIR/<variant>/icon_<size>.png,
                                                contact sheet and comparison page
       app_icon.py --iconset VARIANT ICONSET    one variant as a macOS .iconset (for iconutil)

Chosen (2026-11-14): "d1p-digivice" — the Digivice-shaped handheld, drawn after this project's
digivice sprite (tools/digivice.py) with the app's digitama on its screen. It is fan art of the
Digivice design and is the one Digimon-derived image the repository carries (see NOTICE.md).

Every shape here is drawn for this project (rounded body, square screen, three buttons, a plain
egg or a blob on the LCD), so the chosen icon can be committed and bundled — unlike the
fan-use sprites. Two native grids keep the pixels crisp: 32x32 for large sizes, 16x16 for small.
"""
import os, sys
from PIL import Image, ImageDraw

ICONSET = None
if len(sys.argv) >= 4 and sys.argv[1] == "--iconset":
    ICONSET = (sys.argv[2], sys.argv[3])
    OUT = sys.argv[3]
else:
    OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)


def hexc(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))

# ---- variants -------------------------------------------------------------------------------
DIGI = dict(body="#e3f4f8", light="#ffffff", shade="#bfdde7", outline="#27434f",
            ring="#3b4448", tick="#b9c4c9", lcd="#a9b99a", lcd_d="#8a9c7c", ink="#2d3a2a",
            btn="#33409a", btn_hl="#7383dc", strap="#1e1e22")
VARIANTS = {
    "a1-white": dict(
        title="A1 화이트 클래식 (기준)", note="이전 초안 · 흰 몸체 · 주황 베젤 · 아래 버튼",
        shape="rounded", body="#f4f1e8", light="#ffffff", shade="#d6d0c0", outline="#2b3447",
        bezel="#ff8a00", bezel_ol="#b45c00", lcd="#a9c4a0", lcd_d="#90ad88", ink="#2d3a2a",
        screen="egg", btn="#2f4c8f", btn_hl="#7393dc", strap="#2b3447"),
    "d1-octagon-side": dict(
        title="D1 팔각 · 옆 버튼", note="디지바이스에 가장 가까움 · 깎은 팔각 몸체 · 어두운 링 액정 · 왼쪽 1개 오른쪽 2개 버튼",
        shape="octagon", layout="side", screen="egg", screen_style="ring", **DIGI),
    "d1p-digivice": dict(
        title="D1+ 디지바이스형", note="D1을 디지바이스 비율에 맞춤 · 연한 링 + 회로판 · 큰 사각 액정 속 디지타마 · 왼쪽 큰 버튼, 오른쪽 타원 버튼 2개",
        shape="digivice", **DIGI),
    "d2-rounded-digi": dict(
        title="D2 A1 모양 + 디지바이스 색", note="A1 형태 유지 · 하늘빛 흰 몸체 · 어두운 테 액정 · 남색 버튼 · 검은 고리",
        shape="rounded", screen="egg", screen_style="frame", bezel="#3b4448", bezel_ol="#b9c4c9", **DIGI),
    "d3-octagon-below": dict(
        title="D3 팔각 · 아래 버튼", note="팔각 몸체와 링 액정 · 버튼은 A1처럼 아래 · 원작과 거리 두기",
        shape="octagon", layout="below", screen="egg", screen_style="ring", **DIGI),
}

# Screen art: '.' = LCD, 'o' = ink, 'e' = cream, 's' = orange spot, 'q' = eye, 'a' = "!", 'l' = data line
SCREENS = {
    32: {
        "egg": ["............", ".....oo.....", "....oeeo....", "...oesseo...", "...oeeeeo...",
                "...oseeso...", "....oeeo....", ".....oo.....", "............"],
        "partner": ["..........a.", "...oooo...a.", "..oeeeeo..a.", ".oeqeeqeo.a.", ".oeeeeeeo...",
                    ".oeeeeeeo.a.", "..oo..oo....", "............", "............"],
        "data": ["l.l.l.l.l.l.", ".....oo.....", "....oeeo....", "...oesseo..l", "l..oeeeeo...",
                 "...oseeso..l", "....oeeo....", ".....oo.....", "l.l.l.l.l.l."],
    },
    16: {
        "egg": ["..oo..", ".oeso.", ".oseo.", "..oo..", "......"],
        "partner": [".oo..a", "oqqo.a", "oeeo..", "o..o.a", "......"],
        "data": ["l.oo.l", ".oeso.", ".oseo.", "l.oo.l", "......"],
    },
    # 10x9 screen inside the ring (D variants)
    "ring32": {"egg": ["..........", "....oo....", "...oeeo...", "..oesseo..", "..oeeeeo..",
                       "..oseeso..", "...oeeo...", "....oo....", ".........."]},
}

# Octagon (digivice-leaning) geometry; "side" puts the buttons in housings on the sides.
OCT = {
    32: dict(poly=[(9, 3), (22, 3), (28, 9), (28, 22), (22, 28), (9, 28), (3, 22), (3, 9)],
             housings=[(0, 12, 5, 19), (26, 7, 31, 13), (26, 18, 31, 24)], strap=(0, 0, 6, 6),
             side_buttons=[(1, 14, 3, 17), (27, 8, 29, 11), (27, 19, 29, 22)],
             ring=(7, 7, 24, 24), ring_center=(15.5, 15.5), lcd=(11, 11, 20, 19),
             ring_below=(7, 4, 24, 21), ring_below_center=(15.5, 12.5), lcd_below=(11, 8, 20, 16),
             buttons=[(9, 23, 11, 25), (14, 24, 16, 26), (19, 23, 21, 25)]),
    16: dict(poly=[(5, 1), (10, 1), (14, 5), (14, 10), (10, 14), (5, 14), (1, 10), (1, 5)],
             housings=[], strap=None, side_buttons=[(1, 7, 1, 8), (14, 5, 14, 6), (14, 9, 14, 10)],
             ring=(3, 3, 12, 12), ring_center=(7.5, 7.5), lcd=(5, 5, 10, 9),
             ring_below=(3, 2, 12, 10), ring_below_center=(7.5, 6), lcd_below=(5, 4, 10, 8),
             buttons=[(4, 11, 5, 12), (7, 12, 8, 13), (10, 11, 11, 12)]),
}

# Geometry per grid (pixel coordinates, inclusive boxes for Pillow)
GEOM = {
    32: dict(body=(5, 4, 26, 29), radius=7, egg=(5, 1, 26, 30), strap=(2, 1, 8, 7),
             bezel=(8, 8, 23, 20), bezel_r=3, lcd=(10, 10, 21, 18),
             buttons=[(9, 23, 11, 25), (14, 24, 16, 26), (19, 23, 21, 25)], band=(5, 13, 26, 15)),
    16: dict(body=(2, 1, 13, 14), radius=3, egg=(2, 0, 13, 15), strap=None,
             bezel=(4, 3, 11, 9), bezel_r=1, lcd=(5, 4, 10, 8),
             buttons=[(4, 11, 5, 12), (7, 12, 8, 13), (10, 11, 11, 12)], band=(2, 6, 13, 6)),
}


def device(n, v):
    g, P = GEOM[n], {k: hexc(c) for k, c in v.items() if isinstance(c, str) and c.startswith('#')}
    im = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    px = im.load()

    octagon = v["shape"] == "octagon"
    o = OCT[n]
    # strap loop (behind the body)
    strap_box = (o["strap"] if octagon else g["strap"])
    if v.get("strap") and strap_box:
        ImageDraw.Draw(im).ellipse(strap_box, outline=P["strap"], width=1)

    # body: mask → outline on the edge, light top-left, shade bottom-right
    m = Image.new("L", (n, n), 0)
    d = ImageDraw.Draw(m)
    if v["shape"] == "egg":
        d.ellipse(g["egg"], fill=255)
    elif octagon:
        d.polygon(o["poly"], fill=255)
        if v.get("layout") == "side":
            for box in o["housings"]:
                d.ellipse(box, fill=255)
    else:
        d.rounded_rectangle(g["body"], radius=g["radius"], fill=255)
    mp = m.load()
    body = {(x, y) for x in range(n) for y in range(n) if mp[x, y] > 127}
    for (x, y) in body:
        if any((x + a, y + b) not in body for a, b in N4):
            px[x, y] = P["outline"]
            continue
        c = P["body"]
        if x + y < n * 0.55:
            c = P["light"]
        if x + y > n * 1.35:
            c = P["shade"]
        px[x, y] = c

    # orange band across an egg-shaped body
    if v.get("band"):
        x0, y0, x1, y1 = g["band"]
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if (x, y) in body and px[x, y] != P["outline"]:
                    px[x, y] = P["bezel"]

    # screen: orange/dark bezel (A1, D2) or a dark ring with light circuit ticks (D1, D3)
    style = v.get("screen_style", "bezel")
    below = v.get("layout") == "below"
    if style == "ring":
        import math
        rx0, ry0, rx1, ry1 = o["ring_below"] if below else o["ring"]
        cx, cy = o["ring_below_center"] if below else o["ring_center"]
        radius = (rx1 - rx0 + 1) / 2
        for y in range(ry0, ry1 + 1):
            for x in range(rx0, rx1 + 1):
                r = math.hypot(x + 0.5 - cx - 0.5, y + 0.5 - cy - 0.5)
                if r <= radius - 0.2:
                    px[x, y] = P["ring"]
                    ang = math.degrees(math.atan2(y - cy, x - cx)) % 360
                    if n == 32 and radius - 1.8 <= r < radius - 0.9 and int(ang // 12) % 2 == 0:
                        px[x, y] = P["tick"]
        lcd_box = o["lcd_below"] if below else o["lcd"]
    else:
        ImageDraw.Draw(im).rounded_rectangle(g["bezel"], radius=g["bezel_r"], fill=P["bezel"], outline=P["bezel_ol"])
        lcd_box = g["lcd"]
    x0, y0, x1, y1 = lcd_box
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px[x, y] = P["lcd_d"] if (x == x0 or y == y0) else P["lcd"]   # inner shadow top/left
    art = SCREENS["ring32"][v["screen"]] if (style == "ring" and n == 32) else SCREENS[n][v["screen"]]
    colors = {"o": P["ink"], "e": hexc("#fff7e0"), "s": hexc("#ff8a00"), "q": P["ink"],
              "a": hexc("#e03a3a") if v["screen"] == "partner" and n == 32 else hexc("#ff6a00"),
              "l": P["lcd_d"]}
    for j, row in enumerate(art):
        for i, ch in enumerate(row):
            if ch in colors and 0 <= x0 + i <= x1 and 0 <= y0 + j <= y1:
                px[x0 + i, y0 + j] = colors[ch]

    # three buttons: below the screen, or in the side housings (D1)
    button_boxes = (o["side_buttons"] if v.get("layout") == "side" else o["buttons"]) if octagon else g["buttons"]
    for (bx0, by0, bx1, by1) in button_boxes:
        for y in range(by0, by1 + 1):
            for x in range(bx0, bx1 + 1):
                corner = (x in (bx0, bx1)) and (y in (by0, by1)) and n == 32 and bx1 - bx0 >= 2 and by1 - by0 >= 2
                if not corner:
                    px[x, y] = P["btn"]
        if n == 32:
            px[min(bx0 + 1, bx1), by0] = P["btn_hl"]
        elif bx1 > bx0 or by1 > by0:
            px[bx0, by0] = P["btn_hl"]
    return im


def digivice_small():
    """16x16 hand-placed version of the digivice icon (scaling the 40-grid drawing smeared it)."""
    C = {"O": "#27434f", "W": "#ffffff", "b": "#e3f4f8", "d": "#bfdde7", "r": "#d5e9f0", "R": "#7fa3b1",
         "k": "#3b4448", "F": "#2d3a2a", "L": "#a9b99a", "e": "#fff7e0", "s": "#ff8a00",
         "n": "#33409a", "h": "#7383dc", "x": "#1e1e22"}
    g = [["." for _ in range(16)] for _ in range(16)]
    m = Image.new("L", (16, 16), 0)
    ImageDraw.Draw(m).polygon([(4, 2), (11, 2), (14, 5), (14, 11), (11, 14), (4, 14), (1, 11), (1, 5)], fill=255)
    mp = m.load()
    body = {(x, y) for x in range(16) for y in range(16) if mp[x, y] > 127}
    for (x, y) in body:
        edge = any((x + a, y + b) not in body for a, b in N4)
        g[y][x] = "O" if edge else ("W" if x + y < 9 else ("d" if x + y > 21 else "b"))
    for x in range(3, 13):                      # light ring (square, corners cut)
        for y in range(4, 13):
            if (x in (3, 12) or y in (4, 12)) and not (x in (3, 12) and y in (4, 12)):
                g[y][x] = "R" if (x == 12 or y == 12) else "r"
    for x in range(4, 12):                      # dark circuit board
        for y in range(5, 12):
            if x in (4, 11) or y in (5, 11):
                g[y][x] = "k"
    for x in range(5, 11):                      # LCD with frame
        for y in range(6, 11):
            g[y][x] = "F" if (x in (5, 10) or y in (6, 10)) else "L"
    for (x, y, c) in [(7, 7, "e"), (8, 7, "e"), (7, 8, "s"), (8, 8, "e"), (7, 9, "e"), (8, 9, "s")]:
        g[y][x] = c                             # the digitama
    for (x, y) in [(0, 7), (0, 8), (0, 9), (1, 7), (1, 8), (1, 9)]:
        g[y][x] = "h" if (x, y) == (0, 7) else "n"   # left button
    for (x, y) in [(14, 4), (15, 4), (14, 5), (15, 5), (14, 11), (15, 11), (14, 12), (15, 12)]:
        g[y][x] = "h" if (x, y) in {(14, 4), (14, 11)} else "n"   # right buttons
    for (x, y) in [(2, 0), (3, 1), (2, 1)]:
        g[y][x] = "x"                           # strap
    im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    px = im.load()
    for y in range(16):
        for x in range(16):
            if g[y][x] != ".":
                px[x, y] = hexc(C[g[y][x]])
    return im


def digivice_device(n):
    """Digivice-structured handheld on an n x n grid (40 = full detail, 16 = small sizes).

    Same construction as tools/digivice.py (chamfered body, light ring, dark circuit board,
    square LCD, one round button left and two oval buttons right, strap top-left), scaled from
    its 40x38 drawing, with this app's digitama on the screen.
    """
    import math
    if n < 32:
        return digivice_small()
    f = n / 40.0
    oy = round(1 * f)                     # centre the 38-tall drawing vertically
    OL, B_L, B, B_S, B_D = map(hexc, ("#27434f", "#ffffff", "#e3f4f8", "#bfdde7", "#93bfcd"))
    RING, RING_D, RING_E = map(hexc, ("#d5e9f0", "#7fa3b1", "#4e6f7c"))
    LCD, LCD_D, LCD_F = map(hexc, ("#a9b99a", "#8a9c7c", "#2d3a2a"))
    BTN, BTN_L, BTN_D = map(hexc, ("#33409a", "#7383dc", "#1c2560"))
    STRAP, STRAP_L = hexc("#1e1e22"), hexc("#55555c")
    DARK, CIRC = hexc("#3b4448"), hexc("#b9c4c9")
    def P(x, y): return (x * f, y * f + oy)
    m = Image.new("L", (n, n), 0)
    d = ImageDraw.Draw(m)
    d.polygon([P(8, 4), P(31, 4), P(37, 10), P(37, 31), P(31, 37), P(8, 37), P(2, 31), P(2, 10)], fill=255)
    for box in ((0, 15, 8, 26), (32, 9, 39, 18), (32, 23, 39, 32)):
        (x0, y0), (x1, y1) = P(box[0], box[1]), P(box[2], box[3])
        d.ellipse((round(x0), round(y0), round(x1), round(y1)), fill=255)
    mp = m.load()
    body = {(x, y) for x in range(n) for y in range(n) if mp[x, y] > 127}
    im = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    px = im.load()
    for (x, y) in body:
        if any((x + a, y + b) not in body for a, b in N4):
            px[x, y] = OL
            continue
        c = B
        if x + y < 18 * f: c = B_L
        if x - y > 26 * f or y >= 34 * f + oy: c = B_S
        if x + y > 66 * f: c = B_D
        px[x, y] = c
    cx, cy = 19.5 * f, 20.5 * f + oy
    for y in range(n):
        for x in range(n):
            r = math.hypot(x + 0.5 - cx - 0.5 * f, y + 0.5 - cy) / f      # radius in 40-grid units
            if r < 11.0:
                px[x, y] = DARK
                ang = math.degrees(math.atan2(y + .5 - cy, x + .5 - cx - .5 * f)) % 360
                if n >= 32 and 9.2 <= r < 10.2 and int(ang // 9) % 2 == 0: px[x, y] = CIRC
                if n >= 32 and 7.6 <= r < 8.4 and int(ang // 20) % 3 == 1: px[x, y] = CIRC
            elif r < 13.2:
                px[x, y] = RING if r < 12.4 else RING_E
            elif r < 13.8 and (x, y) in body and px[x, y] != OL:
                px[x, y] = RING_D
    # square LCD (dark frame, inner shadow)
    lx0, ly0 = round(14 * f), round(14 * f) + oy
    lx1, ly1 = round(26 * f), round(27 * f) + oy
    for y in range(ly0, ly1 + 1):
        for x in range(lx0, lx1 + 1):
            edge = y in (ly0, ly1) or x in (lx0, lx1)
            px[x, y] = LCD_F if edge else (LCD_D if (x == lx0 + 1 or y == ly0 + 1) else LCD)
    # the digitama on the screen
    art = (["..ooo..", ".oeeeo.", "oeesseo", "oeeeeeo", "oseeeso", "oeeeeeo", ".oeeeo.", "..ooo.."]
           if n >= 32 else [".oo.", "oeso", "oseo", ".oo."])
    colors = {"o": LCD_F, "e": hexc("#fff7e0"), "s": hexc("#ff8a00")}
    aw, ah = len(art[0]), len(art)
    ax = (lx0 + lx1 + 1 - aw) // 2
    ay = (ly0 + ly1 + 1 - ah) // 2 + (1 if n >= 32 else 0)
    for j, row in enumerate(art):
        for i, ch in enumerate(row):
            if ch in colors:
                px[ax + i, ay + j] = colors[ch]
    # buttons
    def button(bcx, bcy, rx, ry):
        bcx, bcy, rx, ry = bcx * f, bcy * f + oy, max(rx * f, 0.9), max(ry * f, 0.9)
        for y in range(n):
            for x in range(n):
                v = ((x + .5 - bcx) / rx) ** 2 + ((y + .5 - bcy) / ry) ** 2
                if v <= 1:
                    px[x, y] = BTN_D if (v > 0.62 and n >= 32) else (BTN_L if (x + .5 - bcx) + (y + .5 - bcy) < -1.2 * f else BTN)
    button(4.5, 20.5, 3.9, 4.6); button(35.0, 13.5, 3.6, 2.9); button(35.0, 27.5, 3.6, 2.9)
    # strap loop, top-left
    for (x, y) in [(5, 0), (6, 0), (4, 1), (5, 1), (6, 1), (7, 1), (5, 2), (6, 2), (7, 2), (6, 3), (7, 3), (8, 3)]:
        X, Y = int(x * f), int(y * f) + oy
        if 0 <= X < n and 0 <= Y < n and (n >= 32 or (x, y) in {(5, 1), (6, 2)}):
            px[X, Y] = STRAP_L if (x, y) in {(5, 0), (4, 1)} else STRAP
    return im


# ---- icon composition -------------------------------------------------------------------------
SIZES = [16, 32, 64, 128, 256, 512, 1024]


def squircle(size):
    """macOS-style rounded square background, cream like the app, anti-aliased by supersampling."""
    ss = 4
    big = Image.new("RGBA", (size * ss, size * ss), (0, 0, 0, 0))
    inset = round(size * 0.098) * ss          # Big Sur grid: ~100 px margin at 1024
    box = (inset, inset, size * ss - inset - 1, size * ss - inset - 1)
    radius = round((size * ss - 2 * inset) * 0.225)
    grad = Image.new("RGBA", big.size)
    top, bottom = hexc("#fbfaf6"), hexc("#e8e2d3")
    gd = ImageDraw.Draw(grad)
    for y in range(big.size[1]):
        t = y / big.size[1]
        gd.line([(0, y), (big.size[0], y)], fill=tuple(round(top[i] * (1 - t) + bottom[i] * t) for i in range(3)) + (255,))
    mask = Image.new("L", big.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(box, radius=radius, fill=255)
    big.paste(grad, (0, 0), mask)
    ImageDraw.Draw(big).rounded_rectangle(box, radius=radius, outline=hexc("#cfc7b4"), width=max(1, ss * size // 256))
    return big.resize((size, size), Image.LANCZOS), (box[2] - box[0]) // ss


def icon(v, size):
    draw = (lambda n: digivice_device(n)) if v["shape"] == "digivice" else (lambda n: device(n, v))
    big = 40 if v["shape"] == "digivice" else 32
    if size <= 16:
        # Menu-list size: the 16x16 device alone reads better than a background squeezed around it.
        return draw(16).resize((size, size), Image.NEAREST)
    bg, inner = squircle(size)
    # Prefer the detailed grid whenever it fits at least once; 16x16 only below that.
    room = inner * 0.84
    n = big if room >= big else 16
    k = max(1, int(room // n))
    art = draw(n).resize((n * k, n * k), Image.NEAREST)
    bg.alpha_composite(art, ((size - n * k) // 2, (size - n * k) // 2 + max(0, size // 64)))
    return bg


if ICONSET:
    # iconutil names: icon_16x16.png, icon_16x16@2x.png (32 px) … icon_512x512@2x.png (1024 px)
    variant, folder = ICONSET
    v = VARIANTS[variant]
    for base in (16, 32, 128, 256, 512):
        icon(v, base).save(os.path.join(folder, f"icon_{base}x{base}.png"))
        icon(v, base * 2).save(os.path.join(folder, f"icon_{base}x{base}@2x.png"))
    print("iconset", folder)
    sys.exit(0)

for key, v in VARIANTS.items():
    d = os.path.join(OUT, key)
    os.makedirs(d, exist_ok=True)
    for s in SIZES:
        icon(v, s).save(os.path.join(d, f"icon_{s}.png"))

# ---- contact sheet (for a quick look) and comparison page ------------------------------------
from PIL import ImageFont


def font(sz):
    for path in ("/System/Library/Fonts/AppleSDGothicNeo.ttc", "/System/Library/Fonts/Supplemental/AppleGothic.ttf"):
        if os.path.exists(path):
            return ImageFont.truetype(path, sz)
    return ImageFont.load_default()


ROW_H, W = 300, 1500
sheet = Image.new("RGBA", (W, 60 + ROW_H * len(VARIANTS)), hexc("#f3f2ee"))
dr = ImageDraw.Draw(sheet)
dr.text((24, 18), "앱 아이콘 · 디지바이스 쪽으로 (D1, D1+, D2, D3) · 1024/256 · 128 · 64 · 32 · 16 · Dock · 알림", font=font(22), fill=hexc("#222222"))
for r, (key, v) in enumerate(VARIANTS.items()):
    y = 60 + r * ROW_H
    dr.text((24, y + 6), v["title"], font=font(22), fill=hexc("#222222"))
    dr.text((24, y + 36), v["note"], font=font(15), fill=hexc("#8a8a8a"))
    x = 24
    sheet.alpha_composite(icon(v, 1024).resize((220, 220), Image.LANCZOS), (x, y + 64)); x += 240
    for s in (128, 64, 32, 16):
        sheet.alpha_composite(icon(v, s), (x, y + 64 + (220 - s) // 2)); x += s + 28
    # 16 px zoomed to show the pixels
    sheet.alpha_composite(icon(v, 16).resize((64, 64), Image.NEAREST), (x, y + 142)); x += 92
    # Dock mock
    dock = Image.new("RGBA", (220, 110), hexc("#2c2c30"))
    dock.alpha_composite(icon(v, 64), (20, 23)); dock.alpha_composite(icon(v, 64), (100, 23))
    sheet.alpha_composite(dock, (x, y + 120)); x += 240
    # notification banner mock
    banner = Image.new("RGBA", (400, 86), hexc("#ffffff"))
    bd = ImageDraw.Draw(banner)
    bd.rounded_rectangle((0, 0, 399, 85), radius=18, outline=hexc("#dddddd"))
    banner.alpha_composite(icon(v, 64).resize((48, 48), Image.LANCZOS), (16, 19))
    bd.text((76, 18), "진화할 수 있어요!", font=font(17), fill=hexc("#222222"))
    bd.text((76, 46), "아구몬의 진화 조건이 모두 갖춰졌어요.", font=font(14), fill=hexc("#666666"))
    sheet.alpha_composite(banner, (x, y + 132))
sheet.save(os.path.join(OUT, "contact.png"))

cards = []
for key, v in VARIANTS.items():
    sizes = "".join(f'<figure><img src="{key}/icon_{s}.png" width="{min(s, 256)}" height="{min(s, 256)}" '
                    f'style="image-rendering:{"pixelated" if s <= 32 else "auto"}"><figcaption>{s}px</figcaption></figure>'
                    for s in (1024, 128, 64, 32, 16))
    cards.append(f'<section><h2>{v["title"]}</h2><p>{v["note"]}</p><div class="row">{sizes}'
                 f'<figure class="dock"><img src="{key}/icon_128.png" width="64"><img src="{key}/icon_128.png" width="64"><figcaption>Dock</figcaption></figure>'
                 f'<figure class="zoom"><img src="{key}/icon_16.png" width="64" style="image-rendering:pixelated"><figcaption>16px ×4</figcaption></figure>'
                 f'</div></section>')
html = f"""<!doctype html><html lang="ko"><meta charset="utf-8"><title>앱 아이콘 A안</title>
<style>body{{margin:0;padding:24px;background:#f3f2ee;font:14px -apple-system,"Apple SD Gothic Neo",sans-serif;color:#222}}
h1{{font-size:18px}}section{{background:#fff;border-radius:14px;padding:16px 20px;margin:0 0 16px;box-shadow:0 4px 16px rgba(0,0,0,.06)}}
h2{{font-size:16px;margin:0}}p{{color:#8a8a8a;margin:4px 0 12px}}.row{{display:flex;gap:22px;align-items:flex-end;flex-wrap:wrap}}
figure{{margin:0;display:flex;flex-direction:column;align-items:center;gap:6px}}figcaption{{font-size:11px;color:#8a8a8a}}
.dock{{flex-direction:row;background:#2c2c30;padding:12px 14px;border-radius:14px;gap:12px;position:relative}}.dock figcaption{{position:absolute;bottom:-18px;left:0}}</style>
<h1>앱 아이콘 — A1을 디지바이스 모양·색으로 (D1~D3)</h1>
<p>D1은 디지바이스에 가장 가깝고, D3는 거리를 둔 쪽입니다. 32×32 / 16×16 도트를 정수 배율로 확대했습니다.</p>
{''.join(cards)}</html>"""
open(os.path.join(OUT, "index.html"), "w").write(html)
print("written", OUT)
