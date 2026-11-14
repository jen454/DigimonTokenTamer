"""Hand-drawn VB-style sprites (facing right) for species without a colour V-Pet dot.
Shapes are built as masks; the outline is derived automatically. usage: handdrawn.py OUT_DIR"""
import os, sys
from PIL import Image, ImageDraw
OUT = sys.argv[1]; os.makedirs(OUT, exist_ok=True)
def hexc(h): h = h.lstrip('#'); return tuple(int(h[i:i+2], 16) for i in (0, 2, 4)) + (255,)
N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))

def canvas(w, h): return Image.new("RGBA", (w, h), (0, 0, 0, 0))
def mask_of(w, h, draw_fn):
    m = Image.new("L", (w, h), 0); draw_fn(ImageDraw.Draw(m)); p = m.load()
    return {(x, y) for x in range(w) for y in range(h) if p[x, y] > 127}
def outline(mask): return {p for p in mask if any((p[0] + dx, p[1] + dy) not in mask for dx, dy in N4)}

def poyomon():
    W, H = 16, 18; K, Wt, A, B, C = map(hexc, ("#000000", "#ffffff", "#eaf6ff", "#c4def6", "#93b6e4"))
    M, m = hexc("#f06a4a"), hexc("#a8321e")
    # symmetric silhouette: half-width per row around the centre (cols 8-hw .. 7+hw), then a 4-wave hem
    HW = [3, 5, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8]
    mask = {(x, y) for y, hw in enumerate(HW) for x in range(8 - hw, 8 + hw)}
    mask |= {(x, 15) for x in range(16) if x % 4 != 3}           # hem waves
    mask |= {(x, 16) for x in range(16) if x % 4 in (0, 1) and x != 0} | {(0, 16), (1, 16)}
    ol = outline(mask)
    im = canvas(W, H); px = im.load()
    for (x, y) in mask:
        if (x, y) in ol: px[x, y] = K; continue
        c = A
        if x >= 13 or y >= 12: c = B                  # translucent blue shade right / bottom
        if y >= 14: c = C
        if (x == 2 and 4 <= y <= 9) or (x, y) in {(3, 3), (4, 2), (5, 2)}: c = Wt   # gloss
        px[x, y] = c
    for ex in (7, 12):                                # round eyes 2x3, shifted right = facing right
        for dy in range(3):
            for dx in range(2): px[ex + dx, 5 + dy] = K
        px[ex, 5] = Wt
    for x in range(9, 12): px[x, 9] = M               # small orange smile centred between the eyes
    px[10, 10] = m
    return im

def nyaromon():
    W, H = 26, 20
    K, A, B, Cd, Wt = map(hexc, ("#2a1800", "#ffe24a", "#f0bf22", "#c99512", "#fff8b8"))
    E, e, Hl, P, Pd = map(hexc, ("#c8401a", "#5a1400", "#ffffff", "#9a7ad8", "#5e3fa0"))
    def head(d):
        d.ellipse((7, 4, 24, 17), fill=255)
        d.polygon([(8, 9), (9, 0), (14, 5)], fill=255)    # back ear (tilted)
        d.polygon([(17, 5), (21, 0), (23, 9)], fill=255)  # front ear
    hm = mask_of(W, H, head)
    # tail: thin 2px curve from the back of the head, sweeping left then curling up
    tail_pts = [(8, 14), (6, 16), (4, 17), (2, 16), (1, 14), (1, 12), (2, 10)]
    tm = mask_of(W, H, lambda d: d.line(tail_pts, fill=255, width=3, joint="curve")) - hm
    mask = hm | tm; ol = outline(mask)
    im = canvas(W, H); px = im.load()
    order = sorted(tm, key=lambda p: (p[1] < 13, -p[0] if p[1] >= 13 else p[1]))  # walk along the tail
    for (x, y) in mask:
        if (x, y) in ol: px[x, y] = K; continue
        if (x, y) in tm:
            px[x, y] = P if y <= 11 or (x + y) % 4 < 2 else A; continue  # diagonal purple stripes, purple tip
        c = A
        if x >= 22 or y >= 15: c = B
        if y >= 16: c = Cd
        if (x, y) in {(10, 6), (9, 7), (9, 8), (11, 5)}: c = Wt
        px[x, y] = c
    for ex, ey in ((10, 3), (20, 3)):                  # inner ears (lighter)
        for dy in range(3):
            if (ex, ey + dy) in mask and (ex, ey + dy) not in ol: px[ex, ey + dy] = Wt
    EYE = ["KEE", "HeE", "EeE", "KEK"]                 # big round red-brown eyes with a highlight
    pal = dict(K=K, E=E, e=e, H=Hl)
    for ex in (15, 20):
        for dy, row in enumerate(EYE):
            for dx, ch in enumerate(row): px[ex + dx, 8 + dy] = pal[ch]
    for (x, y) in ((17, 13), (18, 14), (19, 13), (20, 14), (21, 13)): px[x, y] = K   # cat mouth "w"
    return im

for name, fn in (("poyomon", poyomon), ("nyaromon", nyaromon)):
    im = fn(); im = im.crop(im.getbbox())
    im.save(os.path.join(OUT, f"{name}.png")); im.resize((im.width * 8, im.height * 8), Image.NEAREST).save(os.path.join(OUT, f"{name}@8x.png"))
    print(name, im.size)
