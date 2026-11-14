import SwiftUI

/// Settings → 난이도, after PokeTokenBar/DigiMonTokenBar's DifficultySettingsSection: two
/// logarithmic sliders (10 %…200 %) edited as a draft and applied with 저장, so dragging a slider
/// does not rescale the gauge on every tick.
@MainActor
struct DifficultySection: View {
    let tamer: TamerStore
    @State private var growth: Double
    @State private var shop: Double

    init(tamer: TamerStore) {
        self.tamer = tamer
        _growth = State(initialValue: tamer.growthDifficulty)
        _shop = State(initialValue: tamer.shopDifficulty)
    }

    private var t: TamerText { tamer.text }
    private var changed: Bool { growth != tamer.growthDifficulty || shop != tamer.shopDifficulty }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(t.difficultyTitle)
                .font(.caption).fontWeight(.semibold).foregroundStyle(CyberPalette.cyan)
                .textCase(.uppercase).padding(.leading, 4)
            VStack(spacing: 0) {
                row(t.difficultyGrowth, value: $growth, low: t.difficultyEasy, high: t.difficultyHard)
                Divider()
                row(t.difficultyShop, value: $shop, low: t.difficultyCheap, high: t.difficultyExpensive)
                Text(t.difficultyHint).font(.caption2).foregroundStyle(TamerPalette.mute)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12).padding(.bottom, 8)
            }
            .tamerCard(radius: 10)
            HStack {
                Spacer()
                if growth != TamerDifficulty.defaultValue || shop != TamerDifficulty.defaultValue {
                    Button(t.resetDefault) {
                        growth = TamerDifficulty.defaultValue
                        shop = TamerDifficulty.defaultValue
                    }
                    .controlSize(.small)
                }
                if changed {
                    Button(t.save) {
                        tamer.setGrowthDifficulty(growth)
                        tamer.setShopDifficulty(shop)
                        growth = tamer.growthDifficulty
                        shop = tamer.shopDifficulty
                    }
                    .buttonStyle(.borderedProminent).controlSize(.small)
                }
            }
        }
    }

    private func row(_ label: String, value: Binding<Double>, low: String, high: String) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 10) {
                Text(label).font(.callout).frame(width: 64, alignment: .leading)
                Slider(value: Binding(
                    get: { TamerDifficulty.position(value.wrappedValue) },
                    set: { value.wrappedValue = TamerDifficulty.value(atPosition: $0) }), in: 0...1)
                    .accessibilityLabel(label)
                Text(TamerDifficulty.label(value.wrappedValue))
                    .font(.caption).monospacedDigit().frame(width: 44, alignment: .trailing)
            }
            HStack {
                Text(low)
                Spacer()
                Text(high)
            }
            .font(.caption2).foregroundStyle(TamerPalette.mute)
            .padding(.leading, 74).padding(.trailing, 54)
            .accessibilityHidden(true)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
    }
}
