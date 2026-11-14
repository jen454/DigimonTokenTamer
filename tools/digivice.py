"""Digivice icon, drawn after the Digimon Adventure (1999) digivice front view. usage: digivice.py OUT_ITEMS_DIR"""
import math, os, sys
from PIL import Image, ImageDraw
OUT = sys.argv[1]; os.makedirs(OUT, exist_ok=True)
def hexc(h): h = h.lstrip('#'); return tuple(int(h[i:i+2], 16) for i in (0, 2, 4)) + (255,)
W, H = 40, 38
OL, B_L, B, B_S, B_D = map(hexc, ("#27434f", "#ffffff", "#e3f4f8", "#bfdde7", "#93bfcd"))
RING, RING_D, RING_E = map(hexc, ("#d5e9f0", "#7fa3b1", "#4e6f7c"))
LCD, LCD_D, LCD_F = map(hexc, ("#a9b99a", "#8a9c7c", "#2d3a2a"))
BTN, BTN_L, BTN_D = map(hexc, ("#33409a", "#7383dc", "#1c2560"))
STRAP, STRAP_L = hexc("#1e1e22"), hexc("#55555c")
CX, CY = 19.5, 20.5
m = Image.new("L", (W, H), 0); d = ImageDraw.Draw(m)
d.polygon([(8, 4), (31, 4), (37, 10), (37, 31), (31, 37), (8, 37), (2, 31), (2, 10)], fill=255)    # chamfered body
d.ellipse((0, 15, 8, 26), fill=255)                                                                # left button housing
d.ellipse((32, 9, 39, 18), fill=255); d.ellipse((32, 23, 39, 32), fill=255)                         # right button housings
p = m.load(); body = {(x, y) for x in range(W) for y in range(H) if p[x, y] > 127}
im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); px = im.load()
N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))
for (x, y) in body:
    if any((x + a, y + b) not in body for a, b in N4): px[x, y] = OL; continue
    c = B
    if x + y < 18: c = B_L
    if x - y > 26 or y >= 34: c = B_S
    if x + y > 66: c = B_D
    px[x, y] = c
for y in (35,):                                         # bottom step lines (stacked plates)
    for x in range(9, 31): px[x, y] = B_D
for x in (13, 26):
    for y in (34, 35, 36): px[x, y] = B_D
# dark circuit board around the screen, inside a light ring
DARK, CIRC = hexc("#3b4448"), hexc("#b9c4c9")
for y in range(H):
    for x in range(W):
        r = math.hypot(x + 0.5 - CX - 0.5, y + 0.5 - CY)
        if r < 11.0:
            px[x, y] = DARK
            ang = math.degrees(math.atan2(y + .5 - CY, x + .5 - CX - .5)) % 360
            if 9.2 <= r < 10.2 and int(ang // 9) % 2 == 0: px[x, y] = CIRC          # circuit ticks
            if 7.6 <= r < 8.4 and int(ang // 20) % 3 == 1: px[x, y] = CIRC
        elif r < 13.2: px[x, y] = RING if r < 12.4 else RING_E
        elif r < 13.8 and (x, y) in body and px[x, y] != OL: px[x, y] = RING_D
# square LCD
for y in range(14, 28):
    for x in range(14, 27):
        edge = y in (14, 27) or x in (14, 26)
        px[x, y] = LCD_F if edge else (LCD_D if (x == 15 or y == 15) else LCD)
# buttons
def button(cx, cy, rx, ry):
    for y in range(H):
        for x in range(W):
            v = ((x + .5 - cx) / rx) ** 2 + ((y + .5 - cy) / ry) ** 2
            if v <= 1: px[x, y] = BTN_D if v > 0.62 else (BTN_L if (x + .5 - cx) + (y + .5 - cy) < -1.2 else BTN)
button(4.5, 20.5, 3.9, 4.6); button(35.0, 13.5, 3.6, 2.9); button(35.0, 27.5, 3.6, 2.9)
# strap loop on the top-left
for (x, y) in [(5, 0), (6, 0), (4, 1), (5, 1), (6, 1), (7, 1), (5, 2), (6, 2), (7, 2), (6, 3), (7, 3), (8, 3)]:
    px[x, y] = STRAP_L if (x, y) in {(5, 0), (4, 1)} else STRAP
im.save(os.path.join(OUT, "digivice.png")); im.resize((W * 8, H * 8), Image.NEAREST).save(os.path.join(OUT, "digivice@8x.png"))
print("digivice", im.size)
