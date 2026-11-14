import Foundation

/// Token amounts in millions for the shop: "10M", "2.5M", "1,432M" (never switches to B).
enum MillionFormat {
    static func string(_ tokens: Int) -> String {
        let millions = Double(tokens) / 1_000_000
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = millions < 10 && millions.truncatingRemainder(dividingBy: 1) != 0 ? 1 : 0
        formatter.minimumFractionDigits = 0
        return (formatter.string(from: NSNumber(value: millions)) ?? String(Int(millions))) + "M"
    }
}

/// Copy for the Tamer screens. Korean is the primary language (DESIGN.md); every other
/// language falls back to English.
struct TamerText {
    let lang: AppLanguage
    init(_ lang: AppLanguage) { self.lang = lang }

    private func s(_ ko: String, _ en: String) -> String { lang == .ko ? ko : en }

    // MARK: Tabs & sections
    var tabPartner: String { s("파트너", "Partner") }
    var tabShop: String { s("상점", "Shop") }
    var tabNotebook: String { s("노트북", "Notebook") }
    var tabBag: String { s("가방", "Bag") }
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

    var movesLabel: String { s("필살기", "Moves") }
    func eggInfo(_ lineKo: String, crest: String) -> String { s("\(lineKo) 계열의 알 · \(crest)", "\(lineKo) line egg · \(crest)") }
    func hatchCheck(_ percent: Int) -> String { s("부화 게이지 \(percent)%", "Hatch gauge \(percent)%") }
    var noProfile: String { s("프로필 정보 없음", "No profile information") }
    var hatchGauge: String { s("부화 게이지", "Hatch gauge") }
    var evolutionGauge: String { s("진화 게이지", "Evolution gauge") }
    func toHatch(_ amount: String) -> String { s("부화까지 \(amount)", "\(amount) to hatch") }
    func toNextStage(_ amount: String) -> String { s("다음 진화까지 \(amount)", "\(amount) to the next stage") }
    func toBondLevel(_ amount: String) -> String { s("유대 Lv +1까지 \(amount)", "\(amount) to the next bond level") }
    var gaugeFull: String { s("게이지 가득 참", "Gauge full") }
    var petHelp: String { s("눌러서 쓰다듬기", "Click to pet") }
    var petAction: String { s("쓰다듬기", "Pet") }
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
    var hintBond: String { s("고기를 주면 유대가 올라요", "Feed meat to raise bond") }
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
    var purchased: String { s("구매 완료", "Purchased") }
    var lockedFirstEgg: String { s("첫 디지타마는 파트너 탭에서 무료로 골라요", "Pick your first digitama for free on the Partner tab") }
    var lockedNeedsHatch: String { s("파트너가 부화하면 살 수 있어요", "Available once your partner hatches") }
    var lockedFromChampion: String { s("성숙기부터 살 수 있어요", "Available from the Champion stage") }
    var forCurrentPartner: String { s("지금 파트너 기준", "For the current partner") }
    var notEnough: String { s("토큰 부족", "Not enough") }
    var shopEmpty: String { s("지금 살 수 있는 아이템이 없어요.", "Nothing to buy right now.") }
    var meatDetail: String { s("게이지와 유대를 올려요 · 소모품", "Raises gauge and bond · consumable") }
    var digiviceDetail: String { s("성장기 → 성숙기 진화의 열쇠 · 파트너마다 1회", "Key to Champion · once per partner") }
    var pendantDetail: String { s("문장을 끼우는 장비 · 완전체 진화의 열쇠", "Holds the crest · key to Ultimate") }
    func digitamaDetail(_ lineKo: String) -> String { s("\(lineKo) 계열의 알 · 사면 가방에 들어가요", "\(lineKo) line egg · goes to your bag") }
    func owned(_ count: Int) -> String { s("보유 \(count)", "Owned \(count)") }

    // MARK: Bag
    var bagEmpty: String { s("가방이 비어 있어요. 상점에서 아이템을 사 보세요.", "Your bag is empty. Visit the shop.") }
    var bagConsumables: String { s("소모품", "Consumables") }
    var bagEquipment: String { s("파트너 장비", "Partner equipment") }
    var bagEggs: String { s("디지타마", "Digitama") }
    var feed: String { s("먹이기", "Feed") }
    var startRaising: String { s("키우기", "Raise") }
    var startRaisingHint: String { s("키우기를 누르면 이 알이 파트너가 되고, 지금 파트너는 보관함으로 가요.", "Raising this egg makes it your partner; the current one moves to storage.") }
    func equipped(_ name: String) -> String { s("장착 중 · \(name)", "Equipped · \(name)") }
    var notOwned: String { s("없음", "None") }
    func meatCount(_ n: Int) -> String { s("\(n)개", "×\(n)") }

    // MARK: Notebook
    func notebookCount(_ have: Int, _ total: Int) -> String { s("등록 \(have) / \(total)", "\(have) / \(total) registered") }
    var notebookHint: String { s("등록된 형태를 누르면 아날라이저가 열려요. 주황 테두리는 메뉴바에 띄운 형태예요.", "Click a registered form to open the Analyzer. The orange outline marks the menu bar form.") }

    // MARK: Analyzer (notebook detail — Koushiro's Digimon Analyzer)
    var analyzerTitle: String { s("아날라이저", "Analyzer") }
    var back: String { s("노트북", "Notebook") }
    var analyzerProfile: String { s("디지몬 정보", "Digimon data") }
    var analyzerType: String { s("형", "Type") }
    var analyzerAttribute: String { s("속성", "Attribute") }
    var analyzerStage: String { s("세대", "Level") }
    var analyzerMoves: String { s("필살기", "Moves") }
    var analyzerNoAttribute: String { s("없음", "None") }
    var analyzerRoute: String { s("진화 루트", "Evolution route") }
    var analyzerCrest: String { s("문장", "Crest") }
    var analyzerOfficial: String { s("공식 도감에서 전체 설명 보기 ↗", "Read the full official profile ↗") }
    var analyzerNoOfficial: String { s("공식 도감 정보가 없는 형태예요.", "No official profile for this form.") }
    var analyzerNameNote: String { s("공식 한국어 이름이 확인되지 않아 음역으로 표기했어요.", "No official Korean name; transliterated.") }
    var showInMenuBar: String { s("메뉴바에 띄우기", "Show in menu bar") }
    var shownInMenuBar: String { s("메뉴바에 띄우는 중 · 해제", "Shown in menu bar · Undo") }
    var crestLitState: String { s("빛난 적 있음", "Has shone") }
    var crestDimState: String { s("아직 빛나지 않음", "Not yet shone") }
    func routeCondition(_ stage: Int) -> String {
        switch stage {
        case 0: return s("부화", "Hatch")
        case 1, 2: return s("게이지", "Gauge")
        case 3: return s("디지바이스", "Digivice")
        case 4: return s("펜던트 + 문장", "Pendant + crest")
        default: return s("유대 Lv \(TamerBalance.bondLevelForMega)", "Bond Lv \(TamerBalance.bondLevelForMega)")
        }
    }
    var followPartner: String { s("지금 파트너 따라가기", "Follow current partner") }
    var pickFromNotebook: String { s("노트북에서 선택…", "Choose in Notebook…") }
    var pickMenuBarForm: String { s("메뉴바 형태 고르기", "Choose menu bar form") }
    var pickBanner: String { s("메뉴바에 띄울 형태를 눌러 주세요", "Click the form to show in the menu bar") }
    var pickHint: String { s("등록된 형태만 고를 수 있어요. 보이는 모습만 바뀌고 육성은 그대로예요.", "Only registered forms can be chosen. Only the look changes; growth stays the same.") }
    var cancel: String { s("취소", "Cancel") }
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

    // MARK: Floating pet
    var petTitle: String { s("바탕화면 펫", "Desktop pet") }
    var petToggle: String { s("바탕화면에 파트너 띄우기", "Show partner on the desktop") }
    var petHint: String { s("드래그해서 옮기고, 클릭하면 쓰다듬고, 더블클릭하면 팝오버가 열려요. 오른쪽 클릭 메뉴도 있어요.", "Drag to move, click to pet, double-click to open the popover. Right-click for a menu.") }
    var petSize: String { s("크기", "Size") }
    var petShow: String { s("바탕화면 펫 보이기", "Show desktop pet") }
    var petHide: String { s("바탕화면 펫 숨기기", "Hide desktop pet") }
    var openPopover: String { s("팝오버 열기", "Open popover") }

    // MARK: Difficulty (as PokeTokenBar)
    var difficultyTitle: String { s("난이도", "Difficulty") }
    var difficultyGrowth: String { s("성장", "Growth") }
    var difficultyShop: String { s("상점 가격", "Shop prices") }
    var difficultyEasy: String { s("쉬움", "Easy") }
    var difficultyHard: String { s("어려움", "Hard") }
    var difficultyCheap: String { s("저렴", "Cheap") }
    var difficultyExpensive: String { s("비쌈", "Expensive") }
    var difficultyHint: String {
        s("성장은 진화 게이지 크기, 상점 가격은 아이템 값에 곱해져요. 지금 게이지의 진행률은 그대로 유지돼요.",
          "Growth multiplies the gauge sizes, shop prices the item prices. Current gauge progress keeps its percentage.")
    }
    var save: String { s("저장", "Save") }
    var resetDefault: String { s("기본값", "Default") }

    // MARK: Settings
    var displayFormTitle: String { s("메뉴바 표시 형태", "Menu bar form") }
    var displayFormHint: String { s("노트북에서 선택하면 노트북이 열려요. 등록된 형태를 누르면 메뉴바에 띄워요. 보이는 모습만 바뀌고 육성은 그대로예요.", "Pick any registered form. Only the look changes; growth stays the same.") }
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
