# Attribution and project status

Digimon Token Tamer (디지몬 토큰 테이머) is an unofficial, non-commercial Digimon fan project.

## Source code

The usage pipeline — local log readers for Claude Code, Codex and other AI coding tools, the
per-file usage cache, official limit lookups, the menu bar item, the usage detail and limit views
and parts of Settings — is adapted from:

- [DigiMonTokenBar](https://github.com/Choisiz/DigiMonTokenBar), Copyright (c) 2026 Choisiz
- [PokeTokenBar](https://github.com/chattymin/PokeTokenBar), Copyright (c) 2026 chattymin and contributors

Both are MIT licensed; the original copyright and permission notice is kept in `LICENSE`.
The growth game (eight partner lines, digivice / pendant / crest / bond rules, shop, notebook),
the light pixel UI and the sprite pipeline under `tools/` are new to this project.

The "DATA TRAFFIC" panel keeps only DigiMonTokenBar's "전체 서비스 · 상세 기록"
(all services · details) part.

## Third-party intellectual property

Digimon characters, names, crests, the Digivice and Tag designs and related artwork are not owned
by this project. The rights belong to their respective owners, including BANDAI, Akiyoshi Hongo
and Toei Animation. This project is not affiliated with, endorsed or sponsored by them.

The sprites (Wikimon Vital Bracelet dots, official crest dots, digitama patterns) are fan-use
material. They are **not committed to this repository and not bundled into the app**: they are
rebuilt locally with `tools/build_assets.sh`, and the app downloads them at runtime from the
separate repository [DigimonTokenTamer-sprites](https://github.com/jen454/DigimonTokenTamer-sprites)
into its cache folder. Rights holders can request removal through this repository's issues.
The MIT license of the source code grants no rights to that material.

비공식 팬 프로젝트이며 Bandai/Toei와 관련이 없습니다. 디지몬 관련 권리는 각 소유자에게 있습니다.
