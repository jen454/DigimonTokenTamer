import Foundation

/// What the partner is doing on its own (user rules, 2026-11-14):
/// evolution possible → jumping with "!", usage cannot be refreshed → asleep, otherwise walking
/// (a little faster while many tokens are flowing). `idle` is only the analyzer's still pose.
enum PartnerMood: String, Equatable, Sendable {
    case egg, idle, walking, busy, sleeping
    /// Every evolution condition is met: jump with the "!". Wins over everything else.
    case ready

    @MainActor
    static func current(usage: UsageStore, tamer: TamerStore) -> PartnerMood {
        guard let partner = tamer.active else { return .idle }
        if partner.isEgg { return .egg }
        if tamer.canEvolve { return .ready }
        if usage.isRefreshFailing { return .sleeping }
        switch usage.burnTier {
        case .fast, .blazing: return .busy
        case .idle, .normal: return .walking
        }
    }
}

/// One-shot motions started by the user or by an event (motion lab names in parentheses).
enum PartnerAction: Equatable, Sendable {
    case pet     // 쓰다듬기: hearts rise
    case annoyed // 짜증: petted too often — anger mark, shaking
    case eat     // 먹기: bites into a piece of meat
    case happy   // 기쁨: hops with notes
}

/// One frame of a motion, in sprite dots (tools/motion_lab.py frame format:
/// `{d, dx, dy, flip, mode, ov:[…]}`).
struct MotionFrame: Equatable, Sendable {
    var duration: Double
    var dx: Int = 0
    var dy: Int = 0
    var flip = false
    var dim = false
    var overlays: [MotionOverlay] = []
}

struct MotionOverlay: Equatable, Sendable {
    enum Item: Equatable, Sendable {
        case icon(PixelIcon)
        /// The meat sprite with `bites` of 9 columns eaten from the left.
        case meat(bites: Int)
    }
    enum Horizontal: Sendable { case left, center, right }
    enum Vertical: Sendable { case top, middle, ground }
    var item: Item
    var horizontal: Horizontal
    var vertical: Vertical
    var ox: Int = 0
    var oy: Int = 0
}

/// Frame scripts, ported from the motion lab (DESIGN §4).
enum MotionScript {
    /// The loop for a mood. `walkRange` is how many dots the walk may stray from the centre.
    static func loop(_ mood: PartnerMood, walkRange: Int = 8) -> [MotionFrame] {
        switch mood {
        case .egg:
            return [MotionFrame(duration: 0.6), MotionFrame(duration: 0.6, dy: -1),
                    MotionFrame(duration: 0.15, dx: -1), MotionFrame(duration: 0.15, dx: 1), MotionFrame(duration: 0.6)]
        case .idle:
            var frames: [MotionFrame] = []
            for flip in [false, true] {
                for _ in 0..<3 {
                    frames.append(MotionFrame(duration: 0.5, flip: flip))
                    frames.append(MotionFrame(duration: 0.5, dy: -1, flip: flip))
                }
            }
            return frames
        case .walking, .busy:
            let step = mood == .busy ? 0.1 : 0.16
            var frames: [MotionFrame] = []
            var x = 0, dir = 1
            let range = max(2, walkRange)
            for k in 0..<(range * 4) {
                x += dir
                if abs(x) >= range { dir = -dir }
                frames.append(MotionFrame(duration: step, dx: x, dy: (k >> 1) % 2 == 1 ? -1 : 0, flip: dir < 0))
            }
            return frames
        case .sleeping:
            return (0..<8).map { k in
                var overlays = [MotionOverlay(item: .icon(.sleep), horizontal: .right, vertical: .top, ox: k % 4, oy: -2 - (k % 4) * 2)]
                if k % 4 > 1 { overlays.append(MotionOverlay(item: .icon(.sleep), horizontal: .right, vertical: .top, ox: 4 + k % 2, oy: -9)) }
                return MotionFrame(duration: 0.55, dim: true, overlays: overlays)
            }
        case .ready:
            // Jumping with the "!" riding on the top-right corner (it moves with the sprite).
            let badge = MotionOverlay(item: .icon(.exclamation), horizontal: .right, vertical: .top, ox: 1, oy: -5)
            var frames = [0, -3, -5, -6, -5, -3, 0].map { MotionFrame(duration: 0.07, dy: $0, overlays: [badge]) }
            frames += [MotionFrame(duration: 0.35, overlays: [badge]), MotionFrame(duration: 0.25, dy: -1, overlays: [badge]),
                       MotionFrame(duration: 0.25, overlays: [badge])]
            return frames
        }
    }

    static func once(_ action: PartnerAction) -> [MotionFrame] {
        switch action {
        case .annoyed:
            // Motion lab `sulk`: shakes with the anger mark, then turns away for a moment.
            let anger = MotionOverlay(item: .icon(.anger), horizontal: .right, vertical: .top, ox: -3, oy: -2)
            var frames = (0..<12).map { k in
                MotionFrame(duration: 0.08, dx: k % 2 == 1 ? 1 : -1, overlays: k % 4 < 2 ? [anger] : [])
            }
            frames += [MotionFrame(duration: 0.7, overlays: [anger]),
                       MotionFrame(duration: 0.6, flip: true, overlays: [anger]), MotionFrame(duration: 0.6, flip: true)]
            return frames
        case .pet:
            var frames = (0..<9).map { k in
                MotionFrame(duration: 0.13, dy: k % 2 == 1 ? -1 : 0,
                            overlays: [MotionOverlay(item: .icon(.heart), horizontal: .center, vertical: .top, ox: -3, oy: -4 - k)])
            }
            frames += [MotionFrame(duration: 0.25, dy: -2), MotionFrame(duration: 0.4)]
            return frames
        case .eat:
            func meat(_ bites: Int) -> MotionOverlay {
                // The 16×16 meat sprite rests on the ground just in front of the mouth.
                MotionOverlay(item: .meat(bites: bites), horizontal: .right, vertical: .ground, ox: -3, oy: -15)
            }
            var frames = [MotionFrame(duration: 0.5, overlays: [meat(0)])]
            for b in 0..<3 {
                frames.append(MotionFrame(duration: 0.16, dx: 2, overlays: [meat(b * 3)]))
                frames.append(MotionFrame(duration: 0.2, overlays: [meat(b * 3 + 3)]))
                frames.append(MotionFrame(duration: 0.32, dy: -1, overlays: [meat(b * 3 + 3)]))
            }
            frames += [MotionFrame(duration: 0.25, dy: -2), MotionFrame(duration: 0.25),
                       MotionFrame(duration: 0.25, dy: -2), MotionFrame(duration: 0.4)]
            return frames
        case .happy:
            let arc = [0, -3, -5, -6, -5, -3, 0]
            var frames: [MotionFrame] = []
            for _ in 0..<2 {
                for (i, y) in arc.enumerated() {
                    frames.append(MotionFrame(duration: 0.07, dy: y,
                                              overlays: [MotionOverlay(item: .icon(.note), horizontal: .right, vertical: .top, ox: 1, oy: -5 - i % 2)]))
                }
                frames.append(MotionFrame(duration: 0.22))
            }
            return frames
        }
    }
}
