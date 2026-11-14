import SwiftUI

/// DATA TRAFFIC, reduced to its "전체 서비스 · 상세 기록" (ALL SERVICES · DETAILS) part.
///
/// DigiMonTokenBar's Data traffic panel had a provider tab bar, the input/output ring console,
/// week/month/provider registers, the activity strip and, folded under a disclosure, the
/// all-services details. Only the details remain, now always open: today's total, this week and
/// this month, the month's daily trend stacked by provider, then the AI tool tabs (moved here
/// from the old console) with the selected tool's breakdown — input, output, cache, models.
/// The limits panel below follows the same tab.
@MainActor
struct UsageDetailsPanel: View {
    @Environment(UsageStore.self) private var store
    @Environment(PopoverNavigation.self) private var nav
    let l: L
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TamerSectionHeading(title: title)
            HStack {
                Text(l.todayTokens)
                Spacer()
                Text(TokenFormatter.grouped(store.todayTotalTokens)).monospacedDigit()
                if store.showsCost { UsageCostText(cost: store.todayUsageCost, l: l) }
            }
            .font(.system(size: 13, weight: .semibold))
            HStack(spacing: 14) {
                periodLabel(l.thisWeek, tokens: store.weekTotalTokens, cost: store.showsCost ? store.weekUsageCost : nil)
                periodLabel(l.thisMonth, tokens: store.monthTotalTokens, cost: store.showsCost ? store.monthUsageCost : nil)
                Spacer(minLength: 0)
            }
            MonthDailyTrend(series: store.monthDailyTotals,
                            providers: store.snapshots.compactMap { snap in
                                snap.monthDaily.map { DailyTrendStack.ProviderSeries(id: snap.providerID,
                                    name: snap.displayName, days: $0, reportsCost: snap.reportsCost) }
                            }, providerOrder: store.registeredProviderIDs, showsCost: store.showsCost,
                            today: LocalUsageReader.todayKey(), l: l)
            if !store.snapshots.isEmpty {
                Divider().overlay(TamerPalette.nbLine)
                ProviderTabBar(snapshots: store.snapshots, selectedID: selected?.providerID,
                               onSelect: { nav.providerID = $0 })
                if let selected, let today = selected.today {
                    providerRow(snapshot: selected, today: today)
                } else {
                    Text(l.lang == .ko ? "오늘 기록된 사용량이 없어요." : "No usage recorded today.")
                        .font(.caption).foregroundStyle(TamerPalette.mute)
                }
            } else if store.lastUpdated != nil {
                Text(l.lang == .ko ? "오늘 기록된 사용량이 없어요." : "No usage recorded today.")
                    .font(.caption).foregroundStyle(TamerPalette.mute)
            }
        }
        .font(.system(size: 11))
        .foregroundStyle(TamerPalette.ink)
        .padding(12)
        .tamerCard()
    }

    /// The tapped AI tool, or the first one.
    private var selected: ProviderSnapshot? { store.snapshot(preferring: nav.providerID) }

    private func periodLabel(_ name: String, tokens: Int, cost: UsageCost?) -> some View {
        HStack(spacing: 4) {
            Text(name).font(.caption).foregroundStyle(TamerPalette.mute)
            Text(TokenFormatter.compact(tokens)).font(.caption.weight(.semibold)).monospacedDigit()
            if let cost { UsageCostText(cost: cost, l: l).font(.caption).foregroundStyle(TamerPalette.mute) }
        }
    }

    private func providerRow(snapshot: ProviderSnapshot, today: DailyUsage) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(l.todayTokens).font(.caption).foregroundStyle(TamerPalette.mute)
                Spacer()
                Text(TokenFormatter.compact(today.totalTokens)).font(.callout).monospacedDigit()
                if snapshot.reportsCost {
                    UsageCostText(cost: today.usageCost, l: l).font(.caption).foregroundStyle(TamerPalette.mute)
                }
            }
            HStack(spacing: 10) {
                tokenTypeLabel(l.tokenInput, today.inputTokens)
                tokenTypeLabel(l.tokenOutput, today.outputTokens)
                tokenTypeLabel(l.tokenCacheWrite, today.cacheCreationTokens)
                tokenTypeLabel(l.tokenCacheRead, today.cacheReadTokens)
            }
            if let models = today.models, models.count > 1 {
                ForEach(models.sorted(by: { $0.value > $1.value }), id: \.key) { model, tokens in
                    HStack(spacing: 6) {
                        Text(model.split(separator: "/").last.map(String.init) ?? model)
                            .font(.caption2).foregroundStyle(TamerPalette.mute)
                            .lineLimit(1).truncationMode(.middle)
                        Spacer()
                        Text(TokenFormatter.compact(tokens)).font(.caption2).foregroundStyle(TamerPalette.mute).monospacedDigit()
                    }
                }
            }
        }
        .padding(.top, 2)
    }

    private func tokenTypeLabel(_ name: String, _ value: Int) -> some View {
        HStack(spacing: 3) {
            Text(name).font(.caption2).foregroundStyle(TamerPalette.mute)
            Text(TokenFormatter.compact(value)).font(.caption2).foregroundStyle(TamerPalette.ink).monospacedDigit()
        }
    }
}
