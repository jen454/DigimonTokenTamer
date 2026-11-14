import Foundation
import Observation

/// What the menu bar shows: nothing yet, a digitama, or one notebook form.
enum MenuSubject: Equatable, Sendable {
    case none
    case egg(line: String)
    case form(FormRef)
}

/// Shop entries (DESIGN §2.5). Crests are never sold — they shine through the trial.
enum ShopItem: Hashable, Sendable, Identifiable {
    case meat
    case digivice
    case pendant
    case digitama(line: String)

    var id: String {
        switch self {
        case .meat: return "meat"
        case .digivice: return "digivice"
        case .pendant: return "pendant"
        case .digitama(let line): return "digitama-\(line)"
        }
    }
}

/// The growth game: one active partner fed by token usage, the shop, the notebook.
///
/// `AppDelegate` calls `update(...)` after each usage refresh. Every change is saved before the
/// popover plays its scene, so quitting mid-animation never loses an evolution.
@MainActor
@Observable
final class TamerStore {
    private(set) var state: TamerState
    let catalog: TamerCatalog
    private(set) var language: AppLanguage

    /// Posts a user notification (title, body). Wired by `AppDelegate`; nil in tests.
    @ObservationIgnored var onNotify: ((String, String) -> Void)?

    @ObservationIgnored private let fileURL: URL
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var wasReady = false

    static let languageKey = "tamerLanguage"

    init(fileURL: URL? = nil, defaults: UserDefaults = .standard, catalog: TamerCatalog = .shared) {
        self.fileURL = fileURL ?? AppStatePaths.directory().appendingPathComponent("tamer-state.json")
        self.defaults = defaults
        self.catalog = catalog
        language = defaults.string(forKey: Self.languageKey).flatMap(AppLanguage.init(rawValue:)) ?? .ko
        state = Self.load(from: self.fileURL)
        wasReady = canEvolve
    }

    var text: TamerText { TamerText(language) }
    var l: L { L(language) }

    func setLanguage(_ language: AppLanguage) {
        self.language = language
        defaults.set(language.rawValue, forKey: Self.languageKey)
    }

    // MARK: Derived

    var active: PartnerState? { state.active }
    var activeLine: TamerCatalog.Line? { state.activeLine.flatMap(catalog.line) }
    var wallet: Int { state.wallet }
    var hasChosenFirstEgg: Bool { !state.partners.isEmpty }
    var storedPartners: [PartnerState] { state.partners.filter { $0.line != state.activeLine } }

    func gaugeSize(for partner: PartnerState) -> Int { TamerBalance.gauge(stage: partner.stage) }

    func gaugeFraction(for partner: PartnerState) -> Double {
        let size = gaugeSize(for: partner)
        return size > 0 ? min(1, Double(partner.gauge) / Double(size)) : 0
    }

    /// The checks between the active partner and its next stage. Empty for the egg and Mega.
    func checks(for partner: PartnerState) -> [EvolutionCheck] {
        guard !partner.isEgg, partner.stage < TamerCatalog.stageCount - 1 else { return [] }
        let gauge = EvolutionCheck(kind: .gauge, met: partner.gauge >= gaugeSize(for: partner))
        switch partner.stage {
        case 2: return [gauge, EvolutionCheck(kind: .digivice, met: partner.hasDigivice)]
        case 3: return [gauge, EvolutionCheck(kind: .pendant, met: partner.hasPendant),
                        EvolutionCheck(kind: .crest, met: partner.crestEarned)]
        case 4: return [gauge, EvolutionCheck(kind: .bond, met: partner.bondLevel >= TamerBalance.bondLevelForMega)]
        default: return [gauge]
        }
    }

    /// "!" — every condition of a gated step is met (DESIGN §2.3).
    var canEvolve: Bool {
        guard let partner = state.active, TamerBalance.isGated(stage: partner.stage) else { return false }
        return checks(for: partner).allSatisfy(\.met)
    }

    var menuSubject: MenuSubject {
        if let form = state.displayForm, state.isRegistered(form) { return .form(form) }
        guard let partner = state.active else { return .none }
        return partner.isEgg ? .egg(line: partner.line) : .form(FormRef(line: partner.line, stage: partner.stage))
    }

    var currentEvent: TamerEvent? { state.pendingEvents.first }

    // MARK: Usage

    /// Credits new usage from one refresh. Same inputs as upstream `CompanionStore.update`.
    func update(todayTokensByProvider: [String: Int], todayDate: String, hasUsageData: Bool) {
        let delta = state.ledger.observe(today: todayTokensByProvider, date: todayDate, hasUsageData: hasUsageData)
        guard delta > 0 else {
            save()   // the ledger may have seeded a provider or opened a new day
            return
        }
        credit(delta, date: todayDate)
    }

    /// Adds `tokens` to the wallet and grows the active partner. Internal for tests.
    func credit(_ tokens: Int, date: String) {
        guard tokens > 0 else { return }
        state.usedSinceInstall = min(state.usedSinceInstall + tokens, TamerBalance.maxTokenValue)
        if var partner = state.active {
            countCrestDay(&partner, date: date)
            state.active = partner
            grow(tokens)
        }
        commit()
    }

    private func countCrestDay(_ partner: inout PartnerState, date: String) {
        guard partner.stage == 3, partner.crestLastDay != date else { return }
        partner.crestLastDay = date
        partner.crestDays = min(partner.crestDays + 1, TamerBalance.crestTrialDays)
        if partner.crestDays >= TamerBalance.crestTrialDays, !partner.crestEarned {
            partner.crestEarned = true
            if partner.hasPendant { crestLit(partner.line) }
        }
    }

    /// Puts tokens into the active partner's gauge and runs every automatic step:
    /// hatching, In-Training I → II → Rookie, and Mega's gauge turning into bond levels.
    /// Gated stages stop at a full gauge; the rest waits for "!".
    private func grow(_ tokens: Int) {
        guard var partner = state.active else { return }
        partner.gauge = min(partner.gauge + tokens, TamerBalance.maxTokenValue)
        var steps = 0
        while steps < 16 {
            steps += 1
            let need = TamerBalance.gauge(stage: partner.stage)
            if partner.stage == TamerCatalog.stageCount - 1 {
                let levels = partner.gauge / need
                partner.bondPoints += levels * TamerBalance.bondPointsPerLevel
                partner.gauge -= levels * need
                break
            }
            if TamerBalance.isGated(stage: partner.stage) {
                partner.gauge = min(partner.gauge, need)
                break
            }
            guard partner.gauge >= need else { break }
            partner.gauge -= need
            let from = partner.stage
            partner.stage += 1
            register(FormRef(line: partner.line, stage: partner.stage))
            if from < 0 {
                enqueue(.hatch(line: partner.line))
                notify(text.notifyHatchTitle, text.notifyHatchBody(name(of: partner)))
            } else {
                enqueue(.evolve(line: partner.line, from: from, to: partner.stage))
                notify(text.notifyEvolvedTitle, text.notifyEvolvedBody(name(of: partner)))
            }
        }
        state.active = partner
    }

    // MARK: Actions

    /// The first digitama is free: the user picks one of the eight (DESIGN §2.1).
    @discardableResult
    func chooseFirstEgg(_ line: String) -> Bool {
        guard state.partners.isEmpty, catalog.line(line) != nil else { return false }
        state.partners.append(PartnerState(line: line))
        state.activeLine = line
        commit()
        return true
    }

    /// Manual evolution, started from the "!" (DESIGN §2.3). Items stay with the partner:
    /// the digivice and the shining pendant are its equipment.
    @discardableResult
    func evolve() -> Bool {
        guard canEvolve, var partner = state.active else { return false }
        let from = partner.stage
        partner.stage += 1
        partner.gauge = 0
        state.active = partner
        register(FormRef(line: partner.line, stage: partner.stage))
        enqueue(.evolve(line: partner.line, from: from, to: partner.stage))
        commit()
        return true
    }

    @discardableResult
    func feedMeat() -> Bool {
        guard state.meat > 0, var partner = state.active, !partner.isEgg else { return false }
        state.meat -= 1
        partner.bondPoints += TamerBalance.meatBond
        state.active = partner
        grow(TamerBalance.meatGauge)
        commit()
        return true
    }

    func switchPartner(to line: String) {
        guard state.hasStarted(line), state.activeLine != line else { return }
        state.activeLine = line
        commit()
    }

    func setDisplayForm(_ form: FormRef?) {
        if let form, !state.isRegistered(form) { return }
        state.displayForm = form
        save()
    }

    func consumeEvent() {
        guard !state.pendingEvents.isEmpty else { return }
        state.pendingEvents.removeFirst()
        save()
    }

    // MARK: Shop

    var shopItems: [ShopItem] {
        guard let partner = state.active else { return [] }
        var items: [ShopItem] = []
        if !partner.isEgg { items.append(.meat) }
        if (0...2).contains(partner.stage), !partner.hasDigivice { items.append(.digivice) }
        if partner.stage == 3, !partner.hasPendant { items.append(.pendant) }
        items += catalog.lines.filter { !state.hasStarted($0.key) }.map { .digitama(line: $0.key) }
        return items
    }

    func price(_ item: ShopItem) -> Int {
        switch item {
        case .meat: return TamerBalance.meatPrice
        case .digivice: return TamerBalance.digivicePrice
        case .pendant: return TamerBalance.pendantPrice
        case .digitama: return TamerBalance.digitamaPrice
        }
    }

    func canBuy(_ item: ShopItem) -> Bool {
        shopItems.contains(item) && wallet >= price(item)
    }

    @discardableResult
    func buy(_ item: ShopItem) -> Bool {
        guard canBuy(item) else { return false }
        state.spentTokens += price(item)
        switch item {
        case .meat:
            state.meat += 1
        case .digivice:
            state.active?.hasDigivice = true
        case .pendant:
            state.active?.hasPendant = true
            if let partner = state.active, partner.crestEarned { crestLit(partner.line) }
        case .digitama(let line):
            // The new egg takes the active slot; the current partner waits in storage.
            state.partners.append(PartnerState(line: line))
            state.activeLine = line
        }
        commit()
        return true
    }

    // MARK: Helpers

    func name(of partner: PartnerState) -> String {
        guard let line = catalog.line(partner.line) else { return partner.line }
        return partner.isEgg ? text.digitama : line.stages[partner.stage].name
    }

    private func register(_ form: FormRef) {
        state.notebook.insert(form.key)
    }

    private func crestLit(_ line: String) {
        state.litCrests.insert(line)
        enqueue(.crestLit(line: line))
        if let crest = catalog.line(line)?.crest {
            notify(text.crestLitTitle(crest.ko, en: crest.en), text.crestLitSubtitle)
        }
    }

    private func enqueue(_ event: TamerEvent) {
        state.pendingEvents.append(event)
        // A long absence can queue many steps; the newest ones are the ones worth watching.
        if state.pendingEvents.count > 4 { state.pendingEvents.removeFirst(state.pendingEvents.count - 4) }
    }

    private func notify(_ title: String, _ body: String) {
        onNotify?(title, body)
    }

    /// Saves and announces a newly reachable "!" once per transition.
    private func commit() {
        let ready = canEvolve
        if ready, !wasReady, let partner = state.active {
            notify(text.notifyReadyTitle, text.notifyReadyBody(name(of: partner)))
        }
        wasReady = ready
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    /// A save that does not decode is kept aside, never overwritten: the app starts fresh and the
    /// old file stays recoverable next to the new one.
    private static func load(from url: URL) -> TamerState {
        guard let data = try? Data(contentsOf: url) else { return TamerState() }
        if let state = try? JSONDecoder().decode(TamerState.self, from: data) { return state }
        let aside = url.deletingPathExtension()
            .appendingPathExtension("corrupt-\(Int(Date().timeIntervalSince1970)).json")
        try? FileManager.default.moveItem(at: url, to: aside)
        AppLog.write("tamer state unreadable — moved to \(aside.lastPathComponent)")
        return TamerState()
    }
}
