import SwiftUI

/// Bag: what the user owns — meat to feed, the current partner's digivice and pendant, and
/// digitama bought in the shop that wait here until "키우기" makes them the partner.
@MainActor
struct BagView: View {
    @Environment(TamerStore.self) private var tamer

    private var t: TamerText { tamer.text }
    private var partner: PartnerState? { tamer.active }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            group(t.bagConsumables) {
                row(icon: PixelSprite(path: TamerAssets.meat, scale: 2, placeholder: CGSize(width: 32, height: 32)),
                    title: t.meat, detail: t.meatDetail,
                    trailing: AnyView(HStack(spacing: 8) {
                        Text(t.meatCount(tamer.state.meat)).font(.system(size: 12, weight: .semibold)).monospacedDigit()
                        Button(t.feed) { tamer.feedMeat() }
                            .buttonStyle(.bordered).controlSize(.small)
                            .disabled(tamer.state.meat == 0 || partner?.isEgg != false)
                    }))
            }

            if let partner, let line = tamer.activeLine {
                group(t.bagEquipment + " · " + tamer.name(of: partner)) {
                    row(icon: PixelSprite(path: TamerAssets.digivice, scale: 1, mode: partner.hasDigivice ? .normal : .grey,
                                          placeholder: CGSize(width: 40, height: 38)),
                        title: t.digivice,
                        detail: partner.hasDigivice ? t.equipped(tamer.name(of: partner)) : t.notOwned,
                        trailing: AnyView(partner.hasDigivice ? TamerChip(text: t.chipOwned, tint: Color(hex: line.crest.color))
                                                              : TamerChip(text: t.notOwned)))
                    Divider().overlay(TamerPalette.nbLine)
                    let pendantPath = !partner.hasPendant ? TamerAssets.emptyPendant
                        : (partner.crestLit ? line.pendantSprite : line.pendantOffSprite)
                    row(icon: PixelSprite(path: pendantPath, fit: CGSize(width: 40, height: 56),
                                          mode: partner.hasPendant ? .normal : .grey, placeholder: CGSize(width: 34, height: 56)),
                        title: t.pendant + (partner.hasPendant ? " · " + t.crestName(line.crest.ko, en: line.crest.en) : ""),
                        detail: partner.hasPendant ? t.equipped(tamer.name(of: partner)) : t.notOwned,
                        trailing: AnyView(partner.hasPendant
                            ? TamerChip(text: partner.crestLit ? t.chipLit : t.chipOff,
                                        tint: partner.crestLit ? Color(hex: line.crest.color) : nil)
                            : TamerChip(text: t.notOwned)))
                }
            }

            if !tamer.state.bagEggs.isEmpty {
                group(t.bagEggs) {
                    ForEach(Array(tamer.state.bagEggs.enumerated()), id: \.offset) { index, key in
                        if index > 0 { Divider().overlay(TamerPalette.nbLine) }
                        if let line = tamer.catalog.line(key) {
                            row(icon: PixelSprite(path: line.eggSprite, scale: 2, placeholder: CGSize(width: 32, height: 40)),
                                title: "\(line.ko) · \(t.digitama)", detail: t.startRaisingHint,
                                trailing: AnyView(Button(t.startRaising) { tamer.startEgg(key) }
                                    .buttonStyle(.borderedProminent).controlSize(.small)))
                        }
                    }
                }
            }

            if partner == nil, tamer.state.bagEggs.isEmpty, tamer.state.meat == 0 {
                Text(t.bagEmpty).font(.system(size: 12)).foregroundStyle(TamerPalette.mute)
            }
        }
    }

    private func group<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            TamerSectionHeading(title: title).padding(.leading, 2)
            VStack(spacing: 0) { content() }
                .padding(.horizontal, 12).tamerCard()
        }
    }

    private func row(icon: some View, title: String, detail: String, trailing: AnyView) -> some View {
        HStack(spacing: 12) {
            icon.frame(width: 52, height: 56)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .semibold))
                Text(detail).font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            trailing
        }
        .padding(.vertical, 10)
    }
}
