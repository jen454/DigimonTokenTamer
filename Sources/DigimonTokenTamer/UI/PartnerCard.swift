import SwiftUI

/// The popover partner card (DESIGN §3.2, mockup `crest-mockup.html`), top to bottom:
/// ① stage ② name · line · stage ③ gauge ④ condition row ⑤ equipment/crest row ⑥ hint.
@MainActor
struct PartnerCard: View {
    @Environment(TamerStore.self) private var tamer
    @Environment(PopoverNavigation.self) private var nav

    var body: some View {
        Group {
            if let partner = tamer.active, let line = tamer.activeLine {
                PartnerCardContent(partner: partner, line: line)
            } else {
                FirstEggPicker()
            }
        }
        .padding(16)
        .tamerCard(radius: 14)
        // Scenes (evolution, hatching, crest) cover the whole popover — see PopoverView.
    }
}

@MainActor
private struct PartnerCardContent: View {
    @Environment(TamerStore.self) private var tamer
    @Environment(UsageStore.self) private var usage
    @Environment(SpritePack.self) private var pack
    @Environment(PopoverNavigation.self) private var nav
    let partner: PartnerState
    let line: TamerCatalog.Line

    @State private var digiviceArrived = false
    @State private var crestFlying = false

    private var t: TamerText { tamer.text }
    private var crestColor: Color { Color(hex: line.crest.color) }
    private var stageLabel: String { partner.isEgg ? t.digitama : tamer.catalog.stageName(partner.stage, tamer.language) }
    private var nextStageLabel: String { tamer.catalog.stageName(partner.stage + 1, tamer.language) }
    private var crestName: String { t.crestName(line.crest.ko, en: line.crest.en) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // DigiMonTokenBar-style header: the character on the left, its profile and gauge on the right.
            HStack(alignment: .top, spacing: 14) {
                stage
                infoColumn
            }
            checksRow.padding(.top, 10)
            if let row = equipmentRow { row.padding(.top, 14) }
            if let hint { hint.padding(.top, 8) }
            if tamer.state.meat > 0, !partner.isEgg {
                Button(t.feedMeat(tamer.state.meat)) { tamer.feedMeat() }
                    .buttonStyle(.bordered).controlSize(.small).padding(.top, 8)
            }
            if !tamer.storedPartners.isEmpty { storageRow.padding(.top, 10) }
        }
        .onChange(of: partner.hasDigivice) { _, has in
            guard has else { return }
            digiviceArrived = false
            withAnimation(.interpolatingSpring(stiffness: 220, damping: 9)) { digiviceArrived = true }
        }
        .onChange(of: partner.hasPendant) { _, has in
            guard has else { return }
            crestFlying = true
            withAnimation(.easeInOut(duration: 0.9).delay(0.3)) { crestFlying = false }
        }
        .onAppear { digiviceArrived = true }
    }

    // MARK: ① Stage — click to pet

    private static let stageSide: CGFloat = 132

    private var stage: some View {
        let pixels = pack.sprite(spritePath)?.pixels ?? CGSize(width: 32, height: 32)
        // Largest whole scale (up to 3×) that fits the box: ultimate/mega forms (~55 px) get 2×.
        let scale = max(1, min(3, ((Self.stageSide - 12) / max(pixels.height, pixels.width)).rounded(.down)))
        let walkRange = max(2, Int((Self.stageSide - pixels.width * scale) / 2 / scale) - 1)
        return ZStack(alignment: .bottom) {
            LinearGradient(colors: [TamerPalette.stageTop, TamerPalette.stageBottom], startPoint: .top, endPoint: .bottom)
            MotionSprite(path: spritePath, scale: scale,
                         mood: PartnerMood.current(usage: usage, tamer: tamer),
                         action: tamer.action, actionID: tamer.actionID, actionAt: tamer.actionAt,
                         walkRange: walkRange, showsBadge: false)
                .padding(.bottom, 8)
        }
        .frame(width: Self.stageSide, height: Self.stageSide)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
        .onTapGesture { if !partner.isEgg { tamer.pet() } }
        .help(partner.isEgg ? "" : t.petHelp)
        .overlay(alignment: .topTrailing) {
            if tamer.canEvolve {
                Button { tamer.evolve() } label: { BouncingBadge() }
                    .buttonStyle(.plain)
                    .help(t.evolveNow)
                    .accessibilityLabel(t.evolveNow)
                    .padding(8)
            }
        }
    }

    private var spritePath: String {
        partner.isEgg ? line.eggSprite : line.stages[partner.stage].sprite
    }

    // MARK: ②③ Profile and gauge

    private var info: TamerCatalog.Info? {
        partner.isEgg ? nil : line.stages[partner.stage].info
    }

    private var infoColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(t.lineLabel(line.ko, line.key)) · \(stageLabel)")
                .font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
            Text(tamer.name(of: partner))
                .font(.system(size: 18, weight: .bold)).lineLimit(1).minimumScaleFactor(0.7)
            if let info {
                // Type and attribute, then the signature moves listed to their right (wrapping when long).
                WrappingHStack(spacing: 4, lineSpacing: 4) {
                    TamerChip(text: info.type.text(tamer.language))
                    if !info.attribute.text(tamer.language).isEmpty { TamerChip(text: info.attribute.text(tamer.language)) }
                    ForEach(info.moves.list(tamer.language), id: \.self) { move in
                        Text(move)
                            .font(.system(size: 11))
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .foregroundStyle(crestColor)
                            .overlay(Capsule().stroke(crestColor.opacity(0.5), lineWidth: 1))
                            .fixedSize()
                            .help(t.movesLabel)
                    }
                }
            } else if !partner.isEgg {
                Text(t.noProfile).font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
            } else {
                Text(t.eggInfo(line.ko, crest: t.crestName(line.crest.ko, en: line.crest.en)))
                    .font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 6)
            HStack(spacing: 4) {
                Text(partner.isEgg ? t.hatchGauge : t.evolutionGauge).foregroundStyle(TamerPalette.mute)
                Spacer()
                Text(TokenFormatter.compact(partner.gauge)).fontWeight(.semibold).foregroundStyle(TamerPalette.ink)
                Text("/ " + TokenFormatter.compact(tamer.gaugeSize(for: partner)))
                    .foregroundStyle(TamerPalette.mute)
            }
            .font(.system(size: 11)).monospacedDigit()
            TamerBar(fraction: tamer.gaugeFraction(for: partner))
                .help(TokenFormatter.grouped(partner.gauge) + " / " + TokenFormatter.grouped(tamer.gaugeSize(for: partner)) + " tokens")
            Text(remainingText).font(.system(size: 10)).foregroundStyle(TamerPalette.mute)
        }
        .frame(maxWidth: .infinity, minHeight: Self.stageSide, alignment: .topLeading)
    }

    private var remainingText: String {
        let left = max(0, tamer.gaugeSize(for: partner) - partner.gauge)
        if partner.isEgg { return t.toHatch(TokenFormatter.compact(left)) }
        if partner.stage == TamerCatalog.stageCount - 1 { return t.toBondLevel(TokenFormatter.compact(left)) }
        return left == 0 ? t.gaugeFull : t.toNextStage(TokenFormatter.compact(left))
    }

    // MARK: ④ Conditions

    @ViewBuilder
    private var checksRow: some View {
        let checks = tamer.checks(for: partner)
        if partner.isEgg {
            checkChip(met: false, text: t.hatchCheck(Int(tamer.gaugeFraction(for: partner) * 100)))
        } else if !checks.isEmpty {
            WrappingHStack(spacing: 6, lineSpacing: 4) {
                ForEach(Array(checks.enumerated()), id: \.offset) { _, check in
                    checkChip(met: check.met, text: label(for: check))
                }
            }
        }
    }

    private func label(for check: EvolutionCheck) -> String {
        switch check.kind {
        case .gauge: return t.gaugeCheck(Int(tamer.gaugeFraction(for: partner) * 100))
        case .digivice: return t.digivice
        case .pendant: return t.pendant
        case .crest:
            let percent = Int(Double(partner.crestDays) / Double(TamerBalance.crestTrialDays) * 100)
            return check.met ? crestName : "\(crestName) (\(percent)%)"
        case .bond: return t.bondCheck(partner.bondLevel, TamerBalance.bondLevelForMega)
        }
    }

    private func checkChip(met: Bool, text: String) -> some View {
        Text("\(met ? "✓" : "·") \(text)")
            .font(.system(size: 11))
            .padding(.horizontal, 7).padding(.vertical, 2)
            .foregroundStyle(met ? TamerPalette.okText : Color(hex: "#888888"))
            .background(Capsule().fill(met ? TamerPalette.okChip : TamerPalette.chip))
            .fixedSize()
    }

    // MARK: ⑤ Equipment / crest

    private var equipmentRow: AnyView? {
        switch partner.stage {
        case 2:
            return AnyView(row(
                icon: PixelSprite(path: TamerAssets.digivice, scale: 1, mode: partner.hasDigivice ? .normal : .grey,
                                  placeholder: CGSize(width: 40, height: 38))
                    .shadow(color: partner.hasDigivice ? Color(hex: "#7fc8ff") : .clear, radius: 3)
                    .scaleEffect(digiviceArrived ? 1 : 0.3)
                    .rotationEffect(.degrees(digiviceArrived ? 0 : -20)),
                title: t.digivice,
                detail: partner.hasDigivice ? t.digiviceOwnedDetail : t.digiviceNeededDetail,
                progress: nil,
                chip: partner.hasDigivice ? TamerChip(text: t.chipOwned, tint: crestColor) : TamerChip(text: t.chipNeeded)))
        case 3:
            let trial = t.trialProgress(line.crest.ko, en: line.crest.en, partner.crestDays, TamerBalance.crestTrialDays)
            let trialFraction = Double(partner.crestDays) / Double(TamerBalance.crestTrialDays)
            if !partner.hasPendant {
                return AnyView(row(icon: pendantIcon(TamerAssets.emptyPendant, mode: .grey),
                                   title: crestName, detail: t.pendantNeededDetail + "\n" + trial,
                                   progress: (trialFraction, Color(hex: "#bbbbbb")), chip: TamerChip(text: t.chipPendantNeeded)))
            }
            if !partner.crestEarned {
                return AnyView(row(icon: pendantIcon(line.pendantOffSprite, mode: .normal),
                                   title: "\(t.pendant) · \(crestName)", detail: trial,
                                   progress: (trialFraction, Color(hex: "#bbbbbb")), chip: TamerChip(text: t.chipOff)))
            }
            return AnyView(row(icon: pendantIcon(line.pendantSprite, mode: .normal, glow: true),
                               title: "\(t.pendant) · \(crestName)", detail: t.crestShiningDetail,
                               progress: nil, chip: TamerChip(text: t.chipLit, tint: crestColor)))
        case 4:
            let need = TamerBalance.bondLevelForMega * TamerBalance.bondPointsPerLevel
            return AnyView(row(icon: pendantIcon(line.pendantSprite, mode: .normal, glow: true),
                               title: "\(t.pendant) · \(crestName)",
                               detail: t.bondDetail(partner.bondLevel, TamerBalance.bondLevelForMega),
                               progress: (Double(partner.bondPoints) / Double(need), crestColor),
                               chip: TamerChip(text: t.chipLit, tint: crestColor)))
        case 5:
            return AnyView(row(icon: pendantIcon(line.pendantSprite, mode: .normal, glow: true),
                               title: "\(t.pendant) · \(crestName)", detail: t.megaBondDetail(partner.bondLevel),
                               progress: (tamer.gaugeFraction(for: partner), crestColor),
                               chip: TamerChip(text: t.chipLit, tint: crestColor)))
        default:
            return nil
        }
    }

    private func pendantIcon(_ path: String, mode: PixelSprite.Mode, glow: Bool = false) -> some View {
        ZStack {
            PixelSprite(path: path, scale: 1, mode: mode, placeholder: CGSize(width: 40, height: 68))
                .shadow(color: glow ? crestColor.opacity(0.8) : .clear, radius: glow ? 4 : 0)
                .modifier(GlowPulse(active: glow))
            if crestFlying {
                // Buying the pendant: the dim crest flies into its window (mockup `doTag`).
                PixelSprite(path: line.crestSprite, scale: 1, mode: .grey, placeholder: CGSize(width: 24, height: 24))
                    .scaleEffect(2)
                    .offset(x: 150, y: -60)
                    .transition(.identity)
            }
        }
        .animation(.easeInOut(duration: 0.9), value: crestFlying)
    }

    private func row(icon: some View, title: String, detail: String, progress: (Double, Color)?, chip: TamerChip) -> some View {
        HStack(spacing: 10) {
            icon.frame(width: 52, height: 70)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .semibold))
                Text(detail).font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
                    .fixedSize(horizontal: false, vertical: true)
                if let (fraction, color) = progress {
                    TamerBar(fraction: fraction, color: color, height: 6).padding(.top, 3)
                }
            }
            Spacer(minLength: 0)
            chip
        }
        .padding(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(TamerPalette.line, lineWidth: 1))
    }

    // MARK: ⑥ Hint

    private var hint: AnyView? {
        func box(_ text: String, shop: Bool = false) -> AnyView {
            AnyView(HStack(spacing: 4) {
                Text(text).font(.system(size: 12)).foregroundStyle(Color(hex: "#555555"))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                if shop {
                    TextLink(title: t.goShop + " ›", size: 12) { nav.tab = .shop }
                }
            }
            .padding(.horizontal, 9).padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: 8).fill(TamerPalette.hint)))
        }
        if tamer.canEvolve { return box(t.hintReady(nextStageLabel)) }
        switch partner.stage {
        case ..<0: return box(t.hintEgg)
        case 0, 1: return box(tamer.language == .ko ? "게이지가 차면 저절로 진화해요." : "Evolves on its own when the gauge fills.")
        case 2: return partner.hasDigivice ? nil : box(t.hintDigivice, shop: true)
        case 3:
            if !partner.hasPendant { return box(t.hintPendant, shop: true) }
            return partner.crestEarned ? nil : box(t.hintCrestSet(line.crest.ko, en: line.crest.en))
        case 4: return partner.bondLevel < TamerBalance.bondLevelForMega ? box(t.hintBond, shop: tamer.state.meat == 0) : nil
        default: return box(t.hintMega)
        }
    }

    // MARK: Storage

    private var storageRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(t.storage).font(.system(size: 11, weight: .semibold)).foregroundStyle(TamerPalette.mute)
            HStack(spacing: 6) {
                ForEach(tamer.storedPartners) { stored in
                    if let storedLine = tamer.catalog.line(stored.line) {
                        Button { tamer.switchPartner(to: stored.line) } label: {
                            PixelSprite(path: stored.isEgg ? storedLine.eggSprite : storedLine.stages[stored.stage].sprite,
                                        fit: CGSize(width: 40, height: 34), placeholder: CGSize(width: 30, height: 30))
                                .frame(width: 48, height: 42)
                                .background(RoundedRectangle(cornerRadius: 7).fill(TamerPalette.cell))
                        }
                        .buttonStyle(.plain)
                        .help("\(tamer.name(of: stored)) · \(t.storageHint)")
                    }
                }
            }
        }
    }
}

/// The orange "!" that bobs when every condition is met (DESIGN §2.3).
struct BouncingBadge: View {
    @State private var up = false
    var body: some View {
        PixelIconView(icon: .exclamation, dot: 3)
            .offset(y: up ? -6 : 0)
            .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: up)
            .onAppear { up = true }
            .contentShape(Rectangle())
    }
}

/// Shining crest pulse (mockup `.glow`).
private struct GlowPulse: ViewModifier {
    let active: Bool
    @State private var bright = false
    func body(content: Content) -> some View {
        content
            .brightness(active && bright ? 0.12 : 0)
            .animation(active ? .easeInOut(duration: 1.2).repeatForever(autoreverses: true) : .default, value: bright)
            .onAppear { bright = active }
            .onChange(of: active) { _, value in bright = value }
    }
}

/// First run: pick one of the eight digitama (DESIGN §2.1, the first egg is free).
@MainActor
private struct FirstEggPicker: View {
    @Environment(TamerStore.self) private var tamer
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(tamer.text.chooseEggTitle).font(.system(size: 15, weight: .bold))
            Text(tamer.text.chooseEggHint).font(.system(size: 12)).foregroundStyle(TamerPalette.mute)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(tamer.catalog.lines) { line in
                    Button { tamer.chooseFirstEgg(line.key) } label: {
                        VStack(spacing: 4) {
                            PixelSprite(path: line.eggSprite, scale: 3, placeholder: CGSize(width: 48, height: 60))
                                .frame(height: 64)
                            Text(line.ko).font(.system(size: 11)).foregroundStyle(TamerPalette.ink)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(TamerPalette.cell))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
