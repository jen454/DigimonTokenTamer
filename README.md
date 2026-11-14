<p align="center"><img src="docs/images/app-icon.png" width="128" alt="디지바이스형 앱 아이콘"></p>

# DigimonTokenTamer

디지몬 토큰 테이머: AI 코딩 도구에 쓴 토큰으로 디지몬 어드벤처 파트너 8계열을 키우는 macOS 메뉴바 앱입니다.

> 비공식 팬 프로젝트이며 Bandai/Toei와 관련이 없습니다. 자세한 고지는 [NOTICE.md](NOTICE.md)를 보세요.

- 설계 전체: [docs/DESIGN.md](docs/DESIGN.md)
- 코드 베이스: [DigiMonTokenBar](https://github.com/Choisiz/DigiMonTokenBar) (← [PokeTokenBar](https://github.com/chattymin/PokeTokenBar)), MIT

## 무엇이 들어 있나

| 영역 | 내용 |
|---|---|
| 메뉴바 | 파트너 도트(정수 배율, 보간 없음)와 오늘 토큰을 표시합니다. 한도 %는 설정에서 켤 수 있습니다. 진화할 수 있을 때만 주황색 "!"가 통통 튑니다. |
| 파트너 카드 | 왼쪽 캐릭터 상자, 오른쪽 프로필(형·속성, 그 오른쪽에 필살기)과 진화 게이지 (DigiTokenBar 홈 카드 방식). 아래는 조건 줄 → 장비/문장 줄 → 힌트 (목업 `crest-mockup.html`). |
| 동작 | 평소엔 걷고, 클릭하면 하트(너무 많이 누르면 짜증), 진화할 수 있으면 점프하며 "!", 토큰 갱신이 안 되면 잠듭니다. 고기를 주면 먹고, 진화 후엔 기뻐합니다. |
| 진화 | 게이지 아래에 토큰 양이 보이고, 진화하면 게이지는 0부터 다시 찹니다. 유년기 I → II → 성장기는 자동입니다. 성장기 → 성숙기는 **디지바이스**, 성숙기 → 완전체는 **펜던트 + 빛나는 문장**, 완전체 → 궁극체는 **유대 레벨**이 필요하고, 모두 "!"를 눌러 시작합니다. |
| 연출 | 부화, 진화(실루엣 깜빡임 → 흰 섬광), 문장 빛남, 디지바이스 획득, 펜던트 장착, 고기 먹기 |
| 상점 | 고기, 디지바이스, 펜던트, 디지타마 8종을 항상 다 보여 줍니다. 가진 것은 "구매 완료", 아직 못 사는 것은 이유를 표시합니다. 문장은 팔지 않습니다. |
| 가방 | 고기(먹이기), 지금 파트너의 디지바이스와 펜던트, 산 디지타마(키우기)가 들어 있습니다. |
| 바탕화면 펫 | 파트너를 바탕화면에 띄웁니다. 드래그로 옮기고, 클릭하면 쓰다듬고, 더블클릭하면 팝오버가 열립니다 (설정 또는 아래 눈 아이콘). |
| 난이도 | PokeTokenBar처럼 성장(게이지 크기)과 상점 가격 배율을 10%~200%로 조절합니다. |
| 노트북 | 계열별 한 줄에 문장 엠블럼과 6단계 칸이 있고, 못 본 형태는 실루엣입니다. 누르면 **아날라이저**(정보, 필살기, 진화 루트, 공식 도감 링크, 메뉴바에 띄우기)가 열립니다. 메뉴바 형태도 여기서 고릅니다. |
| 이름 | 디지몬 이름은 공식 한국어 이름(어드벤처 현지화명: 깜몬, 가루몬, 원뿔몬 …)으로 보입니다. |
| 사용량 | DigiMonTokenBar의 로컬 로그 수집(Claude Code, Codex 외)과 공식 한도 조회를 그대로 씁니다. DATA TRAFFIC은 **전체 서비스 · 상세 기록**만 남겼고, 그 안의 AI 툴 탭을 누르면 해당 툴의 입력·출력·캐시와 한도가 보입니다. |

## 다운로드·설치

macOS 14 이상, Apple Silicon Mac에서 확인했습니다.

1. [Releases](https://github.com/jen454/DigimonTokenTamer/releases/latest)에서 `DigimonTokenTamer-…-macos-arm64.zip`을 받습니다.
2. 압축을 풀고 `DigimonTokenTamer.app`을 **응용 프로그램** 폴더로 옮긴 뒤 엽니다. 메뉴바에 아이콘이 생깁니다.
3. 처음 열 때 실행이 막히면 **시스템 설정 → 개인정보 보호 및 보안 → 확인 없이 열기**를 누릅니다. ad-hoc 서명이라 Apple 공증을 받지 않았습니다.
4. 메뉴바를 누르고 디지타마 8개 중 하나를 고릅니다 (첫 알은 무료).

- **도트 이미지는 첫 실행 때 자동으로 내려받습니다** (인터넷 필요, 약 340KB).
  - 받는 곳: [DigimonTokenTamer-sprites](https://github.com/jen454/DigimonTokenTamer-sprites)
  - 저장 위치: `~/Library/Application Support/DigimonTokenTamer/sprites/`
  - 한 번 받으면 이후에는 오프라인에서도 씁니다.
- **설치 전에 쓴 토큰은 세지 않습니다.** 첫 갱신이 기준점이 되고, 그 뒤 증가분부터 자랍니다.
- Claude Code, Codex 같은 도구의 로컬 기록을 읽습니다. 사용 로그나 프롬프트를 업로드하지 않습니다.
- 업데이트는 앱을 종료하고 새 zip의 앱으로 바꾸면 됩니다. 육성 저장은 그대로 남습니다.

## 소스에서 빌드

Swift 6가 필요합니다 (Command Line Tools만 있어도 됩니다).

```sh
./scripts/build-app.sh         # build/DigimonTokenTamer.app (ad-hoc 서명)
open build/DigimonTokenTamer.app
```

스프라이트는 앱이 스스로 내려받습니다. 직접 만든 스프라이트를 쓰려면 아래처럼 합니다.

```sh
./tools/build_assets.sh        # assets/build 에 생성 (git 제외)
./scripts/install-sprites.sh   # 앱 캐시 폴더로 복사 (build-app.sh 도 assets/build 가 있으면 자동 실행)
./scripts/package-sprites.sh   # 스프라이트 저장소에 올릴 build/sprite-pack 생성
./scripts/package-app.sh       # Release 용 zip + sha256
```

## 개발

```sh
swift build
./scripts/test.sh              # Swift Testing (CLT 환경에서는 Testing.framework 경로를 잡아 줌)
./scripts/gen-catalog.sh       # Resources/Tamer/catalog.json 을 고친 뒤 Swift 소스로 다시 포함
./scripts/make-app-icon.sh     # tools/app_icon.py 로 AppIcon.icns 와 README 아이콘을 다시 생성

# 상태별 화면을 PNG로 렌더링 (실제 저장/설정은 건드리지 않음)
DTT_STATE_DIR=/tmp/dtt DTT_SPRITES_DIR=$PWD/assets/build DTT_RENDER_PREVIEWS=/tmp/dtt-previews \
  .build/debug/DigimonTokenTamer
```

| 환경 변수 | 용도 |
|---|---|
| `DTT_STATE_DIR` | 저장 폴더를 바꿉니다 (기본 `~/Library/Application Support/DigimonTokenTamer`). |
| `DTT_SPRITES_DIR` | 스프라이트를 이 폴더에서 먼저 찾습니다 (예: `assets/build`). |
| `DTT_SPRITES_URL` | 스프라이트를 이 주소에서 받습니다 (예: 로컬 `python3 -m http.server`). |
| `DTT_RENDER_PREVIEWS` | 화면 미리보기를 렌더링하고 종료합니다. |

### 구조

```
Sources/DigimonTokenTamer/
  App/       메뉴바·팝오버 (AppDelegate), 미리보기 렌더러
  Tamer/     육성 게임: 카탈로그, 밸런스, 토큰 장부, 상태, 스프라이트 팩, 메뉴바 프레임
  UI/        파트너 카드, 연출, 상점, 가방, 노트북, 설정, 테마
  Usage/     DigiMonTokenBar 사용량 파이프라인 (로그 파서, 캐시, 한도, UsageStore)
  UsageUI/   상세 기록 패널, 한도 패널, 월간 추이 (DigiMonTokenBar에서 이식)
  Resources/Tamer/catalog.json   8계열 × 6단계 이름·문장·스프라이트 경로 (이미지 없음, 빌드 시 Swift 소스로 포함)
Tests/DigimonTokenTamerTests/    토큰 장부, 진화 조건, 상점, 저장
tools/     에셋 생성 스크립트 (Python)
scripts/   앱 빌드, 스프라이트 설치, 테스트
```

### 밸런스

모든 수치는 `Sources/DigimonTokenTamer/Tamer/TamerBalance.swift` 한 곳에 있습니다. 현재 값은 DigiMonTokenBar의 기준(하루 평균 약 253M 토큰, 일반 라인 졸업 750M)에서 잡은 1차 값이며 [DESIGN.md §2.6](docs/DESIGN.md)에 정리되어 있습니다.

## 저작권

소스 코드는 MIT입니다 ([LICENSE](LICENSE), 원저작권 표시 유지). 앱 아이콘은 디지바이스 디자인을 바탕으로 그린 팬아트입니다. 디지몬 캐릭터, 이름, 문장, 디지바이스 디자인의 권리는 각 소유자에게 있습니다. 도트 이미지는 이 저장소에 커밋하지 않고 앱에도 넣지 않습니다. 앱이 별도 스프라이트 저장소에서 실행 중에 내려받습니다.
