import SwiftUI

/// A sprite that plays motion frames (DESIGN §4): integer dot moves, stepped frames, overlay icons
/// drawn at the sprite's scale. A one-shot action (pet, eat, happy) plays first, then the mood loop.
@MainActor
struct MotionSprite: View {
    @Environment(SpritePack.self) private var pack
    let path: String
    let scale: CGFloat
    let mood: PartnerMood
    var action: PartnerAction? = nil
    /// Changes whenever a new action should play (`TamerStore.actionID`).
    var actionID: Int = 0
    /// When the action was started: a view that appears later (popover reopened) does not replay it.
    var actionAt: Date? = nil
    /// Dots the walk may stray from the centre.
    var walkRange: Int = 8
    /// Shows one fixed frame instead of playing (previews).
    var stillFrame: MotionFrame? = nil
    /// Draw the "!" of the ready motion. The card has its own clickable "!" and turns this off.
    var showsBadge = true

    @State private var frame = MotionFrame(duration: 0)

    init(path: String, scale: CGFloat, mood: PartnerMood, action: PartnerAction? = nil, actionID: Int = 0,
         actionAt: Date? = nil, walkRange: Int = 8, stillFrame: MotionFrame? = nil, showsBadge: Bool = true) {
        self.path = path
        self.scale = scale
        self.mood = mood
        self.action = action
        self.actionID = actionID
        self.actionAt = actionAt
        self.walkRange = walkRange
        self.stillFrame = stillFrame
        self.showsBadge = showsBadge
        // Start on the loop's first frame, so the "!" (or Z, anger) is there from the first paint.
        _frame = State(initialValue: stillFrame ?? MotionScript.loop(mood, walkRange: walkRange).first ?? MotionFrame(duration: 0))
    }

    var body: some View {
        let pixels = pack.sprite(path)?.pixels ?? CGSize(width: 24, height: 24)
        let size = CGSize(width: pixels.width * scale, height: pixels.height * scale)
        PixelSprite(path: path, scale: scale, mode: frame.dim ? .dim : .normal, flipped: frame.flip,
                    placeholder: CGSize(width: 24 * scale, height: 24 * scale))
            .overlay(alignment: .topLeading) {
                ZStack(alignment: .topLeading) {
                    ForEach(Array(frame.overlays.enumerated()), id: \.offset) { _, overlay in
                        if showsBadge || overlay.item != .icon(.exclamation) {
                            overlayView(overlay).offset(position(of: overlay, in: size))
                        }
                    }
                }
            }
            .offset(x: CGFloat(frame.dx) * scale, y: CGFloat(frame.dy) * scale)
            .task(id: "\(mood.rawValue)-\(actionID)-\(path)") {
                if let stillFrame { frame = stillFrame } else { await play() }
            }
    }

    @ViewBuilder
    private func overlayView(_ overlay: MotionOverlay) -> some View {
        switch overlay.item {
        case .icon(let icon):
            PixelIconView(icon: icon, dot: max(1, scale))
        case .meat(let bites):
            let meatScale = max(1, scale)
            PixelSprite(path: TamerAssets.meat, scale: meatScale, placeholder: CGSize(width: 16 * meatScale, height: 16 * meatScale))
                .mask(alignment: .trailing) {
                    Rectangle().frame(width: 16 * meatScale * CGFloat(max(0, 9 - bites)) / 9)
                }
        }
    }

    /// Overlay top-left corner relative to the sprite's top-left, in points.
    private func position(of overlay: MotionOverlay, in size: CGSize) -> CGSize {
        let x: CGFloat
        switch overlay.horizontal {
        case .left: x = 0
        case .center: x = size.width / 2
        case .right: x = size.width
        }
        let y: CGFloat
        switch overlay.vertical {
        case .top: y = 0
        case .middle: y = size.height / 2
        case .ground: y = size.height
        }
        return CGSize(width: x + CGFloat(overlay.ox) * scale, height: y + CGFloat(overlay.oy) * scale)
    }

    private func play() async {
        if let action, actionID > 0, let actionAt, Date().timeIntervalSince(actionAt) < 1.5 {
            for step in MotionScript.once(action) {
                frame = step
                try? await Task.sleep(for: .milliseconds(Int(step.duration * 1000)))
                if Task.isCancelled { return }
            }
        }
        let loop = MotionScript.loop(mood, walkRange: walkRange)
        guard !loop.isEmpty else { return }
        while !Task.isCancelled {
            for step in loop {
                frame = step
                try? await Task.sleep(for: .milliseconds(Int(step.duration * 1000)))
                if Task.isCancelled { return }
            }
        }
    }
}
