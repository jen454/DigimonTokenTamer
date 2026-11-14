#!/usr/bin/env bash
# Build a local, ad-hoc signed DigimonTokenTamer.app (adapted from DigiMonTokenBar's
# scripts/build-digimon-app.sh). Sprites are not bundled — see scripts/install-sprites.sh.
set -euo pipefail
cd "$(dirname "$0")/.."
CONFIGURATION="${DTT_CONFIGURATION:-release}"
swift build -c "$CONFIGURATION"
BIN_DIR="$(swift build -c "$CONFIGURATION" --show-bin-path)"
APP="${DTT_OUTPUT_DIR:-build}/DigimonTokenTamer.app"
# A copy running from this path is quit before its bundle is replaced and reopened afterwards,
# so the running app never keeps executing code that no longer matches its files.
# DTT_NO_RELAUNCH=1 skips the reopen.
RUNNING_BIN="$(cd "$(dirname "$APP")" 2>/dev/null && pwd)/$(basename "$APP")/Contents/MacOS/DigimonTokenTamer"
WAS_RUNNING=0
if pgrep -f "$RUNNING_BIN" >/dev/null 2>&1; then
  WAS_RUNNING=1
  pkill -TERM -f "$RUNNING_BIN" || true
  for _ in 1 2 3 4 5 6 7 8 9 10; do pgrep -f "$RUNNING_BIN" >/dev/null 2>&1 || break; sleep 0.5; done
fi
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/DigimonTokenTamer" "$APP/Contents/MacOS/DigimonTokenTamer"
# Drop local symbols that can embed the builder's home directory.
strip -S -x "$APP/Contents/MacOS/DigimonTokenTamer"
# Guard: no artwork may enter the bundle (docs/DESIGN.md §5.2).
if find "$APP/Contents/Resources" \( -name '*.png' -o -name '*.gif' -o -name '*.svg' -o -name '*.webp' \) | grep -q .; then
  echo "Refusing to build: image files found in the app bundle." >&2
  exit 1
fi
cp LICENSE NOTICE.md "$APP/Contents/Resources/"
# Guard: the binary must not carry the builder's local paths (home folder / user name).
if strings "$APP/Contents/MacOS/DigimonTokenTamer" | grep -q "$HOME"; then
  echo "Refusing to build: the binary embeds a local path under $HOME." >&2
  exit 1
fi
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>local.digimontokentamer.app</string>
<key>CFBundleName</key><string>DigimonTokenTamer</string>
<key>CFBundleDisplayName</key><string>디지몬 토큰 테이머</string>
<key>CFBundleExecutable</key><string>DigimonTokenTamer</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
# "Launch at login" (Settings) registers this agent; KeepAlive relaunches after a crash (upstream).
mkdir -p "$APP/Contents/Library/LaunchAgents"
cat > "$APP/Contents/Library/LaunchAgents/io.github.digimontokentamer.login.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>io.github.digimontokentamer.login</string>
<key>ProgramArguments</key><array><string>/Applications/DigimonTokenTamer.app/Contents/MacOS/DigimonTokenTamer</string></array>
<key>RunAtLoad</key><true/>
<key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>
<key>LimitLoadToSessionType</key><string>Aqua</string>
</dict></plist>
PLIST
codesign --force -s - "$APP"
echo "Built: $PWD/$APP"
# Local convenience: refresh the sprite cache from assets/build (outside the bundle, never shipped).
if [ -f assets/build/manifest.json ]; then
  ./scripts/install-sprites.sh
else
  echo "No sprites yet: run ./tools/build_assets.sh, then ./scripts/install-sprites.sh" >&2
fi
if [ "$WAS_RUNNING" = 1 ] && [ "${DTT_NO_RELAUNCH:-0}" != 1 ]; then
  open "$APP"
  echo "Relaunched the running copy."
else
  echo "Run: open $APP"
fi
