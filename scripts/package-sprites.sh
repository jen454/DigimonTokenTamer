#!/usr/bin/env bash
# Assemble the sprite pack that the app downloads at runtime (SpritePack.defaultBaseURL).
#
# Output: build/sprite-pack/ — exactly the files listed by Resources/Tamer/catalog.json
# (48 forms, 8 digitama, 8 crests, pendants, digivice, meat) in the layout the app expects,
# plus README/NOTICE. Its contents go to the separate sprites repository, never to this one
# (docs/DESIGN.md §5.2). Run ./tools/build_assets.sh first.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/assets/build"
OUT="${1:-$ROOT/build/sprite-pack}"
[ -f "$SRC/manifest.json" ] || { echo "assets/build is missing — run ./tools/build_assets.sh first." >&2; exit 1; }
rm -rf "$OUT"
mkdir -p "$OUT"
python3 -I - "$ROOT/Sources/DigimonTokenTamer/Resources/Tamer/catalog.json" "$SRC" "$OUT" <<'PY'
import json, shutil, sys, pathlib
catalog, src, out = json.load(open(sys.argv[1])), pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])
paths = ["items/digivice.png", "items/meat.png", "items/pendant.png"]
for line in catalog["lines"]:
    key = line["key"]
    paths += [s["sprite"] for s in line["stages"]]
    paths += [f"digitama/{key}.png", f"crests/{key}.png", f"items/pendant_{key}.png", f"items/pendant_{key}_off.png"]
missing = [p for p in paths if not (src / p).is_file()]
if missing:
    sys.exit("missing in assets/build: " + ", ".join(missing))
for p in paths:
    (out / p).parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src / p, out / p)
print(f"{len(paths)} sprites")
PY
cat > "$OUT/README.md" <<'MD'
# DigimonTokenTamer sprites

Runtime sprite pack for [DigimonTokenTamer](https://github.com/jen454/DigimonTokenTamer).
The app downloads these files on first launch and caches them locally; they are not part of the
app or its source repository.

비공식·비상업 팬 프로젝트용 도트 이미지입니다. Bandai/Toei와 관련이 없습니다.

| Folder | Content | Source |
|---|---|---|
| `png/` | 48 partner forms, native pixel size, facing right | Wikimon Vital Bracelet dots (mirrored); Poyomon and Nyaromon drawn for this project |
| `digitama/` | 8 digitama, 16×20 | Pixel redraws of the original digitama patterns |
| `crests/` | 8 crests, 24×24 | Wikimon Digivice V-Pet crest dots, coloured after the official tag art |
| `items/` | pendants, digivice, meat | Drawn for this project after the original designs; meat is original |

Digimon characters, names, crests and the Digivice/Tag designs belong to their respective
owners (BANDAI, Akiyoshi Hongo, Toei Animation). No ownership is claimed and no license is
granted. Rights holders can request removal through the issues of the main repository.
MD
echo "Sprite pack → $OUT"
