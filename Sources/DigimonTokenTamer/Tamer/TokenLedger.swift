import Foundation

/// Turns repeated "today so far" readings into new tokens to credit, once each.
///
/// Ported from DigiMonTokenBar's `CompanionStore.update` (per-provider high-water marks). The
/// rules it keeps:
/// - Usage before the first real reading is the install baseline, never credited.
/// - Each provider is tracked on its own line, so a provider missing from one refresh (no data
///   today, a failed parse) neither moves nor resets the others.
/// - A provider seen for the first time on a day is seeded, not back-paid.
/// - A provider whose total drops (rotated or pruned logs) is rebased, not debited.
/// - On a new day the previous day's numbers are not comparable, so the whole new-day total
///   counts; known providers open the day at zero so a late reading still counts in full.
struct TokenLedger: Codable, Equatable, Sendable {
    private(set) var baselineSet = false
    private(set) var lastDate: String?
    private(set) var claimed: [String: Int] = [:]

    /// Records one refresh and returns the tokens that are new since the last one.
    /// `today` holds only providers whose snapshot is dated `date` (`UsageStore.todayTokensByProvider`).
    mutating func observe(today: [String: Int], date: String, hasUsageData: Bool) -> Int {
        // A refresh with no dated provider data is not an observation: moving the date or the
        // marks on it would make the next good reading look like a whole day of new use.
        guard hasUsageData, !today.isEmpty else { return 0 }
        let today = today.mapValues { min(max(0, $0), TamerBalance.maxTokenValue) }

        guard baselineSet else {
            baselineSet = true
            claimed = today
            lastDate = date
            return 0
        }

        if date != lastDate {
            lastDate = date
            var next = Dictionary(uniqueKeysWithValues: claimed.keys.map { ($0, 0) })
            for (provider, current) in today { next[provider] = current }
            claimed = next
            return today.values.reduce(0, +)
        }

        var delta = 0
        for (provider, current) in today {
            guard let previous = claimed[provider] else {
                claimed[provider] = current
                continue
            }
            if current < previous {
                AppLog.write("tamer ledger regression provider=\(provider) date=\(date) previous=\(previous) current=\(current) — rebased")
                claimed[provider] = current
                continue
            }
            delta += current - previous
            claimed[provider] = current
        }
        return delta
    }
}
