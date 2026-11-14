import Foundation

/// Every number of the growth economy lives here.
///
/// docs/DESIGN.md §2.5 and §6 leave prices, gauge sizes and the crest trial values open
/// ("PokeTokenBar 코드를 분석한 뒤 정한다"). These are first-pass values derived from the
/// DigiMonTokenBar balance — measured average ≈253M tokens/day, a common line graduating at
/// 750M, a 5M egg and a 100M digivice — and are meant to be tuned in this one file.
///
/// Tokens play two roles, as upstream: each one grows the active partner *and* adds to the
/// shop wallet (`usedSinceInstall − spentTokens`). Upstream's lesson applies: an item must cost
/// more than the growth it gives, or buying it is free extra growth.
enum TamerBalance {
    // MARK: Gauge

    /// Tokens to hatch a digitama. Overflow carries into In-Training I.
    static let eggHatch = 5_000_000

    /// Tokens to fill the gauge at each stage (index = stage). The last entry is the Mega gauge,
    /// which turns into one bond level each time it fills (DESIGN §2.2 "궁극체 이후").
    /// Sum egg → Mega ≈ 650M, close to upstream's 750M common line.
    static let stageGauge = [15_000_000, 30_000_000, 100_000_000, 200_000_000, 300_000_000, 300_000_000]

    static func gauge(stage: Int) -> Int {
        if stage < 0 { return eggHatch }
        return stageGauge[min(max(stage, 0), stageGauge.count - 1)]
    }

    /// Stages whose next step needs the user to press "!" (and possibly an item).
    /// In-Training I/II evolve on their own when the gauge fills (DESIGN §2.2).
    static func isGated(stage: Int) -> Bool { stage >= 2 && stage <= 4 }

    // MARK: Crest trial (DESIGN §2.4 — same for all eight lines)

    /// "성숙기로 7일 함께하기": days with any token use while the partner is a Champion.
    static let crestTrialDays = 7

    // MARK: Bond (DESIGN §2.2 완전체 → 궁극체)

    static let bondPointsPerLevel = 100
    static let bondLevelForMega = 5

    // MARK: Shop (DESIGN §2.5)

    static let meatPrice = 10_000_000
    /// Meat fills the gauge a little (half its price, see the note above) and raises bond.
    static let meatGauge = 5_000_000
    static let meatBond = 50
    static let digivicePrice = 100_000_000
    /// The most expensive item, as the design asks.
    static let pendantPrice = 300_000_000
    static let digitamaPrice = 200_000_000

    /// Upper bound for any stored token value, so hand-edited saves cannot overflow `Int`.
    static let maxTokenValue = 1_000_000_000_000_000
}
