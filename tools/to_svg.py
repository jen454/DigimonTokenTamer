"""Pixel sprites -> trimmed native-pixel PNG + SVG, all facing right.
usage: to_svg.py SPRITE_DIR OUT_DIR [HANDDRAWN_DIR]
HANDDRAWN_DIR holds native-size {name}.png that replace placeholder sprites (already drawn facing right)."""
import json, os, sys
from collections import defaultdict
from PIL import Image
SRC, OUT = sys.argv[1], sys.argv[2]
HAND = sys.argv[3] if len(sys.argv) > 3 else None
SCALE = 3
TOL = 8  # max per-channel difference to treat two colors as the same
manifest = json.load(open(os.path.join(SRC, "manifest.json")))
report = []
for m in manifest:
    hand = HAND and os.path.join(HAND, m["name"].lower() + ".png")
    if hand and os.path.exists(hand):
        im = Image.open(hand).convert("RGBA"); im = im.resize((im.width * SCALE, im.height * SCALE), Image.NEAREST)
        m.update(placeholder=False, source="hand-drawn (original, VB style)", wikimonFile=None, url=None)
    else:
        hand = None
        im = Image.open(os.path.join(SRC, m["file"])).convert("RGBA")
        im = im.transpose(Image.FLIP_LEFT_RIGHT)  # V-Pet dots face left; unify everything to face right
    w, h = im.size; px = im.load()
    # verify every SCALExSCALE block is uniform, then downsample
    bad = sum(1 for by in range(0, h - h % SCALE, SCALE) for bx in range(0, w - w % SCALE, SCALE)
              if len({px[bx+i, by+j] for i in range(SCALE) for j in range(SCALE)}) > 1)
    small = im.resize((w // SCALE, h // SCALE), Image.NEAREST)
    small = small.crop(small.getbbox())          # trim transparent margins
    # merge near-identical colors (lossy re-encode noise like #ffca00 vs #ffcb00)
    from collections import Counter
    counts = Counter(c for c in small.getdata() if c[3])
    reps, remap = [], {}
    for c, _ in counts.most_common():
        r = next((r for r in reps if max(abs(r[i]-c[i]) for i in range(3)) <= TOL), None)
        if r is None: reps.append(c); r = c
        remap[c] = r
    small.putdata([remap.get(c, c) if c[3] else (0,0,0,0) for c in small.getdata()])
    colors_before = len(counts)
    sw, sh = small.size; sp = small.load()
    base = os.path.splitext(m["file"])[0]
    os.makedirs(os.path.join(OUT, "png", os.path.dirname(base)), exist_ok=True)
    os.makedirs(os.path.join(OUT, "svg", os.path.dirname(base)), exist_ok=True)
    small.save(os.path.join(OUT, "png", base + ".png"))
    # SVG: one <path> per color, horizontal runs merged
    paths = defaultdict(list)
    for y in range(sh):
        x = 0
        while x < sw:
            c = sp[x, y]
            if c[3] == 0: x += 1; continue
            x0 = x
            while x < sw and sp[x, y] == c: x += 1
            paths[c].append(f"M{x0} {y}h{x-x0}v1h-{x-x0}z")
    body = "".join(f'<path fill="#{c[0]:02x}{c[1]:02x}{c[2]:02x}" d="{"".join(d)}"/>' for c, d in paths.items())
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {sw} {sh}" width="{sw}" height="{sh}" shape-rendering="crispEdges">{body}</svg>'
    open(os.path.join(OUT, "svg", base + ".svg"), "w").write(svg)
    m.update({"facing": "right", "native":[sw, sh], "png":f"png/{base}.png", "svg":f"svg/{base}.svg"})
    report.append((m["name"], f"{w}x{h}", f"{sw}x{sh}", f"{colors_before}->{len(paths)}", os.path.getsize(os.path.join(OUT,"svg",base+".svg")), bad))
json.dump(manifest, open(os.path.join(OUT, "manifest.json"), "w"), indent=2, ensure_ascii=False)
for r in report: print(f"{r[0]:18} {r[1]:>8} -> {r[2]:>6}  colors={r[3]:<3} svg={r[4]/1024:.1f}KB  nonuniform_blocks={r[5]}")
