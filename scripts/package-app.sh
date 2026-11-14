#!/usr/bin/env bash
# Zip the release app for GitHub Releases: build/DigimonTokenTamer-<version>-macos-arm64.zip (+ .sha256).
# The zip holds the app only; sprites are downloaded by the app on first launch.
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/build-app.sh >/dev/null
APP=build/DigimonTokenTamer.app
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP/Contents/Info.plist")
ZIP="build/DigimonTokenTamer-$VERSION-macos-arm64.zip"
rm -f "$ZIP" "$ZIP.sha256"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"
(cd build && shasum -a 256 "$(basename "$ZIP")" > "$(basename "$ZIP").sha256")
echo "Release zip: $PWD/$ZIP"
cat "$ZIP.sha256"
