import AppKit

/// Menu bar frames (DESIGN §3.1, motion lab "idle" and "ready").
///
/// The icon is as wide as the character plus a small slot for the "!" badge. Sprites up to
/// 22 px tall are drawn at an integer scale with nearest-neighbour sampling; taller ones are
/// scaled down to fit, which the design accepted after checking in the motion lab.
enum MenuBarArt {
    struct Frame {
        let image: NSImage
        let cgImage: CGImage
        let delay: TimeInterval
    }

    static let height: CGFloat = 22
    /// Device pixels per point: frames are rendered for Retina.
    static let scale: CGFloat = 2
    private static var pixelHeight: CGFloat { height * scale }
    /// Left inset of the character, in device pixels.
    private static let leftInset: CGFloat = 2
    /// Room kept right of the character for the "!" (4 dots × 2 px + gaps). Always reserved, so
    /// the item does not change width when evolution becomes possible; it also keeps the token
    /// text close to the character instead of a fixed 54 pt slot.
    private static let badgeRoom: CGFloat = 12

    /// Device pixels per sprite dot (motion lab: `h<=22?2:h<=44?1:44/h`), narrowed for wide sprites.
    static func dotScale(for pixels: CGSize) -> CGFloat {
        let h = max(pixels.height, 1), w = max(pixels.width, 1)
        let byHeight: CGFloat = h <= 22 ? 2 : (h <= 44 ? 1 : 44 / h)
        return min(byHeight, 76 / w)
    }

    /// The looping frames for one subject. `ready` adds the bobbing "!" badge and wins over the
    /// mood; otherwise the mood shows (motion lab): asleep (usage cannot refresh) → dimmed with
    /// a Z, walking → bob while turning, quicker while many tokens flow.
    static func loop(sprite: SpritePack.Sprite?, isEgg: Bool, ready: Bool, mood: PartnerMood = .idle) -> [Frame] {
        guard let sprite else { return placeholder(isEgg: isEgg) }
        if ready {
            return (0..<8).compactMap { k in
                render(sprite, up: k % 2 == 1, flip: false, badgeBob: k % 2, overlay: nil, delay: 0.3)
            }
        }
        if isEgg {
            return [render(sprite, up: false, flip: false, badgeBob: nil, overlay: nil, delay: 0.6),
                    render(sprite, up: true, flip: false, badgeBob: nil, overlay: nil, delay: 0.6)].compactMap { $0 }
        }
        switch mood {
        case .sleeping:
            return (0..<4).compactMap { k in
                render(sprite, up: false, flip: false, badgeBob: nil, overlay: nil, delay: 0.7,
                       mark: k % 2 == 0 ? .sleep : nil, markLift: k % 4 == 0 ? 0 : 2, dim: true)
            }
        case .walking, .busy:
            let delay = mood == .busy ? 0.2 : 0.3
            var frames: [Frame] = []
            for flip in [false, true] {
                for k in 0..<6 {
                    if let f = render(sprite, up: k % 2 == 1, flip: flip, badgeBob: nil, overlay: nil, delay: delay) { frames.append(f) }
                }
            }
            return frames
        case .idle, .egg, .ready:
            // Idle: three bobs facing right, three facing left (motion lab `idle`).
            var frames: [Frame] = []
            for flip in [false, true] {
                for k in 0..<6 {
                    if let f = render(sprite, up: k % 2 == 1, flip: flip, badgeBob: nil, overlay: nil, delay: 0.5) { frames.append(f) }
                }
            }
            return frames
        }
    }

    /// A one-off sequence: the crest twinkles next to the character (DESIGN §3.1, 1–2 s).
    /// The item widens for these frames only.
    static func crestTwinkle(sprite: SpritePack.Sprite?, crest: SpritePack.Sprite?) -> [Frame] {
        guard let sprite, let crest else { return [] }
        return [1.0, 0.55, 1.0, 0.35].compactMap { alpha in
            render(sprite, up: false, flip: false, badgeBob: nil, overlay: (crest, alpha), delay: 0.4)
        }
    }

    private static func context(width: CGFloat) -> CGContext? {
        CGContext(data: nil, width: Int(width), height: Int(pixelHeight), bitsPerComponent: 8,
                  bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    }

    private static func render(_ sprite: SpritePack.Sprite, up: Bool, flip: Bool, badgeBob: Int?,
                               overlay: (SpritePack.Sprite, CGFloat)?, delay: TimeInterval,
                               mark: PixelIcon? = nil, markLift: Int = 0, dim: Bool = false) -> Frame? {
        let s = dotScale(for: sprite.pixels)
        let w = (sprite.pixels.width * s).rounded(), h = (sprite.pixels.height * s).rounded()
        let crestSize: CGFloat = 36
        var width = leftInset + w + (overlay == nil ? badgeRoom : crestSize + 4)
        width += width.truncatingRemainder(dividingBy: 2)   // whole points
        guard let ctx = context(width: width),
              let cg = sprite.image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let x = leftInset
        let y: CGFloat = 1 + (up ? 2 : 0)   // bottom-aligned, bob by one point
        ctx.interpolationQuality = s >= 1 ? .none : .medium
        ctx.saveGState()
        if flip {
            ctx.translateBy(x: x * 2 + w, y: 0)
            ctx.scaleBy(x: -1, y: 1)
        }
        if dim { ctx.setAlpha(0.55) }
        ctx.draw(cg, in: CGRect(x: x, y: y, width: w, height: h))
        ctx.restoreGState()

        let right = x + w
        if let mark {
            // Mood marks share the "!" slot to the right of the character (2 px per dot).
            mark.draw(in: ctx, origin: CGPoint(x: right + 1, y: CGFloat(4 - markLift)), dot: 2, canvasHeight: pixelHeight)
        }
        if let bob = badgeBob {
            let icon = PixelIcon.exclamation
            icon.draw(in: ctx, origin: CGPoint(x: right + 2, y: CGFloat(3 - bob * 2)), dot: 2, canvasHeight: pixelHeight)
        }
        if let (crest, alpha) = overlay, let crestCG = crest.image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            ctx.interpolationQuality = .none
            ctx.setAlpha(alpha)
            ctx.draw(crestCG, in: CGRect(x: right + 2, y: pixelHeight - crestSize - 2, width: crestSize, height: crestSize))
        }
        guard let image = ctx.makeImage() else { return nil }
        let ns = NSImage(cgImage: image, size: NSSize(width: width / scale, height: height))
        return Frame(image: ns, cgImage: image, delay: delay)
    }

    /// No sprite pack yet: an outlined egg or a dot, so the item is never invisible.
    private static func placeholder(isEgg: Bool) -> [Frame] {
        let width: CGFloat = 40
        guard let ctx = context(width: width) else { return [] }
        ctx.setStrokeColor(NSColor.labelColor.cgColor)
        ctx.setLineWidth(3)
        let rect = isEgg ? CGRect(x: 6, y: 4, width: 26, height: 34) : CGRect(x: 5, y: 6, width: 28, height: 28)
        ctx.strokeEllipse(in: rect)
        guard let image = ctx.makeImage() else { return [] }
        return [Frame(image: NSImage(cgImage: image, size: NSSize(width: width / scale, height: height)), cgImage: image, delay: 1)]
    }
}
