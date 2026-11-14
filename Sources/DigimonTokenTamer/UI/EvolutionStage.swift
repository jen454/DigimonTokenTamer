import SwiftUI

/// One frame of the evolution / hatching sequence (DESIGN §4, tools/motion_lab.py `evolve`/`hatch`).
struct EvolutionFrame: Equatable {
    enum Who { case current, next }
    var who: Who = .current
    var mode: PixelSprite.Mode = .normal
    var dx: CGFloat = 0     // in dots
    var dy: CGFloat = 0     // in dots
    var flash = false
    var crack = false
    var sparks = false
    var duration: Double
}

enum EvolutionScript {
    /// The before/after sprites of a hatch or evolution; nil for other events.
    static func paths(_ event: TamerEvent, catalog: TamerCatalog) -> (current: String, next: String)? {
        switch event {
        case .hatch(let key):
            guard let line = catalog.line(key) else { return nil }
            return (line.eggSprite, line.stages[0].sprite)
        case .evolve(let key, let from, let to):
            guard let line = catalog.line(key) else { return nil }
            return (line.stages[from].sprite, line.stages[to].sprite)
        case .crestLit:
            return nil
        }
    }

    static func frames(_ event: TamerEvent) -> [EvolutionFrame] {
        var frames: [EvolutionFrame] = []
        if case .hatch = event {
            frames.append(EvolutionFrame(duration: 0.7))
            for (i, d) in [300, 260, 220, 180, 150, 120, 100, 90, 80, 70, 60, 60].enumerated() {
                frames.append(EvolutionFrame(dx: i % 2 == 0 ? -1 : 1, crack: i > 5, duration: Double(d) / 1000))
            }
            frames += [EvolutionFrame(flash: true, duration: 0.08), EvolutionFrame(mode: .white, duration: 0.08),
                       EvolutionFrame(flash: true, duration: 0.08)]
            frames += [EvolutionFrame(who: .next, dy: -2, sparks: true, duration: 0.4), EvolutionFrame(who: .next, sparks: true, duration: 0.3),
                       EvolutionFrame(who: .next, dy: -2, duration: 0.25), EvolutionFrame(who: .next, duration: 0.8)]
            return frames
        }
        for k in 0..<8 { frames.append(EvolutionFrame(dx: k % 2 == 0 ? -1 : 1, duration: 0.08)) }
        for (i, d) in [340, 280, 220, 170, 130, 100, 80, 65, 55, 50, 45, 45].enumerated() {
            frames.append(EvolutionFrame(who: i % 2 == 0 ? .current : .next, mode: .black, duration: Double(d) / 1000))
        }
        frames += [EvolutionFrame(flash: true, duration: 0.07), EvolutionFrame(who: .next, mode: .white, duration: 0.07),
                   EvolutionFrame(flash: true, duration: 0.07), EvolutionFrame(who: .next, mode: .white, duration: 0.14)]
        frames += [EvolutionFrame(who: .next, sparks: true, duration: 0.5), EvolutionFrame(who: .next, dy: -2, sparks: true, duration: 0.3),
                   EvolutionFrame(who: .next, duration: 0.3), EvolutionFrame(who: .next, dy: -2, duration: 0.3),
                   EvolutionFrame(who: .next, duration: 0.9)]
        return frames
    }
}

/// Plays a hatch/evolution on one sprite. Used full size in the popover (`SceneOverlay`) and at
/// pet size on the desktop (`FloatingPetView`).
@MainActor
struct EvolutionStage: View {
    enum FlashStyle {
        /// Whole area turns white (popover).
        case fill
        /// A round white glow on the sprite — a transparent desktop window must not show a square.
        case glow
        /// The host draws the flash itself (`onFrame`), e.g. over the whole popover.
        case host
    }

    @Environment(TamerStore.self) private var tamer
    let event: TamerEvent
    let fit: CGSize
    var flashStyle: FlashStyle = .fill
    /// The first frame showing the new form (titles appear then).
    var onReveal: () -> Void = {}
    var onFinish: () -> Void = {}
    var onFrame: (EvolutionFrame) -> Void = { _ in }
    /// Shows one fixed frame instead of playing (previews).
    var still: EvolutionFrame? = nil

    @State private var frame = EvolutionFrame(duration: 0)
    @State private var revealed = false

    var body: some View {
        let paths = EvolutionScript.paths(event, catalog: tamer.catalog)
        ZStack(alignment: .bottom) {
            if flashStyle == .glow, frame.flash || frame.mode == .white {
                Circle().fill(Color.white).blur(radius: fit.width * 0.12)
                    .frame(width: fit.width * 0.9, height: fit.width * 0.9)
                    .padding(.bottom, fit.height * 0.05)
            }
            if let paths {
                let unit = max(1, fit.height / 60)
                PixelSprite(path: frame.who == .current ? paths.current : paths.next,
                            fit: fit, mode: frame.mode, placeholder: CGSize(width: fit.width / 2, height: fit.height / 2))
                    .offset(x: frame.dx * unit, y: frame.dy * unit)
                if frame.crack {
                    Image(systemName: "bolt.fill").font(.system(size: max(10, fit.height / 8)))
                        .foregroundStyle(.black.opacity(0.7))
                        .padding(.bottom, fit.height * 0.2)
                }
                if frame.sparks {
                    HStack(spacing: fit.width * 0.55) {
                        PixelIconView(icon: .spark, dot: max(2, unit + 1))
                        PixelIconView(icon: .spark, dot: max(2, unit + 1)).offset(y: fit.height * 0.15)
                    }
                    .padding(.bottom, fit.height * 0.6)
                }
            }
            if flashStyle == .fill, frame.flash { Color.white }
        }
        .frame(width: fit.width, height: fit.height, alignment: .bottom)
        .task { if let still { frame = still } else { await play() } }
    }

    private func play() async {
        for step in EvolutionScript.frames(event) {
            frame = step
            onFrame(step)
            if step.who == .next, step.sparks, !revealed {
                revealed = true
                onReveal()
            }
            try? await Task.sleep(for: .milliseconds(Int(step.duration * 1000)))
            if Task.isCancelled { return }
        }
        onFinish()
    }
}
