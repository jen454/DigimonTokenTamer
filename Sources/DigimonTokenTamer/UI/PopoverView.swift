import AppKit
import SwiftUI

enum PopoverTab: CaseIterable { case partner, shop, notebook }

/// Popover screen state. `AppDelegate` resets it each time the popover opens, so it always
/// starts on the partner card (upstream behaviour).
@MainActor
@Observable
final class PopoverNavigation {
    var tab: PopoverTab = .partner
    var showSettings = false
    /// Open Settings with the advanced section expanded (session-key notices link here).
    var expandAdvancedOnOpen = false
    /// Provider shown in the limits panel; kept across openings.
    var providerID: String?
    /// Claude account tab in the limits panel; kept across openings.
    var claudeAccountID: String?

    func reset() {
        showSettings = false
        expandAdvancedOnOpen = false
        tab = .partner
    }

    func openSessionKeySettings() {
        showSettings = true
        expandAdvancedOnOpen = true
    }
}

@MainActor
struct PopoverView: View {
    @Environment(UsageStore.self) private var store
    @Environment(TamerStore.self) private var tamer
    @Environment(PopoverNavigation.self) private var nav
    @Environment(SpritePack.self) private var pack

    private var l: L { tamer.l }
    private var t: TamerText { tamer.text }

    var body: some View {
        Group {
            if nav.showSettings {
                SettingsView(onClose: {
                    nav.showSettings = false
                    nav.expandAdvancedOnOpen = false
                }, startExpanded: nav.expandAdvancedOnOpen)
            } else {
                mainContent
            }
        }
        .frame(width: PopoverMetrics.width)
        .background(TamerPalette.background)
        .foregroundStyle(TamerPalette.ink)
        .environment(\.colorScheme, .light)
        .environment(\.locale, tamer.language.displayLocale)
    }

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            if pack.isMissing { spritePackNotice }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    switch nav.tab {
                    case .partner:
                        PartnerCard()
                        UsageDetailsPanel(l: l, title: t.dataTraffic)
                        LimitsPanel(l: l, language: tamer.language, title: t.limitsTitle)
                    case .shop:
                        ShopView()
                    case .notebook:
                        NotebookView()
                    }
                }
                .reservesScrollerLane()
            }
            .frame(height: 560)
            footer
                .padding(.top, 8)
                .overlay(alignment: .top) { Rectangle().fill(TamerPalette.line).frame(height: 1) }
        }
        .padding(PopoverMetrics.padding)
    }

    /// Shown while no sprite resolves, so empty placeholders are never left unexplained.
    private var spritePackNotice: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "photo.badge.exclamationmark").foregroundStyle(TamerPalette.orange)
            Text(t.spritePackMissing).font(.system(size: 11)).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button(t.reloadSprites) { pack.reload() }.controlSize(.small)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: "#fff4e5")))
    }

    // MARK: Header — title + tabs (mockup `.seg`)

    private var header: some View {
        HStack(spacing: 10) {
            Text(tamer.language == .ko ? "디지몬 토큰 테이머" : "Digimon Token Tamer")
                .font(.system(size: 14, weight: .bold))
            Spacer()
            HStack(spacing: 4) {
                ForEach(PopoverTab.allCases, id: \.self) { tab in
                    let selected = nav.tab == tab
                    Button { nav.tab = tab } label: {
                        Text(title(tab))
                            .font(.system(size: 12))
                            .padding(.horizontal, 9).padding(.vertical, 5)
                            .foregroundStyle(selected ? .white : TamerPalette.ink)
                            .background(RoundedRectangle(cornerRadius: 8).fill(selected ? Color(hex: "#333333") : .white))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selected ? Color(hex: "#333333") : TamerPalette.line))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .overlay(alignment: .topTrailing) {
                        if tab == .partner, tamer.canEvolve, nav.tab != .partner {
                            Circle().fill(TamerPalette.orange).frame(width: 7, height: 7).offset(x: 2, y: -2)
                        }
                    }
                }
            }
        }
    }

    private func title(_ tab: PopoverTab) -> String {
        switch tab {
        case .partner: return t.tabPartner
        case .shop: return t.tabShop
        case .notebook: return t.tabNotebook
        }
    }

    // MARK: Footer (upstream, without the floating pet toggle)

    private var footer: some View {
        HStack(spacing: 10) {
            Button {
                Task { await store.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .help(l.refreshNow)
            if let updated = store.lastUpdated {
                (Text("\(l.updated) ") + Text(updated, style: .relative))
                    .font(.caption)
                    .foregroundStyle(TamerPalette.mute)
            }
            if store.lastErrorDescription != nil {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                    .help(store.lastErrorMessage(l) ?? "")
            }
            Spacer()
            Button {
                nav.showSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.borderless)
            .help(l.settings)
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .buttonStyle(.borderless)
            .help(l.quit)
        }
    }
}
