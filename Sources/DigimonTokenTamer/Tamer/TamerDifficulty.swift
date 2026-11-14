import Foundation

/// Growth and shop difficulty, as in PokeTokenBar/DigiMonTokenBar (`PokemonBalance`):
/// multipliers on the gauge sizes and on shop prices, 10 %…200 %, default 100 %.
/// The slider is logarithmic so ×0.5 and ×2 sit at equal distances from the default.
/// Stored as a preference (UserDefaults), not in the save — upstream's reasoning: it is a taste
/// setting, and importing someone else's save must not change it.
enum TamerDifficulty {
    static let range: ClosedRange<Double> = 0.1...2.0
    static let defaultValue: Double = 1.0
    static let growthKey = "tamerGrowthDifficulty"
    static let shopKey = "tamerShopDifficulty"
    private static let snapWidth = 0.01

    static func clamp(_ value: Double) -> Double {
        guard value.isFinite else { return defaultValue }
        return min(max(value, range.lowerBound), range.upperBound)
    }

    static func scaled(_ base: Int, by difficulty: Double) -> Int {
        max(1, Int((Double(base) * clamp(difficulty)).rounded()))
    }

    /// Slider position (0…1) → multiplier; snaps to the default near the middle.
    static func value(atPosition position: Double) -> Double {
        let lo = range.lowerBound, hi = range.upperBound
        let p = min(max(position, 0), 1)
        if abs(p - self.position(defaultValue)) < snapWidth { return defaultValue }
        return snap(lo * pow(hi / lo, p))
    }

    static func position(_ value: Double) -> Double {
        let lo = range.lowerBound, hi = range.upperBound
        return log(clamp(value) / lo) / log(hi / lo)
    }

    /// Two significant digits, so the label never shows 1.0473.
    static func snap(_ value: Double) -> Double {
        guard value > 0 else { return range.lowerBound }
        let magnitude = pow(10, (log10(value)).rounded(.down) - 1)
        return (value / magnitude).rounded() * magnitude
    }

    static func label(_ value: Double) -> String { String(format: "%.0f%%", value * 100) }
}
