import SwiftUI

/// Shop (DESIGN §2.5): meat, the digivice, the pendant and all eight digitama are always listed.
/// What is already owned shows "구매 완료"; what cannot be bought yet says why. Crests are never
/// sold. The currency is tokens already used; there are no real payments.
@MainActor
struct ShopView: View {
    @Environment(TamerStore.self) private var tamer

    private var t: TamerText { tamer.text }
    private let itemKinds: [ShopItem] = [.meat, .digivice, .pendant]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                TamerSectionHeading(title: t.wallet)
                Text(MillionFormat.string(tamer.wallet))
                    .font(.system(size: 20, weight: .bold, design: .rounded)).monospacedDigit()
                Text(t.walletHint).font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
            }
            .padding(14).frame(maxWidth: .infinity, alignment: .leading).tamerCard()

            section(nil, itemKinds)
            section(t.bagEggs, tamer.catalog.lines.map { .digitama(line: $0.key) })
        }
    }

    private func section(_ title: String?, _ items: [ShopItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title { TamerSectionHeading(title: title).padding(.leading, 2) }
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 { Divider().overlay(TamerPalette.nbLine) }
                    itemRow(item)
                }
            }
            .padding(.horizontal, 12).tamerCard()
        }
    }

    private func itemRow(_ item: ShopItem) -> some View {
        let price = tamer.price(item)
        let status = tamer.status(item)
        let affordable = tamer.wallet >= price
        return HStack(spacing: 12) {
            icon(item, dimmed: status != .available)
                .frame(width: 52, height: 56)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title(item)).font(.system(size: 13, weight: .semibold))
                    if item == .meat, tamer.state.meat > 0 { TamerChip(text: t.owned(tamer.state.meat)) }
                }
                Text(detail(item)).font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
                    .fixedSize(horizontal: false, vertical: true)
                if case .locked(let lock) = status {
                    Text(lockText(lock)).font(.system(size: 11)).foregroundStyle(TamerPalette.orange)
                        .fixedSize(horizontal: false, vertical: true)
                } else if status == .available {
                    Text(MillionFormat.string(price)).font(.system(size: 11, weight: .medium)).monospacedDigit()
                        .foregroundStyle(affordable ? TamerPalette.ink : TamerPalette.mute)
                }
            }
            Spacer(minLength: 0)
            actionButton(item, status: status, affordable: affordable)
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func actionButton(_ item: ShopItem, status: ShopStatus, affordable: Bool) -> some View {
        switch status {
        case .purchased:
            Label(t.purchased, systemImage: "checkmark")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(TamerPalette.okText)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Capsule().fill(TamerPalette.okChip))
                .fixedSize()
        case .available:
            Button(affordable ? t.buy : t.notEnough) { tamer.buy(item) }
                .buttonStyle(.borderedProminent).controlSize(.small)
                .disabled(!tamer.canBuy(item))
        case .locked:
            Button(t.buy) {}
                .buttonStyle(.borderedProminent).controlSize(.small)
                .disabled(true)
        }
    }

    @ViewBuilder
    private func icon(_ item: ShopItem, dimmed: Bool) -> some View {
        let mode: PixelSprite.Mode = .normal
        Group {
            switch item {
            case .meat: PixelSprite(path: TamerAssets.meat, scale: 2, mode: mode, placeholder: CGSize(width: 32, height: 32))
            case .digivice: PixelSprite(path: TamerAssets.digivice, scale: 1, mode: mode, placeholder: CGSize(width: 40, height: 38))
            case .pendant: PixelSprite(path: TamerAssets.emptyPendant, fit: CGSize(width: 40, height: 56), mode: mode, placeholder: CGSize(width: 34, height: 56))
            case .digitama(let line):
                PixelSprite(path: tamer.catalog.line(line)?.eggSprite ?? "", scale: 2, mode: mode, placeholder: CGSize(width: 32, height: 40))
            }
        }
        .opacity(dimmed ? 0.55 : 1)
    }

    private func lockText(_ lock: ShopLock) -> String {
        switch lock {
        case .firstEggFree: return t.lockedFirstEgg
        case .needsHatch: return t.lockedNeedsHatch
        case .fromChampion: return t.lockedFromChampion
        }
    }

    private func title(_ item: ShopItem) -> String {
        switch item {
        case .meat: return t.meat
        case .digivice: return t.digivice
        case .pendant: return t.pendant
        case .digitama(let line): return "\(tamer.catalog.line(line)?.ko ?? line) · \(t.digitama)"
        }
    }

    private func detail(_ item: ShopItem) -> String {
        switch item {
        case .meat: return t.meatDetail
        case .digivice: return t.digiviceDetail + " · " + t.forCurrentPartner
        case .pendant: return t.pendantDetail + " · " + t.forCurrentPartner
        case .digitama(let line): return t.digitamaDetail(tamer.catalog.line(line)?.ko ?? line)
        }
    }
}
