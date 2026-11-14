import Foundation
import Testing
@testable import DigimonTokenTamer

@MainActor
private func makeStore(_ name: String = UUID().uuidString) -> TamerStore {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent("tamer-tests-\(name)", isDirectory: true)
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let defaults = UserDefaults(suiteName: "tamer-tests-\(name)")!
    return TamerStore(fileURL: dir.appendingPathComponent("state.json"), defaults: defaults)
}

@MainActor
private func hatchedStore(_ line: String = "agumon") -> TamerStore {
    let store = makeStore()
    store.chooseFirstEgg(line)
    store.credit(TamerBalance.eggHatch, date: "2026-11-14")
    return store
}

/// Fills the active partner's gauge exactly once.
@MainActor
private func fill(_ store: TamerStore, date: String = "2026-11-14") {
    guard let partner = store.active else { return }
    store.credit(store.gaugeSize(for: partner), date: date)
}

/// A hatched partner raised to a full Rookie gauge, with `wallet` tokens to spend.
@MainActor
private func rookieStore(wallet: Int = 2_000_000_000) -> TamerStore {
    let store = hatchedStore()
    fill(store); fill(store); fill(store)
    store.credit(wallet, date: "2026-11-14")
    return store
}

@Suite("TokenLedger")
struct TokenLedgerTests {
    @Test func firstReadingIsBaselineOnly() {
        var ledger = TokenLedger()
        #expect(ledger.observe(today: ["claude_code": 500], date: "d1", hasUsageData: true) == 0)
        #expect(ledger.observe(today: ["claude_code": 800], date: "d1", hasUsageData: true) == 300)
    }

    @Test func emptyRefreshDoesNotMoveTheLedger() {
        var ledger = TokenLedger()
        _ = ledger.observe(today: ["codex": 100], date: "d1", hasUsageData: true)
        #expect(ledger.observe(today: [:], date: "d2", hasUsageData: true) == 0)
        #expect(ledger.observe(today: ["codex": 90], date: "d1", hasUsageData: false) == 0)
        #expect(ledger.observe(today: ["codex": 150], date: "d1", hasUsageData: true) == 50)
    }

    @Test func newProviderIsSeededNotBackPaid() {
        var ledger = TokenLedger()
        _ = ledger.observe(today: ["claude_code": 100], date: "d1", hasUsageData: true)
        #expect(ledger.observe(today: ["claude_code": 100, "codex": 9_000], date: "d1", hasUsageData: true) == 0)
        #expect(ledger.observe(today: ["claude_code": 100, "codex": 9_500], date: "d1", hasUsageData: true) == 500)
    }

    @Test func regressionRebasesOnlyThatProvider() {
        var ledger = TokenLedger()
        _ = ledger.observe(today: ["a": 1_000, "b": 1_000], date: "d1", hasUsageData: true)
        #expect(ledger.observe(today: ["a": 400, "b": 1_200], date: "d1", hasUsageData: true) == 200)
        #expect(ledger.observe(today: ["a": 500, "b": 1_200], date: "d1", hasUsageData: true) == 100)
    }

    @Test func newDayCountsTheWholeDayAndLateProvidersInFull() {
        var ledger = TokenLedger()
        _ = ledger.observe(today: ["a": 1_000, "b": 1_000], date: "d1", hasUsageData: true)
        #expect(ledger.observe(today: ["a": 300], date: "d2", hasUsageData: true) == 300)
        // b was known yesterday: its first reading today counts from zero.
        #expect(ledger.observe(today: ["a": 300, "b": 50], date: "d2", hasUsageData: true) == 50)
    }
}

@Suite("Growth") @MainActor
struct GrowthTests {
    @Test func firstEggIsFreeAndOnlyOnce() {
        let store = makeStore()
        #expect(store.chooseFirstEgg("gabumon"))
        #expect(store.active?.isEgg == true)
        #expect(!store.chooseFirstEgg("agumon"))
    }

    @Test func eggHatchesIntoInTrainingIAndRegisters() {
        let store = hatchedStore()
        #expect(store.active?.stage == 0)
        #expect(store.state.isRegistered(FormRef(line: "agumon", stage: 0)))
        #expect(store.currentEvent == .hatch(line: "agumon"))
    }

    @Test func inTrainingStagesEvolveOnTheirOwnAndRestartAtZero() {
        let store = hatchedStore()
        #expect(store.active?.gauge == 0)
        // A huge credit still makes one step only; the gauge restarts at 0, nothing carries over.
        store.credit(999_000_000, date: "2026-11-14")
        #expect(store.active?.stage == 1)
        #expect(store.active?.gauge == 0)
        fill(store)
        #expect(store.active?.stage == 2)
        #expect(store.active?.gauge == 0)
        store.credit(999_000_000, date: "2026-11-14")
        // A gated stage stops at a full gauge.
        #expect(store.active?.stage == 2)
        #expect(store.active?.gauge == store.threshold(stage: 2))
        #expect(!store.canEvolve)   // no digivice yet
    }

    @Test func rookieNeedsDigivice() {
        let store = rookieStore()
        #expect(store.status(.digivice) == .available)
        #expect(store.status(.pendant) == .locked(.fromChampion))
        #expect(store.buy(.digivice))
        #expect(store.status(.digivice) == .purchased)
        #expect(!store.buy(.digivice))
        #expect(store.canEvolve)
        #expect(store.evolve())
        #expect(store.active?.stage == 3)
        #expect(store.active?.gauge == 0)
        #expect(store.status(.digivice) == .purchased)
        #expect(store.status(.pendant) == .available)
    }

    @Test func championNeedsPendantAndShiningCrest() {
        let store = rookieStore()
        store.buy(.digivice)
        store.evolve()
        fill(store, date: "2026-11-01")
        #expect(store.active?.crestDays == 1)
        #expect(!store.canEvolve)
        // Trial progress accrues without a pendant.
        for day in 2...TamerBalance.crestTrialDays {
            store.credit(1, date: String(format: "2026-11-%02d", day))
        }
        #expect(store.active?.crestEarned == true)
        #expect(store.active?.crestLit == false)
        #expect(!store.state.litCrests.contains("agumon"))
        #expect(store.status(.pendant) == .available)
        #expect(store.buy(.pendant))
        #expect(store.status(.pendant) == .purchased)
        #expect(store.active?.crestLit == true)
        #expect(store.state.litCrests.contains("agumon"))
        #expect(store.state.pendingEvents.contains(.crestLit(line: "agumon")))
        #expect(store.canEvolve)
        #expect(store.evolve())
        #expect(store.active?.stage == 4)
        #expect(store.active?.gauge == 0)
    }

    @Test func sameDayCountsOnceForTheTrial() {
        let store = rookieStore()
        store.buy(.digivice)
        store.evolve()
        store.credit(10, date: "d2")
        store.credit(10, date: "d2")
        #expect(store.active?.crestDays == 1)
    }

    @Test func ultimateNeedsBondFromMeat() {
        let store = rookieStore(wallet: 5_000_000_000)
        store.buy(.digivice); store.evolve()
        store.buy(.pendant)
        for day in 1...TamerBalance.crestTrialDays { fill(store, date: "x\(day)") }
        #expect(store.evolve())
        fill(store, date: "y1")
        #expect(!store.canEvolve)
        let meals = TamerBalance.bondLevelForMega * TamerBalance.bondPointsPerLevel / TamerBalance.meatBond
        for _ in 0..<meals { #expect(store.buy(.meat)) }
        for _ in 0..<meals { #expect(store.feedMeat()) }
        #expect(store.active?.bondLevel == TamerBalance.bondLevelForMega)
        #expect(store.canEvolve)
        #expect(store.evolve())
        #expect(store.active?.stage == 5)
        // At Mega, each full gauge becomes one bond level and the gauge restarts at 0.
        let before = store.active?.bondLevel ?? 0
        fill(store, date: "y2")
        fill(store, date: "y2")
        #expect(store.active?.bondLevel == before + 2)
        #expect(store.active?.gauge == 0)
        #expect(!store.canEvolve)
    }

    @Test func walletIsUsageMinusSpending() {
        let store = hatchedStore()
        store.credit(TamerBalance.meatPrice, date: "d1")
        let wallet = store.wallet
        #expect(store.buy(.meat))
        #expect(store.wallet == wallet - TamerBalance.meatPrice)
        #expect(store.state.meat == 1)
    }

    @Test func shopListsEverythingAndMarksOwnedEggs() {
        let fresh = makeStore()
        #expect(fresh.shopItems.count == 3 + 8)
        #expect(fresh.status(.digitama(line: "agumon")) == .locked(.firstEggFree))
        #expect(fresh.status(.meat) == .locked(.firstEggFree))
        fresh.chooseFirstEgg("agumon")
        #expect(fresh.status(.meat) == .locked(.needsHatch))
        // The chosen first egg stays listed, marked as purchased.
        #expect(fresh.status(.digitama(line: "agumon")) == .purchased)
        #expect(fresh.status(.digitama(line: "tailmon")) == .available)
    }

    @Test func boughtEggWaitsInBagUntilRaised() {
        let store = hatchedStore("agumon")
        store.credit(TamerBalance.digitamaPrice, date: "d1")
        #expect(store.buy(.digitama(line: "tailmon")))
        #expect(store.state.bagEggs == ["tailmon"])
        #expect(store.state.activeLine == "agumon")
        #expect(store.status(.digitama(line: "tailmon")) == .purchased)
        #expect(!store.buy(.digitama(line: "tailmon")))
        #expect(store.startEgg("tailmon"))
        #expect(store.state.bagEggs.isEmpty)
        #expect(store.state.activeLine == "tailmon")
        #expect(store.storedPartners.map(\.line) == ["agumon"])
        // Stored partners do not grow.
        let stored = store.state.partners.first { $0.line == "agumon" }!
        store.credit(1_000_000, date: "d1")
        #expect(store.state.partners.first { $0.line == "agumon" } == stored)
    }

    @Test func savesWithoutNewerFieldsStillOpen() throws {
        // The shape written by 0.1.0, before the bag existed.
        let old = #"{"spentTokens":0,"ledger":{"lastDate":"2026-11-14","claimed":{"codex":7515820},"baselineSet":true},"activeLine":"agumon","meat":0,"pendingEvents":[],"version":1,"usedSinceInstall":17266038,"partners":[{"crestEarned":false,"startedAt":816348464.4,"stage":-1,"line":"agumon","crestDays":0,"hasPendant":false,"hasDigivice":false,"gauge":1068737,"bondPoints":0}],"notebook":[],"litCrests":[]}"#
        let state = try JSONDecoder().decode(TamerState.self, from: Data(old.utf8))
        #expect(state.activeLine == "agumon")
        #expect(state.active?.gauge == 1_068_737)
        #expect(state.bagEggs.isEmpty)
        #expect(state.ledger.lastDate == "2026-11-14")
    }

    @Test func displayFormMustBeRegistered() {
        let store = hatchedStore()
        store.setDisplayForm(FormRef(line: "agumon", stage: 5))
        #expect(store.state.displayForm == nil)
        store.setDisplayForm(FormRef(line: "agumon", stage: 0))
        #expect(store.menuSubject == .form(FormRef(line: "agumon", stage: 0)))
    }

    @Test func stateSurvivesReload() {
        let name = UUID().uuidString
        let store = makeStore(name)
        store.chooseFirstEgg("palmon")
        store.credit(TamerBalance.eggHatch + 1_000, date: "d1")
        let reloaded = makeStore(name)
        #expect(reloaded.state == store.state)
    }

    @Test func growthDifficultyScalesGaugeAndKeepsProgress() {
        let store = hatchedStore()
        store.credit(store.threshold(stage: 0) / 2, date: "d1")   // half full
        store.setGrowthDifficulty(2.0)
        #expect(store.threshold(stage: 0) == TamerBalance.gauge(stage: 0) * 2)
        #expect(abs(store.gaugeFraction(for: store.active!) - 0.5) < 0.01)
        #expect(store.active?.stage == 0)   // changing the setting never evolves
        store.setGrowthDifficulty(0.1)
        #expect(store.active?.stage == 0)
        #expect(store.active!.gauge < store.threshold(stage: 0))
    }

    @Test func shopDifficultyScalesPricesOnly() {
        let store = hatchedStore()
        let wallet = store.wallet
        store.setShopDifficulty(1.5)
        #expect(store.price(.meat) == TamerBalance.meatPrice * 3 / 2)
        #expect(store.wallet == wallet)
        #expect(TamerDifficulty.clamp(9) == TamerDifficulty.range.upperBound)
        #expect(TamerDifficulty.value(atPosition: TamerDifficulty.position(1.0)) == 1.0)
    }

    @Test func catalogHasEightLinesOfSixStages() {
        let catalog = TamerCatalog.shared
        #expect(catalog.lines.count == 8)
        #expect(catalog.lines.allSatisfy { $0.stages.count == TamerCatalog.stageCount })
        #expect(catalog.line("tailmon")?.stages.last?.name == "Holydramon")
        #expect(Set(catalog.lines.map(\.crest.key)).count == 8)
    }
}

@Suite("Catalog source")
struct CatalogSourceTests {
    /// `TamerCatalogData.swift` is generated from catalog.json; editing one without re-running
    /// scripts/gen-catalog.sh must fail here.
    @Test func embeddedCatalogMatchesJSONFile() throws {
        let file = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/DigimonTokenTamer/Resources/Tamer/catalog.json")
        let onDisk = try String(contentsOf: file, encoding: .utf8)
        #expect(onDisk.trimmingCharacters(in: .newlines) == TamerCatalogData.json)
    }
}

@Suite("Motions")
struct MotionTests {
    @Test func everyMoodLoopsAndActionsCarryTheirIcons() {
        for mood in [PartnerMood.egg, .idle, .walking, .busy, .sleeping, .ready] {
            #expect(!MotionScript.loop(mood).isEmpty)
        }
        // The ready loop always carries the "!" and stays in place (no walking away from it).
        let readyFrames = MotionScript.loop(.ready)
        let readyAlwaysBadged = readyFrames.allSatisfy { $0.overlays.contains { $0.item == .icon(.exclamation) } }
        let readyInPlace = readyFrames.allSatisfy { $0.dx == 0 }
        let readyJumps = readyFrames.contains { $0.dy <= -5 }
        #expect(readyAlwaysBadged && readyInPlace && readyJumps)
        let annoyed = MotionScript.once(.annoyed).flatMap(\.overlays).map(\.item)
        #expect(annoyed.contains(.icon(.anger)))
        let pet = MotionScript.once(.pet).flatMap(\.overlays).map(\.item)
        #expect(pet.contains(.icon(.heart)))
        let eat = MotionScript.once(.eat).flatMap(\.overlays).map(\.item)
        #expect(eat.contains(.meat(bites: 0)) && eat.contains(.meat(bites: 9)))
        let sleepingDimmed = MotionScript.loop(.sleeping).allSatisfy(\.dim)
        #expect(sleepingDimmed)
        // The walk stays inside the range it is given.
        let walkInRange = MotionScript.loop(.walking, walkRange: 5).allSatisfy { abs($0.dx) <= 5 }
        #expect(walkInRange)
    }

    @Test @MainActor func pettingTooOftenAnnoys() {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("tamer-pet-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let store = TamerStore(fileURL: dir.appendingPathComponent("s.json"), defaults: UserDefaults(suiteName: dir.lastPathComponent)!)
        let start = Date()
        for i in 0..<(TamerStore.petLimit - 1) {
            store.pet(now: start.addingTimeInterval(Double(i)))
            #expect(store.action == .pet)
        }
        store.pet(now: start.addingTimeInterval(Double(TamerStore.petLimit - 1)))
        #expect(store.action == .annoyed)
        // After a pause, petting is welcome again.
        store.pet(now: start.addingTimeInterval(60))
        #expect(store.action == .pet)
    }

    @Test @MainActor func feedingAndBuyingStartMotions() {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("tamer-motion-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let store = TamerStore(fileURL: dir.appendingPathComponent("s.json"), defaults: UserDefaults(suiteName: dir.lastPathComponent)!)
        store.chooseFirstEgg("agumon")
        store.credit(TamerBalance.eggHatch + TamerBalance.meatPrice, date: "d1")
        store.buy(.meat)
        let before = store.actionID
        #expect(store.feedMeat())
        #expect(store.action == .eat)
        #expect(store.actionID == before + 1)
    }
}
