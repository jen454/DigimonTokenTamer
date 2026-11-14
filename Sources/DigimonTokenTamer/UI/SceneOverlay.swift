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

    private struct Frame {
        var who: Who = .current
        var mode: PixelSprite.Mode = .normal
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        var flash = false
        var crack = false
        var sparks = false
        var duration: Double
    }
    private enum Who { case current, next }

    @State private var frame = Frame(duration: 0)
    @State private var showTitle = false
    @State private var crestScale: CGFloat = 0.2

    var body: some View {
        ZStack {
            Color(red: 20 / 255, green: 20 / 255, blue: 30 / 255).opacity(0.86)
            VStack(spacing: 14) {
                Spacer(minLength: 0)
                stageContent.frame(height: 190)
                VStack(spacing: 4) {
                    Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                    if let subtitle { Text(subtitle).font(.system(size: 12)).foregroundStyle(.white.opacity(0.7)) }
                }
                .opacity(showTitle ? 1 : 0)
                Spacer(minLength: 0)
                Text(tamer.text.tapToClose).font(.system(size: 10)).foregroundStyle(.white.opacity(0.4)).padding(.bottom, 8)
            }
            if frame.flash { Color.white }
        }
        .contentShape(Rectangle())
        .onTapGesture { onFinish() }
        .task { await play() }
    }

    // MARK: Content

    private var line: TamerCatalog.Line? {
        switch event {
        case .hatch(let line), .crestLit(let line), .evolve(let line, _, _): return tamer.catalog.line(line)
        }
    }

    private var paths: (current: String, next: String)? {
        guard let line else { return nil }
        switch event {
        case .hatch: return (line.eggSprite, line.stages[0].sprite)
        case .evolve(_, let from, let to): return (line.stages[from].sprite, line.stages[to].sprite)
        case .crestLit: return nil
        }
    }

    @ViewBuilder
    private var stageContent: some View {
        if case .crestLit = event, let line {
            PixelSprite(path: line.crestSprite, scale: 4, placeholder: CGSize(width: 96, height: 96))
                .shadow(color: Color(hex: line.crest.color), radius: 14)
                .scaleEffect(crestScale)
        } else if let paths {
            ZStack(alignment: .bottom) {
                PixelSprite(path: frame.who == .current ? paths.current : paths.next,
                            fit: CGSize(width: 180, height: 170), mode: frame.mode,
                            placeholder: CGSize(width: 90, height: 90))
                    .offset(x: frame.dx, y: frame.dy)
                if frame.crack {
                    Image(systemName: "bolt.fill").font(.system(size: 22)).foregroundStyle(.black.opacity(0.7))
                        .padding(.bottom, 40)
                }
                if frame.sparks {
                    HStack(spacing: 120) {
                        PixelIconView(icon: .spark, dot: 4)
                        PixelIconView(icon: .spark, dot: 4).offset(y: 30)
                    }
                    .padding(.bottom, 110)
                }
            }
        }
    }

    private var title: String {
        let t = tamer.text
        switch event {
        case .crestLit:
            return line.map { t.crestLitTitle($0.crest.ko, en: $0.crest.en) } ?? ""
        case .hatch:
            return t.hatchedTitle(line?.stages[0].name ?? "")
        case .evolve(_, _, let to):
            return t.evolvedTitle(line?.stages[to].name ?? "")
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

    // MARK: Timeline

    private func play() async {
        if case .crestLit = event {
            withAnimation(.interpolatingSpring(stiffness: 120, damping: 7)) { crestScale = 1 }
            withAnimation(.easeIn(duration: 0.3).delay(0.4)) { showTitle = true }
            try? await Task.sleep(for: .seconds(2.6))
            if !Task.isCancelled { onFinish() }
            return
        }
        for step in timeline() {
            frame = step
            try? await Task.sleep(for: .milliseconds(Int(step.duration * 1000)))
            if Task.isCancelled { return }
            if step.sparks, !showTitle { withAnimation(.easeIn(duration: 0.3)) { showTitle = true } }
        }
        try? await Task.sleep(for: .seconds(1.4))
        if !Task.isCancelled { onFinish() }
    }

    private func timeline() -> [Frame] {
        let unit: CGFloat = 3
        var frames: [Frame] = []
        if case .hatch = event {
            frames.append(Frame(duration: 0.7))
            for (i, d) in [300, 260, 220, 180, 150, 120, 100, 90, 80, 70, 60, 60].enumerated() {
                frames.append(Frame(dx: i % 2 == 0 ? -unit : unit, crack: i > 5, duration: Double(d) / 1000))
            }
            frames += [Frame(flash: true, duration: 0.08), Frame(mode: .white, duration: 0.08), Frame(flash: true, duration: 0.08)]
            frames += [Frame(who: .next, dy: -2 * unit, sparks: true, duration: 0.4), Frame(who: .next, sparks: true, duration: 0.3),
                       Frame(who: .next, dy: -2 * unit, duration: 0.25), Frame(who: .next, duration: 0.8)]
            return frames
        }
        for k in 0..<8 { frames.append(Frame(dx: k % 2 == 0 ? -unit : unit, duration: 0.08)) }
        for (i, d) in [340, 280, 220, 170, 130, 100, 80, 65, 55, 50, 45, 45].enumerated() {
            frames.append(Frame(who: i % 2 == 0 ? .current : .next, mode: .black, duration: Double(d) / 1000))
        }
        frames += [Frame(flash: true, duration: 0.07), Frame(who: .next, mode: .white, duration: 0.07),
                   Frame(flash: true, duration: 0.07), Frame(who: .next, mode: .white, duration: 0.14)]
        frames += [Frame(who: .next, sparks: true, duration: 0.5), Frame(who: .next, dy: -2 * unit, sparks: true, duration: 0.3),
                   Frame(who: .next, duration: 0.3), Frame(who: .next, dy: -2 * unit, duration: 0.3), Frame(who: .next, duration: 0.9)]
        return frames
    }
}
