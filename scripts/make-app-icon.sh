#!/usr/bin/env bash
# Regenerate the app icon (D1+ "디지바이스형") from tools/app_icon.py:
#   Sources/DigimonTokenTamer/Resources/AppIcon.icns   (bundled by build-app.sh)
#   docs/images/app-icon.png                           (256 px, for the README)
# Needs Pillow; tools/build_assets.sh creates the .venv. The outputs are committed, so a normal
# build does not need Python.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PY="$ROOT/.venv/bin/python"
[ -x "$PY" ] || { python3 -m venv "$ROOT/.venv"; "$ROOT/.venv/bin/pip" install -q pillow; }
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/AppIcon.iconset"
"$PY" -I "$ROOT/tools/app_icon.py" --iconset d1p-digivice "$WORK/AppIcon.iconset" >/dev/null
iconutil -c icns "$WORK/AppIcon.iconset" -o "$ROOT/Sources/DigimonTokenTamer/Resources/AppIcon.icns"
mkdir -p "$ROOT/docs/images"
cp "$WORK/AppIcon.iconset/icon_128x128@2x.png" "$ROOT/docs/images/app-icon.png"
echo "AppIcon.icns and docs/images/app-icon.png updated"
