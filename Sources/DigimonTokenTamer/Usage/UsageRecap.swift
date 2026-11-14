import Foundation

/// Day-by-day token totals kept across months, so a recap survives the 1st of the month.
///
/// Providers only report the current month (`monthDaily`), so on the 3rd a seven-day window would
/// lose four days and a year would be out of reach. This ledger is a local cache of numbers the app
/// already derived — no new user state, nothing to transfer between devices, and it rebuilds itself
/// from the next refresh.
struct UsageLedger: Equatable, Sendable {
    static let defaultsKey = "dailyTokenLedger"
    static let coverageKey = "dailyTokenLedgerSince"

    private(set) var tokensByDay: [String: Int] = [:]
    /// The first day the ledger vouches for. From there on a missing row means "no usage"; before it
    /// the app was not recording, which a recap must not present as a quiet stretch.
    private(set) var coveredSince: String?

    func tokens(on day: String) -> Int { tokensByDay[day] ?? 0 }

    func covers(_ day: String) -> Bool { coveredSince.map { day >= $0 } ?? false }

    /// Records a refresh. A day never goes down: a rotated or pruned log makes the provider report
    /// less than it did yesterday, and the recap would lose days that really happened. Today keeps
    /// climbing all day, so taking the larger of the two is also what the live total does.
    mutating func merge(_ series: [DailyUsage]) {
        for day in series where day.totalTokens > 0 {
            tokensByDay[day.date] = max(tokensByDay[day.date] ?? 0, day.totalTokens)
        }
        // The series lists every day since the 1st, empty ones included, so the whole stretch was
        // scanned: that is what makes a zero a real zero.
        if let first = series.map(\.date).min(), coveredSince.map({ first < $0 }) ?? true {
            coveredSince = first
        }
    }

    /// Drops what no recap can reach any more. Day keys are `yyyy-MM-dd`, which sorts
    /// lexicographically the same way it sorts chronologically.
    mutating func prune(before cutoff: String) {
        tokensByDay = tokensByDay.filter { $0.key >= cutoff }
        // The dropped days are unknown again, not empty.
        if let since = coveredSince, since < cutoff { coveredSince = cutoff }
    }

    static func load(from defaults: UserDefaults) -> UsageLedger {
        var ledger = UsageLedger()
        // Hand-edited defaults are data, not truth: keep what parses as a day and drop the rest.
        // A junk key that sorted below every real day would otherwise backdate the coverage.
        let formatter = LocalUsageReader.localDayFormatter()
        if let stored = defaults.dictionary(forKey: defaultsKey) as? [String: Int] {
            ledger.tokensByDay = stored.filter { formatter.date(from: $0.key) != nil && $0.value > 0 }
        }
        if let since = defaults.string(forKey: coverageKey), formatter.date(from: since) != nil {
            ledger.coveredSince = since
        }
        return ledger
    }

    func save(to defaults: UserDefaults) {
        defaults.set(tokensByDay, forKey: Self.defaultsKey)
        defaults.set(coveredSince, forKey: Self.coverageKey)
    }
}

enum RecapScope: String, CaseIterable, Sendable {
    case week, month, year

    fileprivate var component: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
    }
}

/// One calendar week, month or year. Calendar periods rather than rolling windows, so stepping
/// back lands on "the week of the 7th", not on an arbitrary seven days.
struct RecapPeriod: Equatable, Sendable {
    let scope: RecapScope
    /// First instant of the period.
    let start: Date
    /// First instant after the period.
    let end: Date

    init(scope: RecapScope, containing date: Date, calendar: Calendar) {
        self.scope = scope
        // API-forced unwrap: every Gregorian date sits in a week, a month and a year.
        let interval = calendar.dateInterval(of: scope.component, for: date)
            ?? DateInterval(start: calendar.startOfDay(for: date), duration: 86_400)
        start = interval.start
        end = interval.end
    }

    func shifted(by offset: Int, calendar: Calendar) -> RecapPeriod {
        let moved = calendar.date(byAdding: scope.component, value: offset, to: start) ?? start
        return RecapPeriod(scope: scope, containing: moved, calendar: calendar)
    }

    /// Gregorian whatever the system calendar, so a year runs January to December and the day keys
    /// match `LocalUsageReader.localDayFormatter`. The week still starts on the user's first weekday.
    static func calendar(timeZone: TimeZone = .current) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.firstWeekday = Calendar.current.firstWeekday
        return calendar
    }
}
