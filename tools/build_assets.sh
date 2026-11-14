#!/usr/bin/env bash
# Rebuild every sprite / icon / prototype page under assets/ from scratch.
# Assets are fan-use only (Wikimon / official designs) and are git-ignored; never commit them.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; T="$ROOT/tools"; A="$ROOT/assets"
PY="$ROOT/.venv/bin/python"
[ -x "$PY" ] || { python3 -m venv "$ROOT/.venv"; "$ROOT/.venv/bin/pip" install -q pillow; }
UA="DigiTokenBar-research/0.1"   # be polite to Wikimon: identify ourselves and wait between requests

# 1. reference images (only fetched when missing)
mkdir -p "$A/refs/digitama" "$A/refs/crest"
EGGS="agumon=y08AOPLn96ogvh2B_9C9_cq0g6fWFTAvIo_b42tNOu60dKf_I5CTp1eDLDjwNWCwhydNA0lKWJMrjyOqYC-0hw.webp
gabumon=hPYNNlc6-1uEykMKghqhQPxPdaBYRICOiDvMYZJ0waQhoui6KS27GqHBQcfIxE1qGyEMJW0SUY06wLgv57FLYg.webp
biyomon=-nPelhdrAaeZt4TKYSotGmonYfw7msJeISwpE7Bq6Av471aYY0nPOcqEdELvqkxd-2iVkYsbe0L-_AMzfC78_w.webp
tentomon=LIdjdmjw7CyXvk7AuUxZPXweLIR_Lrg8ewfPK7GSHnlVdAviRUZi-w_KMmWcqXAaLiuINITLvfNatZXEt-OyGA.webp
palmon=C-SU8iQIKAddG4eEfIvk2T_hTIYw-w8HHgG_cyzBEPF-xON6OISdA8A9OO6VCd9xJwSqD04GXvQKlSl0zkJUwg.webp
gomamon=gwAQFmAVBoDGYgpom_8yE2R5LygS0V-BbCb1BlOujOuAdJPUE5lPCdgBOt8kfW_CMd8vEMPFemb0ryz8gV9zFg.webp
patamon=UGm3fe-DaL_Rq-jXe6cB0nl-3_dQwg79nfBlTKvjIYtE6mz1olFQVYgSCJjQRK6Xb3N2_o3YWMyYZKfm3ddejg.png
tailmon=dpO7UWgeWBa5KlVHaaDdiYNZPesFSGOu27GpULv2qO2_H-4p0DQT0QZhqDSUFKszglvN3El08FeqTdj6qQdj-g.webp"
for e in $EGGS; do l="${e%%=*}"; f="${e#*=}"; out="$A/refs/digitama/$l.${f##*.}"
  [ -f "$out" ] || { curl -sfL -A "Mozilla/5.0" -o "$out" "https://i.namu.wiki/i/$f"; sleep 2; }; done
for k in courage friendship love knowledge purity sincerity hope light; do f="Crest_${k}_vpet_Digivice.gif"
  [ -f "$A/refs/crest/$f" ] && continue
  u=$(curl -s -G -A "$UA" https://wikimon.net/api.php --data-urlencode action=query --data-urlencode "titles=File:$f" \
      --data-urlencode prop=imageinfo --data-urlencode iiprop=url --data-urlencode format=json \
      | python3 -I -c "import json,sys;p=list(json.load(sys.stdin)['query']['pages'].values())[0];print(p['imageinfo'][0]['url'])")
  curl -sf -A "$UA" -o "$A/refs/crest/$f" "$u"; sleep 4; done

# 2. sprites -> native PNG/SVG (all facing right), with hand-drawn replacements
[ -f "$A/sprites-raw/manifest.json" ] || python3 -I "$T/download_all.py" "$A/sprites-raw"
"$PY" -I "$T/handdrawn.py" "$A/handdrawn"
"$PY" -I "$T/to_svg.py" "$A/sprites-raw" "$A/build" "$A/handdrawn"
# 3. digitama, items, crests + tags (crests.py overwrites the pendant icons from items.py)
"$PY" -I "$T/digitama_ref.py" "$A/refs/digitama" "$A/build/digitama"
"$PY" -I "$T/items.py" "$A/build/items"
"$PY" -I "$T/digivice.py" "$A/build/items"
"$PY" -I "$T/crests.py" "$A/refs/crest" "$A/build/crests" "$A/build/items"
# 4. prototype pages
python3 -I "$T/motion_lab.py" "$A/build"
python3 -I "$T/crest_mockup.py" "$A/build"
echo "done → $A/build"
