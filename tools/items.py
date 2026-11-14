"""Original pixel item icons (meat; digivice.py and crests.py draw the digivice and pendant). usage: items.py OUT_DIR"""
import os, sys
from PIL import Image
OUT = sys.argv[1]; os.makedirs(OUT, exist_ok=True)
K = "#1a1a1a"
ITEMS = {
 "meat": dict(pal=dict(K=K, R="#d9653b", D="#a3401f", W="#f7a27e", B="#f7f1de", b="#cfc6a8"), rows=[
  "....KKKKK.......",
  "..KKRRRRRKK.....",
  ".KRRWWRRRRRK....",
  ".KRWRRRRRRRK....",
  "KRRRRRRRRRRDK...",
  "KRRRRRRRRRDDK...",
  "KRRRRRRRRDDK....",
  ".KRRRRRRDDKBK...",
  ".KDRRRRDDKBbK...",
  "..KDDDDDKBbK....",
  "...KKKKKBbK.KK..",
  "........KBbKBBK.",
  ".........KBBBbK.",
  "........KBBBbK..",
  ".........KBbK...",
  "..........KK....",
 ]),
}
for name, sp in ITEMS.items():
    rows = sp["rows"]; w = max(len(r) for r in rows); h = len(rows)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0)); px = im.load()
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch != ".":
                c = sp["pal"][ch].lstrip("#"); px[x, y] = tuple(int(c[i:i+2], 16) for i in (0, 2, 4)) + (255,)
    im.save(os.path.join(OUT, f"{name}.png")); im.resize((w * 8, h * 8), Image.NEAREST).save(os.path.join(OUT, f"{name}@8x.png"))
