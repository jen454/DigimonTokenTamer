#!/usr/bin/env bash
# Embed Resources/Tamer/catalog.json as Swift source (Tamer/TamerCatalogData.swift).
#
# A SwiftPM resource bundle would make the generated `Bundle.module` accessor embed the absolute
# build path (e.g. /Users/<name>/…/.build) in the shipped binary. Compiling the JSON in avoids
# both that and any runtime file lookup. Re-run after editing catalog.json; a test checks they match.
set -euo pipefail
cd "$(dirname "$0")/.."
SRC=Sources/DigimonTokenTamer/Resources/Tamer/catalog.json
OUT=Sources/DigimonTokenTamer/Tamer/TamerCatalogData.swift
python3 -I - "$SRC" "$OUT" <<'PY'
import json, sys
src, out = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8").read()
json.loads(text)  # must be valid JSON
assert '"""#' not in text
open(out, "w", encoding="utf-8").write(
    "// Generated from Resources/Tamer/catalog.json by scripts/gen-catalog.sh — do not edit.\n"
    "enum TamerCatalogData {\n"
    "    static let json = #\"\"\"\n" + text.rstrip("\n") + "\n\"\"\"#\n}\n")
print("wrote", out)
PY
