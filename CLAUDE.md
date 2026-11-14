# 디지몬 토큰 테이머

AI 코딩 도구의 토큰 사용량으로 디지몬 어드벤처 파트너 8계열을 키우는 macOS 메뉴바 앱이다. PokeTokenBar를 레퍼런스로 한다.

- **설계 전체**: `docs/DESIGN.md`를 먼저 읽는다. 범위, 진화 조건, 상점, UI, 에셋, 남은 일, 결정 기록이 다 들어 있다.
- **확정 사항은 다시 논의하지 않는다.**
  - 8계열 × 6단계, 분기 없음
  - 성장기 → 성숙기 = 디지바이스, 성숙기 → 완전체 = 펜던트 + 문장, 완전체 → 궁극체 = 유대 레벨
  - 퇴화 없음
  - "!"는 진화 가능할 때만 표시
  - 이름은 "태그"가 아니라 "펜던트"
- **에셋**: `./tools/build_assets.sh`로 `assets/`를 다시 만든다. `assets/`는 git에 넣지 않는다.
  - Wikimon 도트, 공식 문장, 원작 디지타마 무늬 같은 저작권 에셋은 절대 커밋하지 않는다.
- **Wikimon 접근 예절**: UA `DigiTokenBar-research/0.1`을 쓰고 요청 사이에 3~5초를 쉰다. 앱에서 직접 링크해 쓰지 않는다.
- **스프라이트 규칙**: 원래 픽셀 크기, 모두 오른쪽을 봄, 보간 없이(nearest-neighbor) 렌더링한다.
- **작업 기록**: `presentation/log.md`에 단계별로 남긴다. 형식은 "뭘 시켰나 / 뭐가 나왔나 / 내가 뭘 고쳤나"이다.
- **코드**: DigiMonTokenBar(MIT)를 베이스로 한 Swift 패키지다. 구조와 빌드 방법은 `README.md`를 본다.
  - `Usage/`, `UsageUI/`: 상류에서 가져온 사용량 수집과 한도
  - `Tamer/`, `UI/`: 이 프로젝트의 육성 게임과 화면
  - 밸런스 수치는 `Tamer/TamerBalance.swift` 한 곳에만 둔다.
  - 테스트는 `./scripts/test.sh`로 돌린다 (Swift Testing).
  - 앱 저장소, 로그, 로그인 항목 이름은 `DigimonTokenTamer`를 쓴다. 상류 앱(DigiTokenBar)의 파일을 건드리지 않는다.
