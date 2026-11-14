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

    @Test func inTrainingStagesEvolveOnTheirOwnAndRookieWaits() {
        let store = hatchedStore()
        store.credit(TamerBalance.gauge(stage: 0) + TamerBalance.gauge(stage: 1) + 999_000_000, date: "2026-11-14")
        #expect(store.active?.stage == 2)
        // A gated stage stops at a full gauge; overflow is not banked.
        #expect(store.active?.gauge == TamerBalance.gauge(stage: 2))
        #expect(!store.canEvolve)   // no digivice yet
    }

    @Test func rookieNeedsDigivice() {
        let store = hatchedStore()
        store.credit(2_000_000_000, date: "2026-11-14")
        #expect(store.shopItems.contains(.digivice))
        #expect(store.buy(.digivice))
        #expect(store.canEvolve)
        #expect(store.evolve())
        #expect(store.active?.stage == 3)
        #expect(store.active?.gauge == 0)
        #expect(!store.shopItems.contains(.digivice))
    }

    @Test func championNeedsPendantAndShiningCrest() {
        let store = hatchedStore()
        store.credit(2_000_000_000, date: "2026-11-01")
        store.buy(.digivice)
        store.evolve()
        store.credit(TamerBalance.gauge(stage: 3), date: "2026-11-01")
        #expect(store.active?.crestDays == 1)
        #expect(!store.canEvolve)
        // Trial progress accrues without a pendant.
        for day in 2...TamerBalance.crestTrialDays {
            store.credit(1, date: String(format: "2026-11-%02d", day))
        }
        #expect(store.active?.crestEarned == true)
        #expect(store.active?.crestLit == false)
        #expect(!store.state.litCrests.contains("agumon"))
        #expect(store.shopItems.contains(.pendant))
        #expect(store.buy(.pendant))
        #expect(store.active?.crestLit == true)
        #expect(store.state.litCrests.contains("agumon"))
        #expect(store.state.pendingEvents.contains(.crestLit(line: "agumon")))
        #expect(store.canEvolve)
        #expect(store.evolve())
        #expect(store.active?.stage == 4)
    }

    @Test func sameDayCountsOnceForTheTrial() {
        let store = hatchedStore()
        store.credit(2_000_000_000, date: "d1")
        store.buy(.digivice)
        store.evolve()
        store.credit(10, date: "d2")
        store.credit(10, date: "d2")
        #expect(store.active?.crestDays == 1)
    }

    @Test func ultimateNeedsBondFromMeat() {
        let store = hatchedStore()
        store.credit(5_000_000_000, date: "d1")
        store.buy(.digivice); store.evolve()
        store.buy(.pendant)
        for day in 1...TamerBalance.crestTrialDays { store.credit(TamerBalance.gauge(stage: 3), date: "x\(day)") }
        #expect(store.evolve())
        store.credit(TamerBalance.gauge(stage: 4), date: "y1")
        #expect(!store.canEvolve)
        let meals = TamerBalance.bondLevelForMega * TamerBalance.bondPointsPerLevel / TamerBalance.meatBond
        for _ in 0..<meals { #expect(store.buy(.meat)) }
        for _ in 0..<meals { #expect(store.feedMeat()) }
        #expect(store.active?.bondLevel == TamerBalance.bondLevelForMega)
        #expect(store.canEvolve)
        #expect(store.evolve())
        #expect(store.active?.stage == 5)
        // At Mega, each full gauge becomes one bond level.
        let before = store.active?.bondLevel ?? 0
        store.credit(TamerBalance.gauge(stage: 5) * 2, date: "y2")
        #expect(store.active?.bondLevel == before + 2)
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

    @Test func shopSellsOnlyUnstartedEggsAndSwitchesActive() {
        let store = hatchedStore("agumon")
        #expect(!store.shopItems.contains(.digitama(line: "agumon")))
        #expect(store.shopItems.contains(.digitama(line: "tailmon")))
        store.credit(TamerBalance.digitamaPrice, date: "d1")
        #expect(store.buy(.digitama(line: "tailmon")))
        #expect(store.state.activeLine == "tailmon")
        #expect(store.storedPartners.map(\.line) == ["agumon"])
        // Stored partners do not grow.
        let stored = store.state.partners.first { $0.line == "agumon" }!
        store.credit(1_000_000, date: "d1")
        #expect(store.state.partners.first { $0.line == "agumon" } == stored)
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

    @Test func catalogHasEightLinesOfSixStages() {
        let catalog = TamerCatalog.shared
        #expect(catalog.lines.count == 8)
        #expect(catalog.lines.allSatisfy { $0.stages.count == TamerCatalog.stageCount })
        #expect(catalog.line("tailmon")?.stages.last?.name == "Holydramon")
        #expect(Set(catalog.lines.map(\.crest.key)).count == 8)
    }
}
