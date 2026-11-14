"""Sample reference egg patterns into the 16x20 pixel egg. usage: digitama_ref.py REF_DIR OUT_DIR"""
import os, sys
from PIL import Image
REF, OUT = sys.argv[1], sys.argv[2]; os.makedirs(OUT, exist_ok=True)
W, H = 16, 20; CX, CY = 8.0, 11.0
ROWS = [4, 8, 10, 12, 12, 14, 14, 14, 16, 16, 16, 16, 16, 16, 16, 14, 14, 12, 10, 6]  # hand-tuned egg silhouette
def inside(x, y):
    if not 0 <= y < H: return False, 0, 0
    hw = ROWS[y] / 2; nx = (x + 0.5 - CX) / hw; ny = (y + 0.5 - 10.5) / 10.0
    return abs(x + 0.5 - CX) < hw, nx, ny
def shade(c, k): return tuple(max(0, min(255, int(v * k))) for v in c[:3]) + (255,)
def dist(a, b): return sum((a[i] - b[i]) ** 2 for i in range(3))
OUTLINE = (43, 43, 43, 255)
LINES = "agumon gabumon biyomon tentomon palmon gomamon patamon tailmon".split()
HEART = ["X.X", "XXX", ".X."]
HEART_L = [".X.X.", "XXXXX", ".XXX.", "..X.."]
STAR = ["..X..", ".XXX.", "XXXXX", ".XXX.", ".X.X."]
STAR_S = [".X.", "XXX", "X.X"]
def ring(r):
    n = int(r * 2 + 1); c = (n - 1) / 2
    return ["".join("X" if abs(((i - c) ** 2 + (j - c) ** 2) ** .5 - r) < .55 else "." for i in range(n)) for j in range(n)]
RING_S = [".XXX.", "X...X", "X...X", "X...X", ".XXX."]
RING_L = ["..XXX..", ".X...X.", "X.....X", "X.....X", "X.....X", ".X...X.", "..XXX.."]
DARKEN = dict(biyomon=0.85, tailmon=0.85)
STAMPS = {  # (stamp, cx, cy) centre positions read off the reference egg
 "biyomon": [(HEART, 5, 4), (HEART_L, 11, 5), (HEART_L, 8, 11), (HEART, 2, 12), (HEART, 14, 11), (HEART_L, 8, 17)],
 "tentomon": [(STAR_S, 4, 3), (STAR_S, 11, 2), (STAR, 8, 8), (STAR, 1, 11), (STAR_S, 13, 11), (STAR, 5, 16), (STAR_S, 13, 16)],
 "tailmon": [(RING_S, 11, 4), (RING_L, 2, 13), (RING_S, 14, 14), (RING_S, 1, 4)],
}
THR = dict(tailmon=0.30, gomamon=0.40)  # thin pattern lines need a lower vote threshold
for line in LINES:
    f = [x for x in os.listdir(REF) if x.startswith(line)][0]
    ref = Image.open(os.path.join(REF, f)).convert("RGBA"); rp = ref.load(); RW, RH = ref.size
    # egg bbox in ref + interior colours (skip transparent / dark outline)
    pts = [(x, y) for y in range(RH) for x in range(RW) if rp[x, y][3] > 200]
    x0 = min(p[0] for p in pts); x1 = max(p[0] for p in pts); y0 = min(p[1] for p in pts); y1 = max(p[1] for p in pts)
    cols = {}
    for x, y in pts:
        c = rp[x, y]
        if sum(c[:3]) < 200: continue
        k = tuple(v // 8 * 8 for v in c[:3]); cols[k] = cols.get(k, 0) + 1
    # 2 clusters: most common = base, most common far from base = pattern
    ranked = sorted(cols, key=lambda k: -cols[k]); base = ranked[0]
    pat = next(k for k in ranked if dist(k, base) > 3000)
    def avg(center):
        acc = [0, 0, 0, 0]
        for x, y in pts:
            c = rp[x, y]
            if sum(c[:3]) >= 200 and dist(c, center) < 1500: acc = [acc[0] + c[0], acc[1] + c[1], acc[2] + c[2], acc[3] + 1]
        return tuple(int(v / acc[3]) for v in acc[:3]) + (255,)
    base, pat = avg(base), avg(pat)
    pat = shade(pat, DARKEN.get(line, 1.0))
    # our egg interior spans x 1..14, y 1..18 approx; map each cell to ref bbox
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); px = im.load()
    mask = {(x, y): inside(x, y) for x in range(W) for y in range(H)}
    for (x, y), (ok, nx, ny) in mask.items():
        if not ok: continue
        if any(not mask.get((x + dx, y + dy), (False,))[0] for dx, dy in ((1,0),(-1,0),(0,1),(0,-1))): px[x, y] = OUTLINE; continue
        n = p = 0
        for sy in range(4):
            for sx in range(4):
                rx = x0 + (x + (sx + .5) / 4) / W * (x1 - x0); ry = y0 + (y + (sy + .5) / 4) / H * (y1 - y0)
                c = rp[int(rx), int(ry)]
                if c[3] < 200 or sum(c[:3]) < 200: continue
                n += 1; p += dist(c, pat) < dist(c, base)
        if line in STAMPS:
            hit = False
            for st, scx, scy in STAMPS[line]:
                sh, sw = len(st), len(st[0]); ox, oy = x - (scx - sw // 2), y - (scy - sh // 2)
                if 0 <= oy < sh and 0 <= ox < sw and st[oy][ox] == "X": hit = True
            c = pat if hit else base
        else:
            c = pat if n and p / n >= THR.get(line, 0.5) else base
        if (nx * 0.8 + ny * 0.6) > 0.62: c = shade(c, 0.86)
        px[x, y] = c
    for (x, y) in ((5, 4), (4, 5), (4, 6)):
        if px[x, y][:3] == base[:3]: px[x, y] = (255, 255, 255, 255)
    im.save(os.path.join(OUT, f"{line}.png"))
    im.resize((W * 8, H * 8), Image.NEAREST).save(os.path.join(OUT, f"{line}@8x.png"))
    rects = "".join(f'<rect x="{x}" y="{y}" width="1" height="1" fill="#{c[0]:02x}{c[1]:02x}{c[2]:02x}"/>'
                    for y in range(H) for x in range(W) for c in [px[x, y]] if c[3])
    open(os.path.join(OUT, f"{line}.svg"), "w").write(
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" shape-rendering="crispEdges">{rects}</svg>')
    print(line, "base", base[:3], "pat", pat[:3])
