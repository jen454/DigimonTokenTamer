import Foundation

/// One partner line the user has started (DESIGN §2). Stored partners keep their state but do
/// not grow; only the active partner receives tokens.
struct PartnerState: Codable, Equatable, Sendable, Identifiable {
    let line: String
    /// -1 = digitama (egg), 0…5 = In-Training I … Mega.
    var stage: Int = -1
    /// Tokens put into the current stage's gauge.
    var gauge: Int = 0
    var hasDigivice = false
    var hasPendant = false
    /// Crest trial progress: distinct days with token use while a Champion.
    var crestDays = 0
    var crestLastDay: String?
    /// The trial is complete. The crest *shines* once it also sits in a pendant.
    var crestEarned = false
    var bondPoints = 0
    var startedAt = Date()

    var id: String { line }
    var isEgg: Bool { stage < 0 }
    var crestLit: Bool { crestEarned && hasPendant }
    var bondLevel: Int { bondPoints / TamerBalance.bondPointsPerLevel }
    var form: FormRef? { isEgg ? nil : FormRef(line: line, stage: stage) }
}

/// Something the popover should play: the change itself is already saved.
enum TamerEvent: Codable, Equatable, Sendable {
    case hatch(line: String)
    case evolve(line: String, from: Int, to: Int)
    case crestLit(line: String)
}

/// Everything persisted in `tamer-state.json`.
struct TamerState: Codable, Equatable, Sendable {
    var version = 1
    var partners: [PartnerState] = []
    var activeLine: String?
    var ledger = TokenLedger()
    /// Every credited token since install. Wallet = this − `spentTokens`.
    var usedSinceInstall = 0
    var spentTokens = 0
    var meat = 0
    /// Forms seen at least once ("line:stage").
    var notebook: Set<String> = []
    /// Lines whose crest has shone — the notebook emblem takes the crest colour.
    var litCrests: Set<String> = []
    /// Menu bar form chosen in Settings/notebook; nil follows the active partner.
    var displayForm: FormRef?
    var pendingEvents: [TamerEvent] = []
    /// Digitama bought in the shop and waiting in the bag until the user starts raising them.
    var bagEggs: [String] = []

    var active: PartnerState? {
        get { partners.first { $0.line == activeLine } }
        set {
            guard let newValue, let index = partners.firstIndex(where: { $0.line == newValue.line }) else { return }
            partners[index] = newValue
        }
    }

    var wallet: Int { max(0, usedSinceInstall - spentTokens) }

    func hasStarted(_ line: String) -> Bool { partners.contains { $0.line == line } }
    /// Started, or bought and waiting in the bag: the shop shows "구매 완료".
    func ownsEgg(_ line: String) -> Bool { hasStarted(line) || bagEggs.contains(line) }
    func isRegistered(_ form: FormRef) -> Bool { notebook.contains(form.key) }
}

extension TamerState {
    /// Every field is optional on read, so a save from an earlier version (without newer fields
    /// such as `bagEggs`) still opens instead of being set aside as unreadable.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        version = try c.decodeIfPresent(Int.self, forKey: .version) ?? version
        partners = try c.decodeIfPresent([PartnerState].self, forKey: .partners) ?? []
        activeLine = try c.decodeIfPresent(String.self, forKey: .activeLine)
        ledger = try c.decodeIfPresent(TokenLedger.self, forKey: .ledger) ?? TokenLedger()
        usedSinceInstall = try c.decodeIfPresent(Int.self, forKey: .usedSinceInstall) ?? 0
        spentTokens = try c.decodeIfPresent(Int.self, forKey: .spentTokens) ?? 0
        meat = try c.decodeIfPresent(Int.self, forKey: .meat) ?? 0
        notebook = try c.decodeIfPresent(Set<String>.self, forKey: .notebook) ?? []
        litCrests = try c.decodeIfPresent(Set<String>.self, forKey: .litCrests) ?? []
        displayForm = try c.decodeIfPresent(FormRef.self, forKey: .displayForm)
        pendingEvents = try c.decodeIfPresent([TamerEvent].self, forKey: .pendingEvents) ?? []
        bagEggs = try c.decodeIfPresent([String].self, forKey: .bagEggs) ?? []
    }
}

/// One check in the card's condition row ("성숙기까지 ✓ 진화 게이지 100% · 디지바이스").
struct EvolutionCheck: Equatable, Sendable {
    enum Kind: Equatable, Sendable { case gauge, digivice, pendant, crest, bond }
    let kind: Kind
    let met: Bool
}
