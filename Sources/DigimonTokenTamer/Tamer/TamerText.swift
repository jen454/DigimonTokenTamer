import Foundation

/// Copy for the Tamer screens. Korean is the primary language (DESIGN.md); every other
/// language falls back to English.
struct TamerText {
    let lang: AppLanguage
    init(_ lang: AppLanguage) { self.lang = lang }

    private func s(_ ko: String, _ en: String) -> String { lang == .ko ? ko : en }

    // MARK: Tabs & sections
    var tabPartner: String { s("파트너", "Partner") }
    var tabShop: String { s("상점", "Shop") }
    var tabNotebook: String { s("수첩", "Notebook") }
    var dataTraffic: String { s("전체 서비스 · 상세 기록", "All services · Details") }
    var limitsTitle: String { s("사용 한도", "Usage limits") }

    // MARK: Partner card
    var digitama: String { s("디지타마", "Digitama") }
    func lineLabel(_ lineKo: String, _ lineKey: String) -> String {
        s("\(lineKo) 계열", "\(lineKey.prefix(1).uppercased() + lineKey.dropFirst()) line")
    }
    func untilStage(_ stage: String) -> String { s("\(stage)까지", "To \(stage)") }
    var hatchLabel: String { s("부화까지", "To hatch") }
    func gaugeCheck(_ percent: Int) -> String { s("진화 게이지 \(percent)%", "Gauge \(percent)%") }
    var digivice: String { s("디지바이스", "Digivice") }
    var pendant: String { s("펜던트", "Pendant") }
    var meat: String { s("고기", "Meat") }
    func crestName(_ ko: String, en: String) -> String { s("\(ko)의 문장", "Crest of \(en)") }
    func bondCheck(_ level: Int, _ need: Int) -> String { s("유대 Lv \(level) / \(need)", "Bond Lv \(level) / \(need)") }

    var chipNeeded: String { s("필요", "Needed") }
    var chipOwned: String { s("보유", "Owned") }
    var chipPendantNeeded: String { s("펜던트 필요", "Needs pendant") }
    var chipOff: String { s("꺼짐", "Dim") }
    var chipLit: String { s("빛남", "Shining") }

    var digiviceNeededDetail: String { s("성숙기 진화에 필요해요 · 파트너마다 1개", "Needed for Champion · one per partner") }
    var digiviceOwnedDetail: String { s("파트너와 연결됐어요", "Linked with your partner") }
    var pendantNeededDetail: String { s("펜던트가 있어야 문장을 끼울 수 있어요", "The crest needs a pendant to sit in") }
    func trialProgress(_ crestKo: String, en: String, _ days: Int, _ need: Int) -> String {
        s("\(crestKo)의 시련 · 성숙기로 \(need)일 함께하기 \(days)/\(need)",
          "Trial of \(en) · \(need) days together as a Champion \(days)/\(need)")
    }
    var crestShiningDetail: String { s("문장이 빛나고 있어요", "The crest is shining") }
    func bondDetail(_ level: Int, _ need: Int) -> String {
        s("궁극체까지 유대 Lv \(level) / \(need) · 고기를 주면 유대가 올라요",
          "Bond Lv \(level) / \(need) to Mega · meat raises bond")
    }
    func megaBondDetail(_ level: Int) -> String {
        s("유대 Lv \(level) · 게이지가 차면 유대가 1 올라요", "Bond Lv \(level) · each full gauge adds one level")
    }

    // Hints (DESIGN §3.2 ⑥)
    var hintDigivice: String { s("성숙기로 가려면 디지바이스가 필요해요", "Champion needs a digivice") }
    var hintPendant: String { s("완전체로 가려면 펜던트가 필요해요", "Ultimate needs a pendant") }
    func hintCrestSet(_ crestKo: String, en: String) -> String {
        s("펜던트에 문장을 끼웠어요. \(crestKo)의 시련을 마치면 문장이 빛나요.",
          "The crest sits in the pendant. Finish the Trial of \(en) to make it shine.")
    }
    func hintReady(_ stage: String) -> String {
        s("\(KoreanParticle.direction.attach(to: stage)) 진화할 수 있어요! 파트너 옆의 ! 를 누르면 진화가 시작돼요.",
          "Ready to evolve to \(stage)! Press the ! next to your partner.")
    }
    var hintBond: String { s("고기를 주면 유대가 올라요 → 상점", "Feed meat to raise bond → Shop") }
    var hintEgg: String { s("토큰을 쓰면 디지타마가 따뜻해져요. 게이지가 차면 부화해요.", "Using tokens warms the digitama. It hatches when the gauge fills.") }
    var hintMega: String { s("궁극체예요. 이제 게이지가 유대 레벨로 쌓여요.", "Mega reached. The gauge now builds bond levels.") }
    var goShop: String { s("상점", "Shop") }
    var evolveNow: String { s("진화", "Evolve") }
    func feedMeat(_ count: Int) -> String { s("고기 주기 (\(count))", "Feed meat (\(count))") }
    var storage: String { s("파트너 보관함", "Partner storage") }
    var storageHint: String { s("보관 중인 파트너는 자라지 않아요. 눌러서 교체해요.", "Stored partners do not grow. Click to switch.") }

    // MARK: First egg
    var chooseEggTitle: String { s("첫 디지타마를 골라 주세요", "Choose your first digitama") }
    var chooseEggHint: String { s("무늬가 계열을 정해요. 첫 알은 무료예요.", "The pattern decides the line. The first egg is free.") }

    // MARK: Shop
    var wallet: String { s("쓸 수 있는 토큰", "Tokens to spend") }
    var walletHint: String { s("사용한 토큰이 그대로 재화가 돼요. 실제 결제는 없어요.", "Tokens you use become currency. No real payments.") }
    var buy: String { s("구매", "Buy") }
    var notEnough: String { s("토큰 부족", "Not enough") }
    var shopEmpty: String { s("지금 살 수 있는 아이템이 없어요.", "Nothing to buy right now.") }
    var meatDetail: String { s("게이지와 유대를 올려요 · 소모품", "Raises gauge and bond · consumable") }
    var digiviceDetail: String { s("성장기 → 성숙기 진화의 열쇠 · 파트너마다 1회", "Key to Champion · once per partner") }
    var pendantDetail: String { s("문장을 끼우는 장비 · 완전체 진화의 열쇠", "Holds the crest · key to Ultimate") }
    func digitamaDetail(_ lineKo: String) -> String { s("\(lineKo) 계열의 알 · 사면 지금 파트너는 보관함으로 가요", "\(lineKo) line egg · your partner moves to storage") }
    func owned(_ count: Int) -> String { s("보유 \(count)", "Owned \(count)") }

    // MARK: Notebook
    func notebookCount(_ have: Int, _ total: Int) -> String { s("등록 \(have) / \(total)", "\(have) / \(total) registered") }
    var notebookHint: String { s("등록된 형태를 누르면 메뉴바에 띄워요.", "Click a registered form to show it in the menu bar.") }
    var followPartner: String { s("지금 파트너 따라가기", "Follow current partner") }
    var unknownForm: String { "???" }

    // MARK: Scenes
    func crestLitTitle(_ ko: String, en: String) -> String { s("\(ko)의 문장이 빛났다!", "The Crest of \(en) is shining!") }
    var crestLitSubtitle: String { s("완전체 진화가 열렸어요", "Ultimate evolution unlocked") }
    func evolvedTitle(_ name: String) -> String { s("\(KoreanParticle.direction.attach(to: name)) 진화했다!", "Digivolved into \(name)!") }
    func hatchedTitle(_ name: String) -> String { s("\(KoreanParticle.subject.attach(to: name)) 태어났다!", "\(name) hatched!") }
    var tapToClose: String { s("눌러서 닫기", "Click to close") }

    // MARK: Notifications
    var notifyReadyTitle: String { s("진화할 수 있어요!", "Ready to evolve!") }
    func notifyReadyBody(_ name: String) -> String { s("\(name)의 진화 조건이 모두 갖춰졌어요.", "\(name) meets every condition.") }
    var notifyHatchTitle: String { s("디지타마가 부화했어요", "Your digitama hatched") }
    func notifyHatchBody(_ name: String) -> String { s("\(name)(이)가 태어났어요.", "\(name) was born.") }
    var notifyEvolvedTitle: String { s("파트너가 진화했어요", "Your partner digivolved") }
    func notifyEvolvedBody(_ name: String) -> String { s("\(name)(으)로 진화했어요.", "It became \(name).") }

    // MARK: Settings
    var displayFormTitle: String { s("메뉴바 표시 형태", "Menu bar form") }
    var displayFormHint: String { s("수첩에 등록된 형태 중에서 골라요. 보이는 모습만 바뀌고 육성은 그대로예요.", "Pick any registered form. Only the look changes; growth stays the same.") }
    var spritePackTitle: String { s("스프라이트 팩", "Sprite pack") }
    func spritePackStatus(_ found: Int, _ total: Int) -> String { s("이미지 \(found) / \(total)개 찾음", "\(found) / \(total) images found") }
    var spritePackMissing: String {
        s("도트 이미지를 내려받는 중이거나 받지 못했어요. 인터넷 연결을 확인하고 '다시 찾기'를 눌러 주세요.",
          "Sprites are downloading or could not be fetched. Check your connection and press Rescan.")
    }
    var spritePackURL: String { s("내려받기 주소", "Download base URL") }
    var openSpriteFolder: String { s("폴더 열기", "Open folder") }
    var reloadSprites: String { s("다시 찾기", "Rescan") }
    var notice: String {
        s("비공식 팬 프로젝트이며 Bandai/Toei와 관련이 없습니다.", "Unofficial fan project, not affiliated with Bandai/Toei.")
    }
}
