import SwiftUI

extension TamerEvent {
    var sceneID: String {
        switch self {
        case .hatch(let line): return "hatch-\(line)"
        case .evolve(let line, let from, let to): return "evolve-\(line)-\(from)-\(to)"
        case .crestLit(let line): return "crest-\(line)"
        }
    }
}

/// Plays one queued event over the partner card (DESIGN §4):
/// - evolution: the silhouette flickers ever faster between the current and next form, a white
///   flash, then the new form;
/// - hatching: the egg shakes and cracks, a white flash, then In-Training I;
/// - crest: the crest grows in the centre with "용기의 문장이 빛났다!".
/// Frame timings follow tools/motion_lab.py. Click to skip.
@MainActor
struct SceneOverlay: View {
    @Environment(TamerStore.self) private var tamer
    let event: TamerEvent
    let onFinish: () -> Void

    @State private var flash = false
    @State private var showTitle = false
    @State private var crestScale: CGFloat = 0.2

    var body: some View {
        ZStack {
            Color(red: 20 / 255, green: 20 / 255, blue: 30 / 255).opacity(0.86)
            VStack(spacing: 14) {
                Spacer(minLength: 0)
                stageContent.frame(height: 260)
                VStack(spacing: 4) {
                    Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                    if let subtitle { Text(subtitle).font(.system(size: 12)).foregroundStyle(.white.opacity(0.7)) }
                }
                .opacity(showTitle ? 1 : 0)
                Spacer(minLength: 0)
                Text(tamer.text.tapToClose).font(.system(size: 10)).foregroundStyle(.white.opacity(0.4)).padding(.bottom, 8)
            }
            if flash { Color.white }
        }
        .contentShape(Rectangle())
        .onTapGesture { onFinish() }
        .task { await playCrest() }
    }

    // MARK: Content

    private var line: TamerCatalog.Line? {
        switch event {
        case .hatch(let line), .crestLit(let line), .evolve(let line, _, _): return tamer.catalog.line(line)
        }
    }

    @ViewBuilder
    private var stageContent: some View {
        if case .crestLit = event, let line {
            PixelSprite(path: line.crestSprite, scale: 4, placeholder: CGSize(width: 96, height: 96))
                .shadow(color: Color(hex: line.crest.color), radius: 14)
                .scaleEffect(crestScale)
        } else {
            EvolutionStage(event: event, fit: CGSize(width: 230, height: 220), flashStyle: .host,
                           onReveal: { withAnimation(.easeIn(duration: 0.3)) { showTitle = true } },
                           onFinish: {
                               Task { @MainActor in
                                   try? await Task.sleep(for: .seconds(1.4))
                                   onFinish()
                               }
                           },
                           onFrame: { flash = $0.flash })
        }
    }

    private var title: String {
        let t = tamer.text
        switch event {
        case .crestLit:
            return line.map { t.crestLitTitle($0.crest.ko, en: $0.crest.en) } ?? ""
        case .hatch:
            return t.hatchedTitle(line?.stages[0].displayName(tamer.language) ?? "")
        case .evolve(_, _, let to):
            return t.evolvedTitle(line?.stages[to].displayName(tamer.language) ?? "")
        }
    }

    private var subtitle: String? {
        guard let line else { return nil }
        switch event {
        case .crestLit: return tamer.text.crestLitSubtitle
        case .hatch: return tamer.catalog.stageName(0, tamer.language)
        case .evolve(_, _, let to): return tamer.catalog.stageName(to, tamer.language) + " · " + line.ko
        }
    }

    // MARK: Crest timeline (evolution and hatching run in EvolutionStage)

    private func playCrest() async {
        guard case .crestLit = event else { return }
        withAnimation(.interpolatingSpring(stiffness: 120, damping: 7)) { crestScale = 1 }
        withAnimation(.easeIn(duration: 0.3).delay(0.4)) { showTitle = true }
        try? await Task.sleep(for: .seconds(2.6))
        if !Task.isCancelled { onFinish() }
    }
}
