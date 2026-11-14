import SwiftUI

/// Shop (DESIGN §2.5): meat, the digivice, the pendant and eggs of lines not yet started.
/// Crests are never sold. The currency is tokens already used; there are no real payments.
@MainActor
struct ShopView: View {
    @Environment(TamerStore.self) private var tamer

    private var t: TamerText { tamer.text }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                TamerSectionHeading(title: t.wallet)
                Text(TokenFormatter.grouped(tamer.wallet) + " tokens")
                    .font(.system(size: 20, weight: .bold, design: .rounded)).monospacedDigit()
                Text(t.walletHint).font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
            }
            .padding(14).frame(maxWidth: .infinity, alignment: .leading).tamerCard()

            VStack(spacing: 0) {
                if tamer.shopItems.isEmpty {
                    Text(t.shopEmpty).font(.system(size: 12)).foregroundStyle(TamerPalette.mute)
                        .frame(maxWidth: .infinity).padding(20)
                }
                ForEach(Array(tamer.shopItems.enumerated()), id: \.element.id) { index, item in
                    if index > 0 { Divider().overlay(TamerPalette.nbLine) }
                    itemRow(item)
                }
            }
            .padding(.horizontal, 12).tamerCard()
        }
    }

    private func itemRow(_ item: ShopItem) -> some View {
        let price = tamer.price(item)
        let affordable = tamer.wallet >= price
        return HStack(spacing: 12) {
            icon(item).frame(width: 52, height: 56)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title(item)).font(.system(size: 13, weight: .semibold))
                    if item == .meat, tamer.state.meat > 0 { TamerChip(text: t.owned(tamer.state.meat)) }
                }
                Text(detail(item)).font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
                    .fixedSize(horizontal: false, vertical: true)
                Text(TokenFormatter.compact(price)).font(.system(size: 11, weight: .medium)).monospacedDigit()
                    .foregroundStyle(affordable ? TamerPalette.ink : TamerPalette.mute)
            }
            Spacer(minLength: 0)
            Button(affordable ? t.buy : t.notEnough) { tamer.buy(item) }
                .buttonStyle(.borderedProminent).controlSize(.small)
                .disabled(!tamer.canBuy(item))
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func icon(_ item: ShopItem) -> some View {
        switch item {
        case .meat: PixelSprite(path: TamerAssets.meat, scale: 2, placeholder: CGSize(width: 32, height: 32))
        case .digivice: PixelSprite(path: TamerAssets.digivice, scale: 1, placeholder: CGSize(width: 40, height: 38))
        case .pendant: PixelSprite(path: TamerAssets.emptyPendant, fit: CGSize(width: 40, height: 56), placeholder: CGSize(width: 34, height: 56))
        case .digitama(let line):
            PixelSprite(path: tamer.catalog.line(line)?.eggSprite ?? "", scale: 2, placeholder: CGSize(width: 32, height: 40))
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
        case .digivice: return t.digiviceDetail
        case .pendant: return t.pendantDetail
        case .digitama(let line): return t.digitamaDetail(tamer.catalog.line(line)?.ko ?? line)
        }
    }
}
