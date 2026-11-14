#!/usr/bin/env bash
# Copy the locally built sprite pack into the app's cache folder.
#
# The sprites are fan-use assets (Wikimon V-Pet dots, official crest/digitama designs): they are
# never committed and never bundled into the .app (docs/DESIGN.md §5.2). This copies only the
# files the app reads — png/, digitama/, crests/, items/ — from assets/build into
#   ~/Library/Application Support/DigimonTokenTamer/sprites/
# Run ./tools/build_assets.sh first if assets/build does not exist yet.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/assets/build"
DEST="${DTT_STATE_DIR:-$HOME/Library/Application Support/DigimonTokenTamer}/sprites"
if [ ! -f "$SRC/manifest.json" ]; then
  echo "assets/build is missing — run ./tools/build_assets.sh first." >&2
  exit 1
fi
mkdir -p "$DEST"
for dir in png digitama crests items; do
  rsync -a --delete --include='*/' --include='*.png' --exclude='*' "$SRC/$dir/" "$DEST/$dir/"
done
count=$(find "$DEST" -name '*.png' | wc -l | tr -d ' ')
echo "Installed $count sprite files → $DEST"
